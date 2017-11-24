package entities.player.weapons;

import flixel.FlxSprite;

class ExplosionBox extends FlxSprite 
{
	private var timer:Float;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		makeGraphic(96, 96, 0x0000000, false);
		timer = 0;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		timer += elapsed;
		if (timer >= 1.5)
			destroy();
	}
	
	override public function reset(X, Y):Void
	{
		super.reset(X, Y);
		
		timer = 0;
	}
}