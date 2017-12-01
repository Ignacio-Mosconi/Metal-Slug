package states;

import entities.enemies.Boss;
import entities.enemies.Truck;
import entities.player.Player;
import entities.enemies.Enemy;
import entities.enemies.Drone;
import entities.enemies.RifleSoldier;
import environment.Object;
import environment.Barrel;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;
import others.CameraWall;
import others.Collectable;
import others.HUD;
import weapons.Bullet;
import weapons.ExplosionBox;
import weapons.Grenade.GrenadeState;
import weapons.Knife;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import weapons.Nuke;
import weapons.Weapon;

class PlayState extends FlxState
{
	private var player:Player;
	private var boss:Boss;
	private var loader:FlxOgmoLoader;
	private var tilemap:FlxTilemap;
	private var cameraWalls:FlxTypedGroup<CameraWall>;
	private var entities:FlxGroup;
	private var enemies:FlxTypedGroup<Enemy>;
	private var collectables:FlxTypedGroup<Collectable>;
	private var objects:FlxTypedGroup<Object>;
	private var hud:HUD;
	private var skyBackDrop:FlxBackdrop;
	private var mountainBackDrop:FlxBackdrop;
	private var treesBackDrop:FlxBackdrop;
	private var theme:FlxSound;
	
	override public function create():Void
	{
		super.create();
		
		// Attributes Initialization
		entities = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();
		collectables = new FlxTypedGroup<Collectable>();
		objects = new FlxTypedGroup<Object>();
		skyBackDrop = new FlxBackdrop(AssetPaths.skyBackdrop__png, 0.5, 0, true, false, 0, 0);
		mountainBackDrop = new FlxBackdrop(AssetPaths.mountainBackdrop__png, 0.6, 0.1, true, false, 32, 0);
		treesBackDrop = new FlxBackdrop(AssetPaths.treesBackdrop__png, 1, 0.1, true, false, 320, 0);
		
		// Tilemap, Loader & Environment Set Up
		loader = new FlxOgmoLoader(AssetPaths.Level__oel);
		add(skyBackDrop);
		add(mountainBackDrop);
		add(treesBackDrop);
		tilemapSetUp();
		add(objects);
		loader.loadEntities(entityCreator, "Entities");
		
		// Game Set Up
		initialSetUp();
		cameraSetUp();
		hudSetUp();
		
		// Entities & Enemies Set Up
		entities.add(enemies);
		enemiesFollowingTargetSetUp();
		add(entities);
		add(collectables);
		
		// Music
		theme = FlxG.sound.load(AssetPaths.mainTheme__wav, 0.35, true, null, false, true, null, null);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Miscellaneus
		garbageCollector();
		cameraHandling();
		
		// Collisions
		// Entities - Tilemap & Walls
		FlxG.collide(player, cameraWalls);
		FlxG.overlap(entities, tilemap, entityTileMapCollision);
		// Player - Enemies
		FlxG.overlap(player, enemies, playerEnemyCollision);
		// Weapons - Enemies
		FlxG.overlap(player.pistolBullets, enemies, bulletEnemyCollision);
		FlxG.overlap(player.knife, enemies, knifeEnemyCollision);
		FlxG.collide(player.grenades, tilemap);
		for (grenade in player.grenades)
			if (grenade.currentState == GrenadeState.EXPLODING)
				FlxG.overlap(grenade.explosionBox, enemies, grenadeEnemyCollision);
		// Enemy Weapons - Player
		for (enemy in enemies)
			if (enemy.getType() == "RifleSoldier")
				FlxG.overlap(enemy.accessWeapon(), player, enemyBulletPlayerCollision);
		FlxG.overlap(boss.accessWeapon(), player, enemyNukePlayerCollision);
		for (nuke in boss.accessWeapon())
			if (nuke.currentState == NukeState.EXPLODING)
				FlxG.overlap(nuke.explosionBox, player, enemyExplosionPlayerCollision);
		// Weapons - Environment
		for (object in objects)
			if (object.getType() == "Barrel")
			{
				FlxG.overlap(player.knife, object, weaponObjectCollision);
				FlxG.overlap(player.pistolBullets, object, weaponObjectCollision);
				for (grenade in player.grenades)
					if (grenade.currentState == GrenadeState.EXPLODING)
						FlxG.overlap(grenade.explosionBox, object, weaponObjectCollision);
			}
		for (nuke in boss.accessWeapon())
			FlxG.collide(nuke, tilemap, nukeTilemapCollision);
		// Player - Collectables
		FlxG.overlap(player, collectables, playerCollectableCollision);
		
		// HUD Info & Sound
		if (!hud.visible)
			hud.visible = true;
		if (!theme.playing)
			theme.play();
		hud.updateHUD(Player.lives, player.totalAmmo, player.grenadesAmmo, Reg.score, player.isInvincible);
		
		// Substates Checking
		checkPauseCondition();
		checkLoseCondition();
	}
	
