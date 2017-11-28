package states;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	private var background:FlxBackdrop;
	private var title:FlxText;
	private var playButton:FlxButton;
	private var exitButton:FlxButton;

	override public function create():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, true, null, false);

		super.create();

		titleSetUp();
		buttonsSetUp();
	}

	private function titleSetUp():Void 
	{
		title = new FlxText(0, FlxG.height / 4, 0, "Metal Slug", 28, true);
		title.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF660000, 2, 1);
		title.screenCenter(X);
		add(title);
	}
	
	private function buttonsSetUp():Void 
	{
		playButton = new FlxButton(0, 0, "Play", clickPlay);
		playButton.scale.set(3 / 2, 3 / 2);
		playButton.screenCenter();
		add(playButton);
	
		exitButton = new FlxButton(0, FlxG.height * 3 / 5, "Exit", clickExit);
		exitButton.scale.set(4 / 3, 4 / 3);
		exitButton.screenCenter(X);
		add(exitButton);
	}
	
	private function clickPlay():Void
	{
		FlxG.mouse.visible = false;
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
		{
			FlxG.switchState(new PlayState());
		});
	}

	private function clickExit():Void
	{
		System.exit(0);
	}
}