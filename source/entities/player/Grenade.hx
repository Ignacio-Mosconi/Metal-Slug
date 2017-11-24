package entities.player;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxColor;

enum GrenadeState
{
	FLYING;
	EXPLODING;
}
class Grenade extends Weapon 
{
	private var currentState:GrenadeState;
	private var speed:Int;
	private var direction:Int;
	private var timer:Float;
	private var explosion:FlxTypedEmitter<FlxParticle>;
	private var explosionBox:FlxSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, Direction:Int) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.grenade__png, false, 16, 16, false);
		
		currentState = GrenadeState.FLYING;
		speed = Reg.grenadeSpeed;
		acceleration.y = Reg.gravity;
		elasticity = 0.5;
		direction = Direction;	
		velocitySetUp();
		timer = 0;
		
		explosionBox = new FlxSprite();
		explosionBox.makeGraphic(96, 96, 0x0000000, false);
		explosionBox.kill();
		FlxG.state.add(explosionBox);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		trace(velocity.x);
		
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
					currentState = GrenadeState.EXPLODING;
				}
					
			case GrenadeState.EXPLODING:
				explosionBox.destroy();
				destroy();
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
		explosion.makeParticles(3, 3, FlxColor.YELLOW, 100);
		explosion.makeParticles(3, 3, FlxColor.RED, 100);
		explosion.start(true, 0.1, 0);
		FlxG.state.add(explosion);
		
		explosionBox.reset(x + width / 2 - explosionBox.width / 2, y + height - explosionBox.height);
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
}