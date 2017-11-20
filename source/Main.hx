package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.PlayState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(480, 336, PlayState, 1, 60, 60, false, false));
	}
}