package entities.player;

import flixel.FlxObject;
import flixel.FlxSprite;

class Weapon extends FlxSprite 
{
	static public var directionToFace(null, set):Int;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		pixelPerfectPosition = false;
		directionToFace = FlxObject.RIGHT;
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		facing = directionToFace;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	override public function reset(X, Y)
	{
		super.reset(X, Y);
		
		facing = directionToFace;
	}
	
	static function set_directionToFace(value:Int):Int 
	{
		return directionToFace = value;
	}
}