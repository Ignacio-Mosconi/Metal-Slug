package entities.enemies;
import flixel.FlxObject;

enum RifleSoldierState
{
	WANDERING;
	SHOOTING;
}
class RifleSoldier extends Enemy 
{
	private var currentState:RifleSoldierState;
	private var walkOrigin:Int;
	private var distanceWalked:Int;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		makeGraphic(64, 64, 0xFFFFFFFF);
		speed = Reg.rifleSoldierSpeed;
		currentState = RifleSoldierState.WANDERING;
		walkOrigin = Std.int(X);
		distanceWalked = 0;
		velocity.x = speed;		
	}
	
	override public function update(elapsed:Float):Void
	{
		stateMachine();
		
		super.update(elapsed);		
	}
	
	private function stateMachine():Void
	{
		switch (currentState)
		{
			case RifleSoldierState.WANDERING:
				moveAround();
				
			case RifleSoldierState.
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
			velocity.x = (velocity.x < 0) ? speed: -speed;
		}
	}
	
	private function getType():String
	{
		return "RifleSoldier";
	}
}