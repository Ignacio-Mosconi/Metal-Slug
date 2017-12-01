package entities.enemies;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;

enum TruckState
{
	PARKED;
	MOVING;
	SPAWNING_UNITS;
	CHARGING;
	EXPLODING;
}
class Truck extends Enemy 
{
	private var hitPoints:Int;
	private var enemiesSpawned:FlxTypedGroup<Enemy>;
	private var hasJustSpawnedEnemy:Bool;
	private var spawnTimer:Float;
	private var explosion:FlxTypedEmitter<FlxParticle>;
	private var unitsSpawned:Int;
	private var truckMovingSound:FlxSound;
	private var truckExplodingSound:FlxSound;
	
	public function new(?X, ?Y, enemies:FlxTypedGroup<Enemy>) 
	{
		super(X, Y);
		
		// Graphics, Animations & Sound effects
		loadGraphic(AssetPaths.truck__png, true, 160, 96, false);
		animationsSetUp();
		soundEffectsSetUp();
		
		// Attributes Initialization
		currentState = TruckState.PARKED;
		hitPoints = Reg.truckHitPoints;
		speed = Reg.truckSpeed;
		acceleration.y = Reg.gravity;
		hasJustSpawnedEnemy = false;
		spawnTimer = 0;
		enemiesSpawned = enemies;
		unitsSpawned = 0;
	}
	
	override public function update(elapsed:Float)
	{
		checkLeftBoundary();
		stateMachine(elapsed);
		
		super.update(elapsed);
	}
	
	private function stateMachine(elapsed:Float):Void
	{
		switch (currentState)
		{
			case TruckState.PARKED:
				animation.play("parked");
				
				if (camera.scroll.x + 3/2 * FlxG.width > x)
				{
					velocity.x = speed;
					currentState = TruckState.MOVING;
				}
				
			case TruckState.MOVING:
				animation.play("move");
				truckMovingSound.play();
				
				if (camera.scroll.x + FlxG.width / 2 >= x)
				{
					velocity.x = 0;
					currentState = TruckState.SPAWNING_UNITS;
				}
				
			case TruckState.SPAWNING_UNITS:
				animation.play("parked");
				truckMovingSound.stop();
				
				velocity.x = 0;
				spawnEnemy(elapsed);
				
				if (hitPoints <= 0)
					currentState = TruckState.EXPLODING;
				else
					if (unitsSpawned == Reg.truckSpawnLimit)
					{
						velocity.x = speed;
						currentState = TruckState.CHARGING;
					}
				
			case TruckState.CHARGING:
				animation.play("move");
				truckMovingSound.play();
				
				if (x + width < camera.scroll.x)
					kill();
					
				if (hitPoints <= 0)
					currentState = TruckState.EXPLODING;
					
			case TruckState.EXPLODING:
				if (animation.name != "explode")
				{
					animation.play("explode");
					truckExplodingSound.play();
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
	// Action Methods
	private function spawnEnemy(time:Float):Void 
	{
		if (!hasJustSpawnedEnemy)
		{
			var soldier = new RifleSoldier(x + width, y);
			soldier.followingTarget = followingTarget;
			enemiesSpawned.add(soldier);
			hasJustSpawnedEnemy = true;
			spawnTimer = 0;
			unitsSpawned++;
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
	// Other Methods
	private function animationsSetUp():Void 
	{
		animation.add("parked", [0], 30, false, false, false);
		animation.add("move", [0, 1], 12, true, false, false);
		animation.add("getHit", [2], 30, false, false, false);
		animation.add("explode", [3, 4, 5, 6, 7], 12, false, false, false);
	}
	
	private function soundEffectsSetUp():Void 
	{
		truckMovingSound = FlxG.sound.load(AssetPaths.truckEngine__wav, 0.9);
		truckMovingSound.proximity(x, y, followingTarget, FlxG.width);
		truckExplodingSound = FlxG.sound.load(AssetPaths.explosion__wav);
		truckExplodingSound.proximity(x, y, followingTarget, FlxG.width);
	}
	
	private function checkLeftBoundary():Void 
	{
		if (x < camera.scroll.x - 160)
			kill();
	}
	
	override public function getDamage(?damage:Int):Void
	{
		animation.play("getHit");
		hitPoints -= (damage != null) ? damage: 1;
		if (hitPoints <= 0)
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