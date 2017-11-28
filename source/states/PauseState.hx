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
	private var exitButton:FlxButton;
	
	public function new(BGColor:FlxColor=0x22000000) 
	{
		super(BGColor);
		
		pause = new FlxText(0, FlxG.height / 4, FlxG.width, "Paused", 24, true);
		pause.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF660000, 2, 1);
		pause.alignment = FlxTextAlign.CENTER;
		pause.scrollFactor.set(0, 0);
		add(pause);
		
		resumeButton = new FlxButton(0, 0, "Resume", clickResume);
		resumeButton.scale.set(3 / 2, 3 / 2);
		resumeButton.screenCenter();
		add(resumeButton);
		
		exitButton = new FlxButton(0, FlxG.height * 3 / 5, "Quit", clickQuit);
		exitButton.scale.set(4 / 3, 4 / 3);
		exitButton.screenCenter(X);
		add(exitButton);
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
			FlxG.switchState(new MenuState());
		});
	}
	
}