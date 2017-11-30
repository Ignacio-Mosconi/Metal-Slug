package others;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class CameraWall extends FlxSprite 
{
	private var position:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, Position:Int) 
	{
		super(X, Y);
		
		makeGraphic(1, FlxG.height, 0x00000000, true);
		position = Position;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		x = (position == FlxObject.LEFT) ? camera.scroll.x: camera.scroll.x + FlxG.width - 1;
	}
}