package entities.enemies;

import flixel.FlxSprite;

class Enemy extends FlxSprite
{

	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		pixelPerfectPosition = false;
	}
	
}