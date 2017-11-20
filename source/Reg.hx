package;
import flixel.math.FlxRandom;

class Reg 
{
	// Player
	static public var playerNormalSpeed:Int = 220;
	static public var playerJumpSpeed:Int = -500;
	static public var playerStandingHeight:Int = 64;
	static public var playerCrouchedHeight:Int = 48;
	// Wapons
	static public var pistolBulletSpeed:Int = 440;
	static public var pistolRateOfFire:Float = 0.1;
	static public var pistolMagSize:Int = 7;
	static public var grenadeSpeed:Int = 300;
	// Game
	static public var gravity:Int = 1400;
	static public var random:FlxRandom = new FlxRandom();
	// Enemies
	static public var droneFlyingSpeed:Int = -100;
	
}