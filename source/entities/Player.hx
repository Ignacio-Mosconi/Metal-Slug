package entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

enum State
{
	IDLE;
	MOVING;
	JUMPING;
	CROUCHED;
	STABBING;
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
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("idle", [0, 1], 6, true, false, false);
		animation.add("move", [2, 3, 4, 5, 6, 7, 8, 9], 12, true, false, false);
		animation.add("jump", [0, 1], 6, false, false, false);
		animation.add("crouch", [0, 1], 6, false, false, false);
		animation.add("stab", [0, 1], 6, false, false, false);
		
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
				
				if (velocity.y != 0)
					currentState = State.JUMPING;
				else
				{
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
				}
					
			case State.MOVING:
				animation.play("move");
				move();
				jump();
				stab();
				
				if (velocity.y != 0)
					currentState = State.JUMPING;
				else
				{
					if (velocity.x == 0)
						currentState = State.IDLE;
					else
						if (knife.alive)
							currentState = State.STABBING;
				}
					
			case State.JUMPING:
				if (animation.name != "jump")
					animation.play("jump");
					
				stab();
				
				if (velocity.y == 0)
				{
					if (velocity.x != 0)
						currentState = State.MOVING;
					else
						currentState = State.IDLE;
				}
				else
					if (knife.alive)
						currentState = State.STABBING;
				
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
				else
					if (knife.alive)
						currentState = State.STABBING;
				
			case State.STABBING:
				if (animation.name != "stab")
					animation.play("stab");
				
				if (velocity.y == 0)
					velocity.x = 0;
				knife.x = (facing == FlxObject.LEFT) ? x - knife.width: x + width;
				knife.y = y + height / 2 - knife.height / 2;
				
				if (animation.name == "stab" && animation.finished)
				{
					knife.kill();
					
					if (velocity.y != 0)
						currentState == State.JUMPING;
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
			velocity.y = jumpSpeed;
	}
	
	private function crouch():Void
	{
		if (FlxG.keys.justPressed.DOWN)
		{		
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
}