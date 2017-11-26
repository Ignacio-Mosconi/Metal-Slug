package states;

import entities.player.Player;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class DeathState extends FlxSubState 
{
	private var death:FlxText;
	private var gameOver:FlxText;
	private var instructions:FlxText;

	public function new(BGColor:FlxColor= 0x22000000)
	{
		super(BGColor);

		gameOverSetUp();
		instructionsSetUp();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			Reg.score = 0;
			Player.setLives(3);
			FlxG.mouse.visible = true;
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(new MenuState()); 
			});
		}
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
	
	private function instructionsSetUp():Void
	{
		instructions = new FlxText(0, FlxG.height / 2, FlxG.width, "Press ESC to go to the main menu", 12, true);
		instructions.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		instructions.alignment = FlxTextAlign.CENTER;
		instructions.scrollFactor.set(0, 0);
		add(instructions);
	}
}