package entities.enemies;
import entities.player.weapons.Bullet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;

enum RifleSoldierState
{
	WANDERING;
	DETECTING_PLAYER;
	SHOOTING;
	BACKING_OFF;
}
class RifleSoldier extends Enemy 
{
	private var currentState:RifleSoldierState;
	private var walkOrigin:Int;
	private var distanceWalked:Int;
	public var rifleBullets:FlxTypedGroup<Bullet>;
	private var backingOffTime:Float;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.rifleSoldier__png, true, 80, 64, false);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("move", [1, 2, 3, 4, 5, 6, 7, 8], 12, true, false, false);
		speed = Reg.rifleSoldierSpeed;
		currentState = RifleSoldierState.WANDERING;
		walkOrigin = Std.int(X);
		distanceWalked = 0;
		velocity.x = speed;
		acceleration.y = Reg.gravity;
		backingOffTime = 0;
		
		rifleBullets = new FlxTypedGroup<Bullet>();
		FlxG.state.add(rifleBullets);
	}
	
	override public function update(elapsed:Float):Void
	{
		stateMachine(elapsed);
		
		trace(currentState);
		
		super.update(elapsed);		
	}
	
	private function stateMachine(elapsed:Float):Void
	{
		switch (currentState)
		{
			case RifleSoldierState.WANDERING:
				animation.play("move");
				
				moveAround();
				
				if (trackedPlayer())
				{
					detectPlayer();
					currentState = RifleSoldierState.DETECTING_PLAYER;
				}
					
			case RifleSoldierState.DETECTING_PLAYER:
				
				if (velocity.y == 0)
				{
					shoot();
					currentState = RifleSoldierState.SHOOTING;
				}
				
			case RifleSoldierState.SHOOTING:
				
				velocity.x = (x > followingTarget.x) ? speed: -speed;
				facing = (x > followingTarget.x) ? FlxObject.RIGHT: FlxObject.LEFT;
				currentState = RifleSoldierState.BACKING_OFF;
				
			case RifleSoldierState.BACKING_OFF:
				animation.play("move");
				
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
		}
	}
	
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
}