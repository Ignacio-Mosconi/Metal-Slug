package others;

import entities.player.Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private var background:FlxSprite;
	private var backgroundFill:FlxSprite;
	private var lives:FlxText;
	private var livesSprite:FlxSprite;
	private var totalAmmo:FlxText;
	private var ammoSprite:FlxSprite;
	private var grenades:FlxText;
	private var grenadesSprite:FlxSprite;
	private var score:FlxText;
	private var playerMagBar:FlxBar;
	private var playerPowerUpBar:FlxBar;
	
	public function new(player:Player)
	{
		super();
		
		backgroundSetUp();
		livesSetUp();	
		totalAmmoSetUp();
		grenadesSetUp();
		scoreSetUp();
		playerMagBarSetUp(player);
		powerUpBarSetUp(player);

	}
	
	public function updateHUD(Lives:Int, Ammo:Int, Grenades:Int, Score:Int, PowerUp:Bool):Void
	{
		lives.text = Std.string(Lives);
		lives.color = (Lives < 2) ? FlxColor.RED: FlxColor.WHITE;
		
		totalAmmo.text = Std.string(Ammo);
		totalAmmo.color = (Ammo < 14) ? FlxColor.RED: FlxColor.WHITE;
			
		grenades.text = Std.string(Grenades);
		grenades.color = (Grenades < 2) ? FlxColor.RED: FlxColor.WHITE;
				
		score.text = "Score: " + Std.string(Score);
		
		playerPowerUpBar.visible = PowerUp ? true: false;
	}
	
	private function backgroundSetUp():Void 
	{
		background = new FlxSprite(0, 0);
		backgroundFill = new FlxSprite();
		backgroundFill.makeGraphic(FlxG.width - 2, 30, 0xFF113311);
		background.makeGraphic(FlxG.width, 32, FlxColor.WHITE);
		background.stamp(backgroundFill, 1, 1);
		background.scrollFactor.set(0, 0);
		add(background);
	}
	
	private function livesSetUp():Void 
	{
		lives = new FlxText(48, 8, 0, "3", 12, true);
		lives.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		lives.scrollFactor.set(0, 0);
		add(lives);
		
		livesSprite = new FlxSprite(32, 8, AssetPaths.livesHUD__png);
		livesSprite.scrollFactor.set(0, 0);
		add(livesSprite);
	}
	
	private function totalAmmoSetUp():Void 
	{
		totalAmmo = new FlxText(FlxG.width / 2 - 50, 8, 0, "56", 12, true);
		totalAmmo.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		totalAmmo.scrollFactor.set(0, 0);
		add(totalAmmo);
		
		ammoSprite = new FlxSprite(FlxG.width / 2 - 82, 8, AssetPaths.weaponsHUD__png);
		ammoSprite.loadGraphic(AssetPaths.weaponsHUD__png, true, 32, 16);
		ammoSprite.scrollFactor.set(0, 0);
		add(ammoSprite);
	}
	
	private function grenadesSetUp():Void 
	{
		grenades = new FlxText(112, 8, 0, "3", 12, true);
		grenades.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		grenades.scrollFactor.set(0, 0);
		add(grenades);
		
		grenadesSprite = new FlxSprite(96, 8, AssetPaths.grenade__png);
		grenadesSprite.loadGraphic(AssetPaths.grenade__png, true, 16, 16);
		grenadesSprite.scrollFactor.set(0, 0);
		add(grenadesSprite);
	}
	
	private function scoreSetUp():Void 
	{
		score = new FlxText(FlxG.width - 128, 8, 0, "Score: 0", 12, true);
		score.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 1, 1);
		score.scrollFactor.set(0, 0);
		add(score);
	}
	
	private function playerMagBarSetUp(player:Player):Void
	{
		playerMagBar = new FlxBar(FlxG.width / 2 - 18, 10, FlxBarFillDirection.LEFT_TO_RIGHT, 100, 12, player, "magAmmo", 0, Reg.pistolMagSize, true);
		playerMagBar.createFilledBar(0xFF882222, 0xFFDBC21E, true, FlxColor.BLACK);
		playerMagBar.scrollFactor.set(0, 0);
		add(playerMagBar);
	}
	
	private function powerUpBarSetUp(player:entities.player.Player) 
	{
		playerPowerUpBar = new FlxBar(4, FlxG.height / 4, FlxBarFillDirection.BOTTOM_TO_TOP, 12, 100, player, "invincibilityTime", 0, Reg.invincibilityPowerUpTime, true);
		playerPowerUpBar.createFilledBar(0xFF010101, 0xFF124597, true, FlxColor.WHITE);
		playerPowerUpBar.scrollFactor.set(0, 0);
		add(playerPowerUpBar);
	}
}