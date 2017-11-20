package entities.player;
import flixel.FlxObject;

class Grenade extends Weapon 
{
	private var speed:Int;
	private var direction:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, Direction:Int) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.grenade__png, false, 16, 16, false);
		
		speed = Reg.grenadeSpeed;
		acceleration.y = Reg.gravity;
		direction = Direction;	
		velocitySetUp();
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!isOnScreen())
			destroy();
	}
	
	private function velocitySetUp():Void 
	{
		velocity.y = -speed;
		if (direction == FlxObject.LEFT)
		{
			velocity.x = -speed;
			angularVelocity = -300;
		}
		else
		{
			velocity.x = speed;
			angularVelocity = 300;
		}
	}
}