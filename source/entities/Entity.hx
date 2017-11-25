package entities;

import flixel.FlxSprite;

class Entity extends FlxSprite 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		pixelPerfectPosition = false;
	}
	
	public function getType():String
	{
		return "Enitity";
	}
	
}