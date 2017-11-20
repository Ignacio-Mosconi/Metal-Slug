package entities.enemies;

import flixel.FlxSprite;

class Enemy extends FlxSprite
{
	private var speed:Int;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		pixelPerfectPosition = false;
	}
	
	public function getDamage():Void
	{
		destroy();
	}
}