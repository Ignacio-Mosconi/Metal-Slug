package entities.enemies;

class Drone extends Enemy 
{
	private var amplitude:Int;
	private var frequency:Float;
	private var time:Float;
	private var originY:Float;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.drone__png, true, 32, 32, false);
		animation.add("fly", [0, 1], 6, true, false, false);
		animation.play("fly");
		
		speed = Reg.droneFlyingSpeed;
		amplitude = Reg.random.int(32, 64);
		frequency = Math.PI;
		time = 0;
		originY = Y;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		time += elapsed;
		y = amplitude * Math.cos(frequency * time) + originY;
		velocity.x = speed;
	}	
}