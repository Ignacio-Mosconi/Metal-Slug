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
	private var title:FlxText;
	private var subtitle:FlxText;
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
		title = new FlxText(0, FlxG.height / 4 - 32, 0, "Super Lieutenant 001:", 28, true);
		title.color = 0xFF002700;
		title.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF138735, 2, 1);
		title.screenCenter(X);
		add(title);
		
		subtitle = new FlxText(0, FlxG.height / 4, 0, "The Summer Soldier", 22, true);
		subtitle.color = 0xFF002700;
		subtitle.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF138735, 2, 1);
		subtitle.screenCenter(X);
		add(subtitle);
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