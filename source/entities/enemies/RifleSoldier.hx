package entities.enemies;

import flixel.system.FlxSound;
import weapons.Bullet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;

enum RifleSoldierState
{
	WANDERING;
	DETECTING_PLAYER;
	SHOOTING;
	BACKING_OFF;
	DYING;
}
class RifleSoldier extends Enemy 
{
	private var walkOrigin:Int;
	private var distanceWalked:Int;
	public var rifleBullets(get, null):FlxTypedGroup<Bullet>;
	private var backingOffTime:Float;
	private var hasJustCollided:Bool;
	private var collisionTimer:Float;
	private var footStepSound:FlxSound;
	private var detectPlayerSound:FlxSound;
	private var rifleShotSound:FlxSound;
	private var deathSound:FlxSound;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		// Graphics, Animations & Sound effects
		loadGraphic(AssetPaths.rifleSoldier__png, true, 80, 64, false);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		facing = FlxObject.LEFT;
		animationsSetUp();
		soundEffectsSetUp();
		
		// Attributes Initialization
		width = 40;
		speed = Reg.rifleSoldierSpeed;
		currentState = RifleSoldierState.WANDERING;
		walkOrigin = Std.int(X);
		distanceWalked = 0;
		velocity.x = -speed;
		acceleration.y = Reg.gravity;
		backingOffTime = 0;
		hasJustCollided = false;
		collisionTimer = 0;
		
