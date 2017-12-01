package weapons;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;

enum NukeState
{
	FLYING;
	EXPLODING;
}
class Nuke extends Weapon 
{
	public var currentState(get, null):NukeState;
	private var explosion:FlxTypedEmitter<FlxParticle>;
	public var explosionBox(get, null):ExplosionBox;
	public var hasJustCollided(default, set):Bool;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.nuke__png, false, 16, 12, false);
		currentState = NukeState.FLYING;
		acceleration.y = Reg.gravity;
		angularVelocity = -200;
		hasJustCollided = false;
	}
	
	override public function update(elapsed:Float)
	{
		stateMachine();
		
		super.update(elapsed);
	}
	
	private function stateMachine()
	{
		switch (currentState)
		{
			case NukeState.FLYING:
				if (hasJustCollided)
				{
					explode();
					currentState = NukeState.EXPLODING;
				}
			case NukeState.EXPLODING:
				kill();
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
		
		explosionBox = new ExplosionBox(x + width / 2 - 96 / 2, y + height - 96);
		FlxG.state.add(explosionBox);
	}
	
	function get_explosionBox():ExplosionBox 
	{
		return explosionBox;
	}
	
	function get_currentState():NukeState 
	{
		return currentState;
	}
	
	function set_hasJustCollided(value:Bool):Bool 
	{
		return hasJustCollided = value;
	}
	
}