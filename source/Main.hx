package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.MenuState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(480, 336, MenuState, 1, 60, 60, false, true));
	}
}