package entities;
import flixel.FlxObject;

class Bullet extends Weapon 
{
	private var direction:Int;
	private var speed:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, Direction:Int) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.bullet__png, true, 4, 4, false);
		direction = Direction;
		speed = (direction == FlxObject.LEFT) ? -Reg.pistolBulletSpeed: Reg.pistolBulletSpeed;
		velocity.x = speed;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!isOnScreen())
			destroy();	
	}
}