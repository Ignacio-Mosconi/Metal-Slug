package weapons;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.system.FlxSound;

enum GrenadeState
{
	FLYING;
	EXPLODING;
}
class Grenade extends Weapon 
{
	public var currentState(get, null):GrenadeState;
	private var speed:Int;
	private var direction:Int;
	private var timer:Float;
	private var explosion:FlxTypedEmitter<FlxParticle>;
	public var explosionBox(get, null):ExplosionBox;
	private var explosionSound:FlxSound;
	
	public function new(?X:Float=0, ?Y:Float=0, Direction:Int) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.grenade__png, false, 16, 16, false);
		explosionSound = FlxG.sound.load(AssetPaths.explosion__wav);
		
		currentState = GrenadeState.FLYING;
		speed = Reg.grenadeSpeed;
		acceleration.y = Reg.gravity;
		elasticity = 0.5;
		direction = Direction;	
		velocitySetUp();
		timer = 0;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		switch (currentState)
		{
			case GrenadeState.FLYING:
				timer += elapsed;
				slowDown();	
				if (velocity.x == 0)
					angularVelocity = 0;
					
				if (timer >= Reg.grenadeTimer)
				{
					explode();
					explosionSound.play();
					currentState = GrenadeState.EXPLODING;
				}
					
			case GrenadeState.EXPLODING:
				kill();
		}				
	}
	
	private function velocitySetUp():Void 
	{
		velocity.y = -speed;
		if (direction == FlxObject.LEFT)
		{
			velocity.x = -speed;
			angularVelocity = -300;
		}
		else
		{
			velocity.x = speed;
			angularVelocity = 300;
		}
	}
	
	private function explode():Void
	{
		explosion = new FlxTypedEmitter<FlxParticle>();
		explosion.focusOn(this);
		explosion.launchMode = FlxEmitterMode.CIRCLE;
		explosion.makeParticles(2, 2, 0xFFEFD10B, 100);
		explosion.makeParticles(2, 2, 0xFFFE3344, 100);
		explosion.speed.set(200, 400, 500, 700);
		explosion.start(true, 0, 0);
		explosion.lifespan.set(0.25, 0.75);
		FlxG.state.add(explosion);
		
		explosionBox = new ExplosionBox(x + width / 2 - 48, y + height - 96);
		FlxG.state.add(explosionBox);
	}
	
	private function slowDown():Void 
	{
		if (direction == FlxObject.LEFT)
		{
			if (velocity.x + 3 < 0)
				velocity.x += 3;
			else
				velocity.x = 0;
		}
		else
		{
			if (velocity.x - 3 > 0)
				velocity.x -= 3;
			else
				velocity.x = 0;
		}
	}
	
	function get_currentState():GrenadeState 
	{
		return currentState;
	}
	
	function get_explosionBox():ExplosionBox 
	{
		return explosionBox;
	}	
}