package entities.weapons;

import flixel.FlxSprite;

class ExplosionBox extends FlxSprite 
{	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.explosionBox__png, true, 96, 96, false);
		animation.add("explode", [0, 1, 2, 3, 4, 5], 24, false, false, false);
		animation.play("explode");
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
				
		if (animation.name == "explode" && animation.finished)
			destroy();
	}
}