package;
import flixel.math.FlxRandom;

class Reg 
{
	// Player
	static public var playerMaxLives:Int = 3;
	static public var playerNormalSpeed:Int = 220;
	static public var playerJumpSpeed:Int = -500;
	static public var playerStandingHeight:Int = 64;
	static public var playerCrouchedHeight:Int = 48;
	// Wapons
	static public var pistolBulletSpeed:Int = 440;
	static public var pistolRateOfFire:Float = 0.1;
	static public var pistolMagSize:Int = 7;
	static public var grenadeSpeed:Int = 300;
	static public var grenadeTimer:Float = 1.5;
	// Game
	static public var random:FlxRandom = new FlxRandom();
	static public var gravity:Int = 1400;
	static public var score:Int = 0;
	// Enemies
	static public var droneScore:Int = 2;
	static public var rifleSoldierSpeed:Int = 120;
	static public var rifleSoldierScore:Int = 10;
	static public var rifleSoldierWalkDistance:Int = 200;
	static public var rifleSoldierTrackDistance:Int = 300;
	static public var rifleSoldierJumpSpeed:Int = -100;
	static public var rifleSoldierBackOffTime:Float = 1;
	
}