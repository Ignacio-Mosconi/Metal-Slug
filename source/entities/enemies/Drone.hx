package entities.enemies;
import flixel.FlxG;
import flixel.system.FlxSound;

enum DroneState
{
	FLYING;
	EXPLODING;
}

class Drone extends Enemy 
{
	private var amplitude:Int;
	private var frequency:Float;
	private var time:Float;
	private var originY:Float;
	private var hasAppeared:Bool;
	private var flyingSound:FlxSound;
	private var explodingSound:FlxSound;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		// Graphics, Animation & Sound Effects
		loadGraphic(AssetPaths.drone__png, true, 32, 32, false);
		animation.add("fly", [0, 1, 2], 12, true, false, false);
		animation.add("explode", [3, 4, 5, 6, 7], 8, false, false, false);
		flyingSound = FlxG.sound.load(AssetPaths.droneFlying__wav, 0.02);
		flyingSound.proximity(x, y, followingTarget, FlxG.width / 10);
		explodingSound = FlxG.sound.load(AssetPaths.droneExploding__wav, 0.9);
		explodingSound.proximity(x, y, followingTarget, FlxG.width);
		
		// Attributes Initialization
		speed = Reg.random.int(-120, -80);
		amplitude = Reg.random.int(32, 64);
		frequency = Math.PI;
		time = 0;
		originY = Y;
		currentState = DroneState.FLYING;
		hasAppeared = false;
	}
	
	override public function update(elapsed:Float)
	{
		if (isOnScreen())
			hasAppeared = true;
			
		if (hasAppeared)
		{
			stateMachine(elapsed);
			if (camera.scroll.x > x + width)
				kill();
		}
		
		super.update(elapsed);
	}
	
	private function stateMachine(elapsed:Float):Void 
	{
		switch (currentState)
		{
			case DroneState.FLYING:
				animation.play("fly");
				flyingSound.play();
				
				time += elapsed;
				y = amplitude * Math.cos(frequency * time) + originY;
				velocity.x = speed;
				
				if (acceleration.y != 0)
					currentState = DroneState.EXPLODING;
				
			case DroneState.EXPLODING:
				if (animation.name != "explode")
				{
					animation.play("explode");
					explodingSound.play();
				}
				
				if (animation.name == "explode" && animation.finished)
					kill();
		}
	}
	// Other Methods
	override public function getDamage(?damage:Int):Void
	{
		super.getDamage();
		
		acceleration.y = Reg.gravity;
		Reg.score += Reg.droneScore;
	}
	
	override public function getType():String
	{
		return "Drone";
	}
}