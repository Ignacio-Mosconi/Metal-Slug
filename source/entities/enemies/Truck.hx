package entities.enemies;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;

enum TruckState
{
	PARKED;
	MOVING;
	SPAWNING_UNITS;
	EXPLODING;
}
class Truck extends Enemy 
{
	private var currentState:TruckState;
	private var hitPoints:Int;
	private var enemiesSpawned:FlxTypedGroup<Enemy>;
	private var hasJustSpawnedEnemy:Bool;
	private var spawnTimer:Float;
	private var explosion:FlxTypedEmitter<FlxParticle>;
	
	public function new(?X, ?Y, enemies:FlxTypedGroup<Enemy>) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.truck__png, true, 160, 96, false);
		animation.add("parked", [0], 30, false, false, false);
		animation.add("move", [0, 1], 12, true, false, false);
		animation.add("getHit", [2], 30, false, false, false);
		animation.add("explode", [3, 4, 5, 6, 7], 12, false, false, false);
		currentState = TruckState.PARKED;
		hitPoints = Reg.truckHitPoints;
		speed = Reg.truckSpeed;
		acceleration.y = Reg.gravity;
		hasJustSpawnedEnemy = false;
		spawnTimer = 0;
		enemiesSpawned = enemies;
	}
	
	override public function update(elapsed:Float)
	{
		stateMachine(elapsed);
		trace(currentState);
		trace(spawnTimer);
		trace(hasJustSpawnedEnemy);
		
		super.update(elapsed);
	}
	
	private function stateMachine(elapsed:Float):Void
	{
		switch (currentState)
		{
			case TruckState.PARKED:
				animation.play("parked");
				
				if (camera.scroll.x + 2 * FlxG.width > x)
				{
					velocity.x = speed;
					currentState = TruckState.MOVING;
				}
				
			case TruckState.MOVING:
				animation.play("move");
				
				if (camera.scroll.x + FlxG.width / 2 >= x)
				{
					velocity.x = 0;
					currentState = TruckState.SPAWNING_UNITS;
				}
				
			case TruckState.SPAWNING_UNITS:
				animation.play("parked");
				
				velocity.x = 0;
				spawnEnemy(elapsed);
				
				if (hitPoints <= 0)
					currentState = TruckState.EXPLODING;
				
			case TruckState.EXPLODING:
				if (animation.name != "explode")
				{
					animation.play("explode");
					velocity.y = 100;
				}
				
				if (animation.name == "explode" && animation.curAnim.curFrame == 2)
				{
					velocity.y = 0;
					explode();
				}
				if (animation.name == "explode" && animation.finished)
					kill();	
		}
	}
	
	private function spawnEnemy(time:Float):Void 
	{
		if (!hasJustSpawnedEnemy && spawnTimer >= Reg.truckEnemySpawnTime)
		{
			var soldier = new RifleSoldier(x + width, y);
			soldier.followingTarget = followingTarget;
			enemiesSpawned.add(soldier);
			hasJustSpawnedEnemy = true;
			spawnTimer = 0;
		}
		else
		{
			spawnTimer += time;
			if (spawnTimer >= Reg.truckEnemySpawnTime)
				hasJustSpawnedEnemy = false;
		}
	}
	
	private function explode():Void
	{
		explosion = new FlxTypedEmitter<FlxParticle>();
		explosion.focusOn(this);
		explosion.launchMode = FlxEmitterMode.CIRCLE;
		explosion.makeParticles(3, 3, 0xFFEFD10B, 100);
		explosion.makeParticles(3, 3, 0xFFFE3344, 100);
		explosion.speed.set(300, 500, 600, 800);
		explosion.start(true, 0, 0);
		explosion.lifespan.set(0.4, 0.9);
		FlxG.state.add(explosion);
	}
	
	override public function getDamage():Void
	{
		animation.play("getHit");
		hitPoints--;
		if (hitPoints == 0)
		{
			super.getDamage();
			Reg.score += Reg.truckScore;
		}
	}
	
	override public function getType():String
	{
		return "Truck";
	}
}