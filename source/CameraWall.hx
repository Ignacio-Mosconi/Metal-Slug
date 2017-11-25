package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class CameraWall extends FlxSprite 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		makeGraphic(1, FlxG.height, 0x00000000, true);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		x = camera.scroll.x;
	}
}