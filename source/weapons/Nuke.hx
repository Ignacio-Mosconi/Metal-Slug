package weapons;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;

class Nuke extends Weapon 
{
	private var explosion:FlxTypedEmitter<FlxParticle>;
	public var explosionBox(get, null):ExplosionBox;
	public var hasJustExploded(get, null):Bool;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.nuke__png, false, 16, 12, false);
		acceleration.y = Reg.gravity;
		angularVelocity = -200;
	}
	
	public function explode():Void
	{
		hasJustExploded = true;
		
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
		
		kill();		
	}
	
	function get_hasJustExploded():Bool
	{
		return hasJustExploded;
	}
	
	function get_explosionBox():ExplosionBox 
	{
		return explosionBox;
	}
}