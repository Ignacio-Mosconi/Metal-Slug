package states;

import entities.player.Player;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class DeathState extends FlxSubState 
{
	private var gameOver:FlxText;
	private var retryButton:FlxButton;
	private var quitButton:FlxButton;

	public function new(BGColor:FlxColor= 0x22000000)
	{
		super(BGColor);

		Reg.score = 0;
		gameOverSetUp();
		buttonsSetUp();
	}

	private function gameOverSetUp():Void
	{
		gameOver = new FlxText(0, FlxG.height / 4, FlxG.width, "Game Over", 24, true);
		gameOver.color = FlxColor.RED;
		gameOver.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.WHITE, 1, 1);
		gameOver.alignment = FlxTextAlign.CENTER;
		gameOver.scrollFactor.set(0, 0);
		add(gameOver);
	}
	
	private function buttonsSetUp():Void
	{
		retryButton = new FlxButton(0, 0, "Retry", clickRetry);
		retryButton.scale.set(3 / 2, 3 / 2);
		retryButton.screenCenter();
		retryButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(retryButton);
	
		quitButton = new FlxButton(0, FlxG.height * 3 / 5, "Quit", clickQuit);
		quitButton.scale.set(4 / 3, 4 / 3);
		quitButton.screenCenter(X);
		quitButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(quitButton);
	}
	
	private function clickRetry():Void
	{
		camera.fade(FlxColor.BLACK, 0.5, false, function()
		{
			FlxG.mouse.visible = false;
			FlxG.switchState(new PlayState());
		});
	}
	
	private function clickQuit():Void
	{
		camera.fade(FlxColor.BLACK, 1, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}
}