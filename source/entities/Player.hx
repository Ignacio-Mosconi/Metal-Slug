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
}

class Player extends FlxSprite 
{
	private var currentState:State;
	private var speed:Int;
	private var jumpSpeed:Int;
	
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
		
		currentState = State.IDLE;
		speed = Reg.playerNormalSpeed;
		jumpSpeed = -Reg.playerJumpSpeed;
		acceleration.y = Reg.gravity;
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
				
				if (velocity.y != 0)
					currentState = State.JUMPING;
				else
				{
					if (velocity.x != 0)
						currentState = State.MOVING;
					else
						if (height == Reg.playerCrouchedHeight)
							currentState = State.CROUCHED;
				}
					
			case State.MOVING:
				animation.play("move");
				move();
				jump();
				crouch();
				
				if (velocity.y != 0)
					currentState = State.JUMPING;
				else
					if (velocity.x == 0)
						currentState = State.IDLE;
					
			case State.JUMPING:
				if (animation.name != "jump")
					animation.play("jump");
				
				if (velocity.y == 0)
				{
					if (velocity.x == 0)
						currentState = State.IDLE;
					else
						currentState = State.MOVING;
				}
				
			case State.CROUCHED:
				if (animation.name != "crouch")
					animation.play("crouch");
					
				if (!FlxG.keys.pressed.DOWN)
				{
					height = Reg.playerStandingHeight;
					//offset.y = -32;
					currentState = State.IDLE;
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
			//offset.y = 32;
		}
	}
}