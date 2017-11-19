package entities;
import flixel.FlxObject;

class Grenade extends Weapon 
{
	private var speed:Int;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.grenade__png, false, 8, 8, false);
		
		speed = Reg.grenadeSpeed;
		velocity.y = -speed;
		acceleration.y = Reg.gravity;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (facing == FlxObject.LEFT)
		{
			velocity.x = -speed;
			angularVelocity = -2500;
		}
		else
		{
			velocity.x = speed;
			angularVelocity = 2500;
		}
		trace(angularVelocity);
	}
}