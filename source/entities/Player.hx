package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

enum State
{
	IDLE;
	MOVING;
	PREJUMPING;
	JUMPING;
	LANDING;
	CROUCHED;
	STABBING;
	AIMING_UPWARDS;
}

class Player extends FlxSprite
{
	private var currentState:State;
	private var speed:Int;
	private var jumpSpeed:Int;
	private var knife:Knife;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		loadGraphic(AssetPaths.player__png, true, 64, 64, true);
		pixelPerfectPosition = false;
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("idle", [0, 1, 2, 1], 6, true, false, false);
		animation.add("move", [3, 4, 5, 6, 7, 8, 9, 10], 12, true, false, false);
		animation.add("preJump", [11, 12], 24, false, false, false);
		animation.add("jump", [13], 16, false, false, false);
		animation.add("land", [14], 16, false, false, false);
		animation.add("crouch", [15, 16], 8, false, false, false);
		animation.add("stab", [17, 18, 19], 12, false, false, false);
		animation.add("crouchStab", [20, 21, 22], 12, false, false, false);
		animation.add("postCrouchStab", [16], 16, false, false, false);
		animation.add("aimUpwards", [23], 16, false, false, false);

		currentState = State.IDLE;
		speed = Reg.playerNormalSpeed;
		jumpSpeed = Reg.playerJumpSpeed;
		acceleration.y = Reg.gravity;

		knife = new Knife();
		knife.kill();
		FlxG.state.add(knife);
	}

	override public function update(elapsed:Float)
	{
		stateMachine();
		trace(currentState);

		super.update(elapsed);
	}

	private function stateMachine()
	{
		switch (currentState)
		{
			case State.IDLE:
				animation.play("idle");
				move();
				jump();
				crouch();
				stab();
				aimUpwards();

				if (velocity.x != 0)
					currentState = State.MOVING;
				else
				{
					if (knife.alive)
						currentState = State.STABBING;
					else 
						if (height == Reg.playerCrouchedHeight)
							currentState = State.CROUCHED;
				}

			case State.MOVING:
				animation.play("move");
				move();
				jump();
				stab();

				if (velocity.x == 0)
					currentState = State.IDLE;
				else 
					if (knife.alive)
						currentState = State.STABBING;

			case State.PREJUMPING:
				if (animation.name != "preJump")
					animation.play("preJump");

				if (animation.name == "preJump" && animation.finished)
				{
					velocity.y = jumpSpeed;
					currentState = State.JUMPING;
				}

			case State.JUMPING:
				if (animation.name != "jump")
					animation.play("jump");

				stab();

				if (velocity.y == 0)
					currentState = State.LANDING;
				else 
					if (knife.alive)
						currentState = State.STABBING;

			case State.LANDING:
				if (animation.name != "land")
					animation.play("land");

				if (animation.name == "land" && animation.finished)
				{
					if (velocity.x == 0)
						currentState = State.IDLE;
					else
						currentState = State.MOVING;
				}

			case State.CROUCHED:
				if (animation.name != "crouch" && animation.name != "crouchStab" && animation.name != "postCrouchStab")
					animation.play("crouch");
				else
					if (animation.name != "postCrouchStab")
						animation.play("postCrouchStab");
				stab();

				if (!FlxG.keys.pressed.DOWN)
				{
					y -= 16;
					updateHitbox();
					currentState = State.IDLE;
				}
				else 
					if (knife.alive)
						currentState = State.STABBING;

			case State.STABBING:
				if (height == Reg.playerStandingHeight)
				{
					if (animation.name != "stab")
						animation.play("stab");
				}
				else
					if (animation.name != "crouchStab")
						animation.play("crouchStab");

				if (velocity.y == 0)
					velocity.x = 0;
				knife.x = (facing == FlxObject.LEFT) ? x - knife.width: x + width;
				knife.y = y + height / 2 - knife.height / 2;

				if ((animation.name == "stab" || animation.name == "crouchStab") && animation.finished)
				{
					knife.kill();
					
					if (velocity.y != 0)
						currentState = State.JUMPING;
					else
					{
						if (velocity.x != 0)
							currentState = State.MOVING;
						else
						{
							if (height == Reg.playerCrouchedHeight)
								currentState = State.CROUCHED;
							else
								currentState = State.IDLE;
						}
					}
				}
				
			case State.AIMING_UPWARDS:
				animation.play("aimUpwards");
				
				jump();
				stab();
				
				if (!FlxG.keys.pressed.UP)
					currentState = State.IDLE;
				else
				{
					if (velocity.y != 0)
						currentState = State.JUMPING;
					else 
						if (knife.alive)
							currentState = State.STABBING;
				}
		}
	}

	private function move():Void
	{
		velocity.x = 0;
		if (FlxG.keys.pressed.LEFT)
		{
			facing = FlxObject.LEFT;
			velocity.x = -speed;
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			facing = FlxObject.RIGHT;
			velocity.x = speed;
		}
	}

	private function jump():Void
	{
		if (FlxG.keys.justPressed.S)
		{
			currentState = State.PREJUMPING;
		}
	}

	private function crouch():Void
	{
		if (FlxG.keys.pressed.DOWN)
		{
			y += 16;
			height = Reg.playerCrouchedHeight;
			offset.y = 16;
		}
	}

	private function stab():Void
	{
		if (FlxG.keys.justPressed.D)
		{
			Weapon.directionToFace = facing;
			if (facing == FlxObject.LEFT)
				knife.reset(x - knife.width, y + height / 2 - knife.height / 2);
			else
				knife.reset(x + width, y + height / 2 - knife.height / 2);
		}
	}
	
	private function aimUpwards():Void
	{
		if (FlxG.keys.pressed.UP)
		{
			currentState = State.AIMING_UPWARDS;
		}
	}
}