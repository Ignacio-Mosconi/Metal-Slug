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
}

class Player extends FlxSprite
{
	private var currentState:State;
	private var speed:Int;
	private var jumpSpeed:Int;
	private var knifeAttack:Knife;

	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		loadGraphic(AssetPaths.player__png, true, 64, 64, true);
		pixelPerfectPosition = false;
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("idle", [0, 1, 2], 6, true, false, false);
		animation.add("move", [3, 4, 5, 6, 7, 8, 9, 10], 12, true, false, false);
		animation.add("preJump", [11, 12], 24, false, false, false);
		animation.add("jump", [13], 6, false, false, false);
		animation.add("land", [14], 24, false, false, false);
		animation.add("crouch", [15, 16], 8, false, false, false);
		animation.add("stab", [17, 18, 19], 10, false, false, false);

		currentState = State.IDLE;
		speed = Reg.playerNormalSpeed;
		jumpSpeed = Reg.playerJumpSpeed;
		acceleration.y = Reg.gravity;

		knifeAttack = new Knife();
		knifeAttack.kill();
		FlxG.state.add(knifeAttack);
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

				if (velocity.x != 0)
					currentState = State.MOVING;
				else
				{
					if (knifeAttack.alive)
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
					if (knifeAttack.alive)
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
					if (knifeAttack.alive)
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
				if (animation.name != "crouch")
					animation.play("crouch");

				stab();

				if (!FlxG.keys.pressed.DOWN)
				{
					y -= 16;
					updateHitbox();
					currentState = State.IDLE;
				}
				else if (knifeAttack.alive)
					currentState = State.STABBING;

			case State.STABBING:
				if (animation.name != "stab")
					animation.play("stab");

				if (velocity.y == 0)
					velocity.x = 0;
				knifeAttack.x = (facing == FlxObject.LEFT) ? x - knifeAttack.width: x + width;
				knifeAttack.y = y + height / 2 - knifeAttack.height / 2;

				if (animation.name == "stab" && animation.finished)
				{
					knifeAttack.kill();
					
					if (velocity.y != 0)
						currentState = State.JUMPING;
					else
					{
						if (velocity.x != 0)
							currentState = State.MOVING;
						else
							currentState = State.IDLE;
					}
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
		if (FlxG.keys.justPressed.DOWN)
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
				knifeAttack.reset(x - knifeAttack.width, y + height / 2 - knifeAttack.height / 2);
			else
				knifeAttack.reset(x + width, y + height / 2 - knifeAttack.height / 2);
		}
	}
}