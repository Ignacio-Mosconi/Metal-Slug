package entities;

import flixel.FlxObject;
import flixel.FlxSprite;

class Weapon extends FlxSprite 
{
	static public var directionToFace(null, set):Int;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		directionToFace = FlxObject.RIGHT;
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (facing != directionToFace)
			facing = directionToFace;
	}
	
	static function set_directionToFace(value:Int):Int 
	{
		return directionToFace = value;
	}
	
}