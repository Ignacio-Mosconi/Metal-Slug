package states;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	private var title:FlxSprite;
	private var playButton:FlxButton;
	private var exitButton:FlxButton;
	private var background:FlxSprite;

	override public function create():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, true, null, false);
		
		super.create();

		background = new FlxSprite(0, 0, AssetPaths.skyBackdrop__png);
		add(background);
		titleSetUp();
		buttonsSetUp();
	}

	private function titleSetUp():Void 
	{		
		title = new FlxSprite(0, FlxG.height / 4 - 60, AssetPaths.title__png);
		title.screenCenter(X);
		add(title);
	}
	
	private function buttonsSetUp():Void 
	{
		playButton = new FlxButton(0, 0, "Play", clickPlay);
		playButton.scale.set(3 / 2, 3 / 2);
		playButton.screenCenter();
		playButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(playButton);
	
		exitButton = new FlxButton(0, FlxG.height * 3 / 5, "Exit", clickExit);
		exitButton.scale.set(4 / 3, 4 / 3);
		exitButton.screenCenter(X);
		add(exitButton);
	}
	
	private function clickPlay():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
		{
			FlxG.mouse.visible = false;
			FlxG.switchState(new PlayState());
		});
	}

	private function clickExit():Void
	{
		System.exit(0);
	}
}