		// Weapons Creation
		rifleBullets = new FlxTypedGroup<Bullet>();
		FlxG.state.add(rifleBullets);
	}
	
	override public function update(elapsed:Float):Void
	{
		stateMachine(elapsed);		
		checkHitboxOffset();
		checkLeftBoundary();	
		collisionLogic(elapsed);
		
		super.update(elapsed);		
	}
	
	private function stateMachine(elapsed:Float):Void
	{
		switch (currentState)
		{
			case RifleSoldierState.WANDERING:
				animation.play("move");
				footStepSound.play(false, 0, 700);
				footStepSound.setPosition(x + width, y + height);
				
				moveAround();
				
				if (trackedPlayer())
				{
					detectPlayer();
					currentState = RifleSoldierState.DETECTING_PLAYER;
				}
					
			case RifleSoldierState.DETECTING_PLAYER:
				if (animation.name != "detectPlayer")
				{
					animation.play("detectPlayer");
					detectPlayerSound.play();
				}
				
				if (animation.name == "detectPlayer" && animation.finished && velocity.y == 0)
				{
					shoot();
					currentState = RifleSoldierState.SHOOTING;
				}
				
			case RifleSoldierState.SHOOTING:
				if (animation.name != "shoot")
				{
					animation.play("shoot");
					rifleShotSound.play(true, 0, 700);
				}
					
				if (animation.name == "shoot" && animation.finished)
				{
					velocity.x = (x > followingTarget.x) ? speed: -speed;
					facing = (x > followingTarget.x) ? FlxObject.RIGHT: FlxObject.LEFT;
					currentState = RifleSoldierState.BACKING_OFF;
				}
				
			case RifleSoldierState.BACKING_OFF:
				animation.play("move");
				footStepSound.play(false, 0, 700);
				footStepSound.setPosition(x + width, y + height);
				
				backingOffTime += elapsed;
				if (backingOffTime >= Reg.rifleSoldierBackOffTime)
				{
					backingOffTime = 0;
					if (trackedPlayer())
					{
						velocity.x = 0;
						facing = (followingTarget.x < x) ? FlxObject.LEFT: FlxObject.RIGHT;
						shoot();
						currentState = RifleSoldierState.SHOOTING;
					}
					else						
						currentState = RifleSoldierState.WANDERING;
				}
				
			case RifleSoldierState.DYING:
				if (animation.name != "die")
				{
					animation.play("die");
					deathSound.play();
				}
					
				if (animation.name == "die" && animation.finished && !FlxFlicker.isFlickering(this))
					FlxFlicker.flicker(this, 1, 0.05, true, true, endDeath, null);
		}
	}
	
	// Action Methods
	private function moveAround():Void 
	{
		if (velocity.x > 0)
			distanceWalked = Std.int(x) - walkOrigin;
		else
			distanceWalked = walkOrigin - Std.int(x);
			
		if (distanceWalked >= Reg.rifleSoldierWalkDistance)
		{
			distanceWalked = 0;
			walkOrigin = Std.int(x);
			facing = (velocity.x < 0) ? FlxObject.RIGHT: FlxObject.LEFT;
			velocity.x = (velocity.x < 0) ? speed: -speed;
		}
	}
	
	private function detectPlayer():Void 
	{
		velocity.x = 0;
		facing = (followingTarget.x < x) ? FlxObject.LEFT: FlxObject.RIGHT;
		velocity.y = Reg.rifleSoldierJumpSpeed;
	}
	
	private function shoot():Void 
	{
		if (facing == FlxObject.LEFT)
		{
			var bullet = new Bullet(x - 4, y + 10, facing);
			bullet.velocity.y = Reg.random.float( -15, -5);
			rifleBullets.add(bullet);
		}
		else
		{
			var bullet = new Bullet(x + width, y + 10, facing);
			bullet.velocity.y = Reg.random.float( -15, -5);
			rifleBullets.add(bullet);
		}
	}
	
	// Other Methods
	private function trackedPlayer():Bool
	{
		var hasDetectedPlayer:Bool = false;
		
		if (x > followingTarget.x)
		{
			if (x - followingTarget.x + followingTarget.width <= Reg.rifleSoldierTrackDistance)
				hasDetectedPlayer = true;
		}
		else
		{
			if (x < followingTarget.x)
				if (followingTarget.x - x + width <= Reg.rifleSoldierTrackDistance)
					hasDetectedPlayer = true;
		}
		
		return hasDetectedPlayer;
	}
	
	override public function getDamage(?damage:Int):Void
	{
		super.getDamage();
		
		velocity.x = 0;
		Reg.score += Reg.rifleSoldierScore;
		currentState =  RifleSoldierState.DYING;
	}
	
	override public function getType():String
	{
		return "RifleSoldier";
	}
	
	override public function accessWeapon():FlxTypedGroup<Dynamic>
	{
		return rifleBullets;
	}
	
	private function animationsSetUp():Void 
	{
		animation.add("move", [0, 1, 2, 3, 4, 5, 6, 7], 12, true, false, false);
		animation.add("detectPlayer", [8, 9, 8], 6, false, false, false);
		animation.add("shoot", [10, 11, 12], 12, false, false, false);
		animation.add("die", [13, 14, 15], 3, false, false, false);
	}
	
	private	function soundEffectsSetUp():Void
	{
		footStepSound = FlxG.sound.load(AssetPaths.footStep__wav, 0.03);
		footStepSound.proximity(x, y + height, followingTarget, FlxG.width / 10);
		detectPlayerSound = FlxG.sound.load(AssetPaths.enemyDetectingPlayer__wav, 0.5);
		detectPlayerSound.proximity(x, y, followingTarget, FlxG.width);
		rifleShotSound = FlxG.sound.load(AssetPaths.rifleShot__wav, 0.75);
		rifleShotSound.proximity(x, y, followingTarget, FlxG.width);
		deathSound = FlxG.sound.load(AssetPaths.enemyDeath__wav, 0.5);
		deathSound.proximity(x, y, followingTarget, FlxG.width);
	}
	
	private function collisionLogic(time:Float):Void 
	{
		if (isTouching(FlxObject.WALL) && !hasJustCollided)
		{
			distanceWalked = 0;
			walkOrigin = Std.int(x);
			hasJustCollided = true;
			collisionTimer = 0;
			facing = (velocity.x < 0) ? FlxObject.RIGHT: FlxObject.LEFT;
			velocity.x = (velocity.x < 0) ? speed: -speed;
		}
	
		if (hasJustCollided)
		{
			collisionTimer += time;
			if (collisionTimer >= 0.2)
				hasJustCollided = false;
		}
	}
	
	private function checkHitboxOffset():Void 
	{
		if (facing == FlxObject.LEFT)
			offset.x = 30;
		else
			offset.x = 10;
	}
	
	private	function checkLeftBoundary():Void 
	{
		if (x + width < camera.scroll.x)
			kill();
	}
	
	private function endDeath(f:FlxFlicker):Void 
	{
		kill();
	}
	
	// Getters & Setters
	function get_rifleBullets():FlxTypedGroup<Bullet> 
	{
		return rifleBullets;
	}
}