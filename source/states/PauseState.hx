package states;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PauseState extends FlxSubState 
{
	private var pause:FlxText;
	private var resumeButton:FlxButton;
	private var quitButton:FlxButton;
	
	public function new(BGColor:FlxColor=0x22000000) 
	{
		super(BGColor);
		
		pause = new FlxText(0, FlxG.height / 4, FlxG.width, "Paused", 24, true);
		pause.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 2, 1);
		pause.alignment = FlxTextAlign.CENTER;
		pause.scrollFactor.set(0, 0);
		add(pause);
		
		resumeButton = new FlxButton(0, 0, "Resume", clickResume);
		resumeButton.scale.set(3 / 2, 3 / 2);
		resumeButton.screenCenter();
		resumeButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav, 1, false, null, false, false, null);
		add(resumeButton);
		
		quitButton = new FlxButton(0, FlxG.height * 3 / 5, "Quit", clickQuit);
		quitButton.scale.set(4 / 3, 4 / 3);
		quitButton.screenCenter(X);
		quitButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(quitButton);
	}
	
	private function clickResume():Void
	{
		FlxG.mouse.visible = false;
		close();
	}
	
	private function clickQuit():Void
	{
		camera.fade(FlxColor.BLACK, 1, false, function()
		{
			Reg.score = 0;
			FlxG.mouse.visible = true;
			FlxG.switchState(new MenuState());
		});
	}
	
}