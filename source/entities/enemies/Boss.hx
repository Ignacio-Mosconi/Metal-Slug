package entities.enemies;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import weapons.Nuke;

enum BossState
{
	FLYING;
	EXPLODING;
}
class Boss extends Enemy 
{
	private var hitPoints:Int;
	private var nukes:FlxTypedGroup<Nuke>;
	private var destination:FlxPoint;
	private var amplitude:Int;
	private var frequency:Float;
	private var time:Float;
	private var originY:Float;
	private var hasJustThrownNuke:Bool;
	private var nukeTimer:Float;
	private var hasAppeared:Bool;
	private var hasJustChangedDirection:Bool;
	private var collisionTimer:Float;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.boss__png, true, 128, 64, true);
		animationsSetUp();
		
		currentState = BossState.FLYING;
		hitPoints = Reg.bossHitPoints;
		speed = Reg.bossSpeed;
		amplitude = 32;
		frequency = 2 * Math.PI;
		time = 0;
		originY = Y;
		hasJustThrownNuke = true;
		nukeTimer = Reg.nukeTimer;
		hasAppeared = false;
		hasJustChangedDirection = false;
		collisionTimer = 0;
		nukes = new FlxTypedGroup<Nuke>();
		FlxG.state.add(nukes);
	}
	
	override public function update(elapsed:Float)
	{
		checkAppearance();
			
		if (hasAppeared)
			stateMachine(elapsed);
		
		boundariesCollision(elapsed);
		
		super.update(elapsed);
	}
	
	private function stateMachine(elapsed:Float)
	{
		switch (currentState)
		{
			case BossState.FLYING:
				animation.play("fly");
				
				flyAround(elapsed);
				throwNuke(elapsed);
					
				if (hitPoints <= 0)
					currentState = BossState.EXPLODING;
					
			case BossState.EXPLODING:
				animation.play("explode");
				
				if (animation.name == "explode" && animation.finished)
					kill();
		}
	}
	// Action Methods
	private function flyAround(elapsed:Float):Void 
	{
		time += elapsed;
		y = amplitude * Math.cos(frequency * time) + originY;
	}
	
	private function throwNuke(elapsed:Float):Void 
	{
		if (!hasJustThrownNuke)
		{
			hasJustThrownNuke = true;
			nukeTimer = Reg.nukeTimer;
			var nuke = new Nuke(x + width / 2, y + height);
			nukes.add(nuke);
		}
		else
		{
			nukeTimer -= elapsed;
			if (nukeTimer <= 0)
				hasJustThrownNuke = false;
		}
	}
	
	//Other Methods	
	private function checkAppearance():Void 
	{
		if (camera.scroll.x + FlxG.width == FlxG.worldBounds.right && !hasAppeared)
		{
			hasAppeared = true;
			velocity.x = speed;
		}
	}
	
	private function boundariesCollision(elapsed:Float):Void 
	{
		if (!hasJustChangedDirection && (x + width >= camera.scroll.x + FlxG.width || x <= camera.scroll.x))
		{
			hasJustChangedDirection = true;
			collisionTimer = 0;
			velocity.x = (velocity.x < 0 )? speed: -speed;
		}
		else
			if (hasJustChangedDirection)
			{
				collisionTimer += elapsed;
				if (collisionTimer >= 0.5)
					hasJustChangedDirection = false;
			}
	}
	
	private function animationsSetUp():Void 
	{
		animation.add("fly", [0, 1], 24, true, false, false);
		animation.add("getHit", [2], 30, false, false, false);
		animation.add("explode", [3, 4, 5, 6, 7], 12, false, false, false);
	}
	
	override public function getDamage(?damage:Int)
	{
		animation.play("getHit");
		hitPoints -= (damage != null) ? damage: 1;
		if (hitPoints <= 0)
		{
			super.getDamage();
			Reg.score += Reg.bossScore;
		}
	}
	
	override public function getType():String
	{
		return "Boss";
	}
	
	override public function accessWeapon():FlxTypedGroup<Dynamic>
	{
		return nukes;
	}
}