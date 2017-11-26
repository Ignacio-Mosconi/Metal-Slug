package states;

import others.CameraWall;
import others.HUD;
import entities.enemies.Drone;
import entities.enemies.Enemy;
import entities.enemies.RifleSoldier;
import entities.weapons.Bullet;
import entities.weapons.ExplosionBox;
import entities.weapons.Grenade;
import entities.weapons.Grenade.GrenadeState;
import entities.weapons.Knife;
import entities.player.Player;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var player:Player;
	private var loader:FlxOgmoLoader;
	private var tilemap:FlxTilemap;
	private var cameraWalls:FlxTypedGroup<others.CameraWall>;
	private var entities:FlxGroup;
	private var enemies:FlxTypedGroup<Enemy>;
	private var hud:others.HUD;
	
	override public function create():Void
	{
		super.create();
		
		// Attributes Initialization
		entities = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();
		
		// Tilemap & Enitities
		loader = new FlxOgmoLoader(AssetPaths.Level__oel);
		tilemapSetUp();
		loader.loadEntities(entityCreator, "Entities");
		
		// Game Set Up
		initialSetUp();
		cameraSetUp();
		hudSetUp();
		
		// Enemies
		entities.add(enemies);
		add(enemies);
		enemiesFollowingTargetSetUp();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Miscellaneus
		garbageCollector();
		cameraHandling();
		
		// Collisions
		FlxG.collide(player, cameraWalls);
		FlxG.overlap(entities, tilemap, entityTileMapCollision);
		FlxG.overlap(player, enemies, playerEnemyCollision);
		FlxG.overlap(player.pistolBullets, enemies, bulletEnemyCollision);
		FlxG.overlap(player.knife, enemies, knifeEnemyCollision);
		FlxG.collide(player.grenades, tilemap);
		for (grenade in player.grenades)
			if (grenade.currentState == GrenadeState.EXPLODING)
				FlxG.overlap(grenade.explosionBox, enemies, grenadeEnemyCollision);
		for (enemy in enemies)
			if (enemy.getType() == "RifleSoldier")
				FlxG.overlap(enemy.accessWeapon(), player, enemyBulletPlayerCollision);
		
		// HUD Info
		hud.updateHUD(Player.lives, player.totalAmmo, player.grenadesAmmo, Reg.score);
		
		// Substates Checking
		checkLoseCondition();
	}
	
	// Set Up Methods
	private function tilemapSetUp():Void 
	{
		tilemap = loader.loadTilemap(AssetPaths.tileset__png, 32, 32, "Tiles");
		tilemap.setTileProperties(0, FlxObject.NONE);
		for (i in 1...4)
			tilemap.setTileProperties(i, FlxObject.ANY);
		for (i in 4...19)
			tilemap.setTileProperties(i, FlxObject.NONE);
		for (i in 19...22)
			tilemap.setTileProperties(i, FlxObject.UP);
		for (i in 22...26)
			tilemap.setTileProperties(i, FlxObject.NONE);
		add(tilemap);
	}
	
	private function entityCreator(entityName:String, entityData:Xml)
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		
		switch (entityName)
		{
			case "Player":
				player = new Player(x, y);
				entities.add(player);
				add(player);
			case "Drone":
				var drone = new Drone(x, y);
				enemies.add(drone);
			case "RifleSoldier":
				var rifleSoldier = new RifleSoldier(x, y);
				enemies.add(rifleSoldier);
		}
	}
	
	private function initialSetUp():Void 
	{
		camera.fade(FlxColor.BLACK, 0.5, true, false);
		FlxG.worldBounds.set(0, 0, loader.width, loader.height);
		FlxG.mouse.visible = false;
	}
	
	private function cameraSetUp():Void 
	{
		camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
		camera.followLerp = 0.5;
		camera.targetOffset.set(96, -64);
		camera.setScrollBounds(0, loader.width, 0, loader.height);
		camera.bgColor = 0xFF224466;
		camera.pixelPerfectRender = false;
		cameraWalls = new FlxTypedGroup<others.CameraWall>();
		var leftWall = new others.CameraWall(0, 0, FlxObject.LEFT);
		var rightWall = new others.CameraWall(0, 0, FlxObject.RIGHT);
		cameraWalls.add(leftWall);
		cameraWalls.add(rightWall);
		add(cameraWalls);
	}
	
	private function hudSetUp():Void 
	{
		hud = new others.HUD(player);
		add(hud);
	}
	
	private function enemiesFollowingTargetSetUp():Void 
	{
		for (enemy in enemies)
			if (enemy.getType() != "Drone")
				enemy.setFollowingTarget(player);
	}
	
	// Collision Methods	
	private function entityTileMapCollision(e:Dynamic, t:FlxTilemap):Void 
	{
		if (e.getType() != "Drone")
		{
			FlxObject.separate(e, t);
		}
	}
	
	private function playerEnemyCollision(p:Player, e:Enemy):Void 
	{
		if (!p.hasJustBeenHit && !e.isGettingDamage)
		{
			FlxObject.separate(p, e);
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			p.getHit();
		}
	}
	
	private function bulletEnemyCollision(b:Bullet, e:Enemy):Void
	{
		if (!e.isGettingDamage)
		{
			e.getDamage();
			player.pistolBullets.remove(b);
		}
	}
	
	private function knifeEnemyCollision(k:Knife, e:Enemy):Void
	{
		if (!e.isGettingDamage)
			e.getDamage();
	}
	
	private function grenadeEnemyCollision(eB:ExplosionBox, e:Enemy):Void
	{
		if (!e.isGettingDamage)
			e.getDamage();
	}
	
	private function enemyBulletPlayerCollision(b:Bullet, p:Player):Void 
	{
		if (!p.hasJustBeenHit)
		{
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			p.getHit();
		}
	}
	
	// Other Methods
	private function garbageCollector():Void
	{
		for (enemy in enemies)
			if (!enemy.alive)
			{
				enemy.destroy();
				enemies.remove(enemy, true);
			}
	}
	
	private function cameraHandling():Void 
	{
		if (camera.scroll.x < loader.width - FlxG.width)
			camera.setScrollBoundsRect(camera.scroll.x, 0, loader.width, loader.height, false);
		else
			camera.setScrollBoundsRect(loader.width - FlxG.width, 0, loader.width, loader.height);
	}
	
	// Substates Methods
	private function checkLoseCondition():Void 
	{
		if (player.hasLost)
		{
			hud.visible = false;
			openSubState(new DeathState());
		}
	}
}