	// Set Up Methods
	private function tilemapSetUp():Void 
	{
		tilemap = loader.loadTilemap(AssetPaths.tileset__png, 32, 32, "Tiles");
		tilemap.setTileProperties(0, FlxObject.NONE);
		for (i in 1...6)
			tilemap.setTileProperties(i, FlxObject.ANY);
		for (i in 6...19)
			tilemap.setTileProperties(i, FlxObject.NONE);
		for (i in 19...22)
			tilemap.setTileProperties(i, FlxObject.UP);
		for (i in 22...26)
			tilemap.setTileProperties(i, FlxObject.NONE);
		for (i in 26...30)
			tilemap.setTileProperties(i, FlxObject.ANY);
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
			case "Drone":
				var drone = new Drone(x, y);
				enemies.add(drone);
			case "RifleSoldier":
				var rifleSoldier = new RifleSoldier(x, y);
				enemies.add(rifleSoldier);
			case "Truck":
				var truck = new Truck(x, y, enemies);
				enemies.add(truck);
			case "Boss":
				boss = new Boss(x, y);
				enemies.add(boss);
			case "Barrel":
				var barrel = new Barrel(x, y);
				objects.add(barrel);
			case "Collectable":
				var collectable = new Collectable(x, y, Reg.random.int(0, Reg.numberOfCollectables - 1));
				collectables.add(collectable);
		}
	}
	
	private function initialSetUp():Void 
	{
		camera.fade(FlxColor.BLACK, 0.5, true, null, false);
		FlxG.worldBounds.set(0, 0, loader.width, loader.height);
	}
	
	private function cameraSetUp():Void 
	{
		camera.scroll.x = player.x - 96;
		camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
		camera.followLerp = 0.5;
		camera.targetOffset.set(96, -64);
		camera.setScrollBounds(0, loader.width, 0, loader.height);
		camera.pixelPerfectRender = false;
		cameraWalls = new FlxTypedGroup<CameraWall>();
		var leftWall = new CameraWall(0, 0, FlxObject.LEFT);
		var rightWall = new CameraWall(FlxG.width, 0, FlxObject.RIGHT);
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
		if (!p.hasJustBeenHit && !e.isGettingDamage && !p.isInvincible)
		{
			FlxObject.separate(p, e);
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			p.getHit();
		}
		else
			if (e.getType() == "Truck" && e.currentState != TruckState.CHARGING)
				FlxObject.separate(p, e);
	}
	
	private function bulletEnemyCollision(b:Bullet, e:Enemy):Void
	{
		if (!e.isGettingDamage)
		{
			e.getDamage();
			b.kill();
		}
	}
	
	private function knifeEnemyCollision(k:Knife, e:Enemy):Void
	{
		if (!e.isGettingDamage && e.getType() != "Truck")
			e.getDamage();
		else
			k.kill();
	}
	
	private function grenadeEnemyCollision(eB:ExplosionBox, e:Enemy):Void
	{
		if (!e.isGettingDamage && e.getType() != "Truck")
			e.getDamage();
		else
			if (!e.isGettingDamage)
			{
				eB.destroy();
				e.getDamage(10);
			}
	}
	
	private function enemyExplosionPlayerCollision(eB:ExplosionBox, p:Player):Void
	{
		if (!p.hasJustBeenHit && !p.isInvincible && p.currentState != State.DYING)
		{
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			eB.destroy();
			p.getHit();
		}
	}
	
	private function enemyBulletPlayerCollision(w:Weapon, p:Player):Void 
	{
		if (!p.hasJustBeenHit && !p.isInvincible && p.currentState != State.DYING)
		{
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			p.getHit();
			w.kill();
		}
	}
	
	private function enemyNukePlayerCollision(n:Nuke, p:Player):Void 
	{
		if (!p.hasJustBeenHit && !p.isInvincible && p.currentState != State.DYING)
		{
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			p.getHit();
			n.hasJustCollided = true;
		}
	}
	
	private function weaponObjectCollision(w:Dynamic, o:Dynamic):Void 
	{
		if (o.getType() == "Barrel")
			o.dropItem(collectables);
		w.kill();
	}
	
	private function playerCollectableCollision(p:Player, c:Collectable):Void 
	{
		if (!p.hasJustPickedUpCollectable)
		{
			p.pickUpCollectable(c);
			if (p.hasJustPickedUpCollectable)
				c.bePicked(p);
		}
	}
	
	private function nukeTilemapCollision(n:Nuke, t:FlxTilemap):Void
	{
		n.hasJustCollided = true;
	}
	
	// Other Methods
	private function garbageCollector():Void	// Let's get rid of the nasty trash!
	{
		for (enemy in enemies)
			if (!enemy.alive)
			{
				enemy.destroy();
				enemies.remove(enemy, true);
				entities.remove(enemy, true);
			}
		for (collectable in collectables)
			if (!collectable.alive)
			{
				collectable.destroy();
				collectables.remove(collectable, true);
			}
		for (object in objects)
			if (!object.alive)
			{
				object.destroy();
				objects.remove(object, true);
			}
		for (bullet in player.pistolBullets)
			if (!bullet.alive)
			{
				bullet.destroy();
				player.pistolBullets.remove(bullet, true);
			}
		for (grenade in player.grenades)
			if (!grenade.alive)
			{
				grenade.destroy();
				player.grenades.remove(grenade, true);
			}
		for (enemy in enemies)
			if (enemy.accessWeapon() != null)
				for (bullet in enemy.accessWeapon())
					if (!bullet.alive)
					{
						bullet.destroy();
						enemy.accessWeapon().remove(bullet, true);
					}
	}
	
	private function cameraHandling():Void 
	{
		if (camera.scroll.x < loader.width - FlxG.width)
			camera.setScrollBounds(camera.scroll.x, loader.width, 0, loader.height);
		else
			camera.setScrollBounds(loader.width - FlxG.width, loader.width, 0, loader.height);
	}
	
	// Substates Methods
	private function checkPauseCondition():Void 
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			theme.pause();
			FlxG.sound.play(AssetPaths.select__wav);
			hud.visible = false;
			FlxG.mouse.visible = true;
			openSubState(new PauseState());
		}
	}
	
	private function checkLoseCondition():Void 
	{
		if (player.hasLost)
		{
			theme.pause();
			hud.visible = false;
			FlxG.mouse.visible = true;
			openSubState(new DeathState());
		}
	}	
}