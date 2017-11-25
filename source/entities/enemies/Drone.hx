package entities.enemies;

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
	private var currentState:DroneState;
	private var hasAppeared:Bool;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.drone__png, true, 32, 32, false);
		animation.add("fly", [0, 1, 2], 12, true, false, false);
		animation.add("explode", [3, 4, 5, 6, 7], 8, false, false, false);
		
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
			if (!isOnScreen())
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
				
				time += elapsed;
				y = amplitude * Math.cos(frequency * time) + originY;
				velocity.x = speed;
				
				if (acceleration.y != 0)
					currentState = DroneState.EXPLODING;
				
			case DroneState.EXPLODING:
				animation.play("explode");
				
				if (animation.name == "explode" && animation.finished)
					kill();
		}
	}
	
	override public function getDamage():Void
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