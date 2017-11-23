package entities.enemies;

enum State
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
	private var currentState:State;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.drone__png, true, 32, 32, false);
		animation.add("fly", [0, 1, 2], 3, true, false, false);
		animation.add("explode", [3, 4, 5, 6, 7], 8, false, false, false);
		
		speed = Reg.droneFlyingSpeed;
		amplitude = Reg.random.int(32, 64);
		frequency = Math.PI;
		time = 0;
		originY = Y;
		currentState = State.FLYING;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		stateMachine(elapsed);
	}
	
	private function stateMachine(elapsed:Float):Void 
	{
		switch (currentState)
		{
			case State.FLYING:
				animation.play("fly");
				
				time += elapsed;
				y = amplitude * Math.cos(frequency * time) + originY;
				velocity.x = speed;
				
				if (acceleration.y != 0)
					currentState = State.EXPLODING;
				
			case State.EXPLODING:
				animation.play("explode");
				
				if (animation.name == "explode" && animation.finished)
					destroy();
		}
	}
	
	override public function getDamage():Void
	{
		super.getDamage();
		
		acceleration.y = Reg.gravity;
		Reg.score += Reg.droneScore;
	}
	
	public function getType():String
	{
		return "Drone";
	}
}