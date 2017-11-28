package entities.enemies;

import flixel.FlxG;
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
	
	public function new(?X, ?Y, enemyGroup) 
	{
		super(X, Y);
		
		currentState = TruckState.PARKED;
		hitPoints = Reg.
		speed = Reg.truckSpeed;
		enemiesSpawned = enemyGroup;
		hasJustSpawnedEnemy = false;
		spawnTimer = 0;
	}
	
	override public function update(elapsed:Float)
	{
		stateMachine(elapsed);
		
		super.update(elapsed);
	}
	
	private function stateMachine(elapsed:Float):Void
	{
		switch (currentState)
		{
			case TruckState.PARKED:
				if (camera.scroll.x + 2 * FlxG.width > x)
				{
					velocity.x = speed;
					currentState = TruckState.MOVING;
				}
			case TruckState.MOVING:
				if (camera.scroll.x + FlxG.width / 2 >= x)
				{
					velocity.x = 0;
					currentState = TruckState.SPAWNING_UNITS;
				}
			case TruckState.SPAWNING_UNITS:
				spawnEnemy(elapsed);
				if (hitPoints <= 0)
					currentState = TruckState.EXPLODING;
			case TruckState.EXPLODING:
				
		}
	}
	
	private function spawnEnemy(time:Float):Void 
	{
		if (!hasJustSpawnedEnemy)
		{
			var soldier = new RifleSoldier(x + width, y);
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
	
	override public function getDamage():Void
	{
		hitPoints--;
	}
}