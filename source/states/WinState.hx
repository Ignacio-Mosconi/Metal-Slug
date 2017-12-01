package states;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class WinState extends FlxSubState 
{
	private var levelComplete:FlxText;
	private var score:FlxText;
	private var highestScore:FlxText;
	private var quitButton:FlxButton;

	public function new(BGColor:FlxColor= 0x22000000)
	{
		super(BGColor);
		
		levelCompleteSetUp();
		scoringSetUp();
		buttonsSetUp();
	}

	private function levelCompleteSetUp():Void
	{
		levelComplete = new FlxText(0, FlxG.height / 4, FlxG.width, "Level Complete", 24, true);
		levelComplete.color = FlxColor.GREEN;
		levelComplete.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.WHITE, 1, 1);
		levelComplete.alignment = FlxTextAlign.CENTER;
		levelComplete.scrollFactor.set(0, 0);
		add(levelComplete);
	}
	
	private function scoringSetUp():Void
	{
		if (Reg.score > Reg.highestScore)
			Reg.highestScore = Reg.score;
		
		score = new FlxText(0, FlxG.height / 4 + 48, FlxG.width, "You Scored " + Reg.score + " Points.", 12, true);
		score.color = FlxColor.WHITE;
		score.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		score.alignment = FlxTextAlign.CENTER;
		score.scrollFactor.set(0, 0);
		add(score);
		
		highestScore = new FlxText(0, FlxG.height / 4 + 64, FlxG.width, "Highest Score: " + Reg.highestScore + " points.", 12, true);
		highestScore.color = FlxColor.WHITE;
		highestScore.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		highestScore.alignment = FlxTextAlign.CENTER;
		highestScore.scrollFactor.set(0, 0);
		add(highestScore);
	}
	
	private function buttonsSetUp():Void
	{	
		quitButton = new FlxButton(0, FlxG.height * 3 / 5, "Quit", clickQuit);
		quitButton.scale.set(4 / 3, 4 / 3);
		quitButton.screenCenter(X);
		quitButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(quitButton);
	}
	
	private function clickQuit():Void
	{
		Reg.score = 0;
		camera.fade(FlxColor.BLACK, 1, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}
}