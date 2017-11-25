package states;

import entities.enemies.Drone;
import entities.enemies.Enemy;
import entities.enemies.RifleSoldier;
import entities.player.weapons.Bullet;
import entities.player.weapons.ExplosionBox;
import entities.player.weapons.Grenade;
import entities.player.weapons.Grenade.GrenadeState;
import entities.player.weapons.Knife;
import entities.player.Player;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var player:Player;
	private var loader:FlxOgmoLoader;
	private var tilemap:FlxTilemap;
	private var entities:FlxGroup;
	private var enemies:FlxTypedGroup<Enemy>;
	private var hud:HUD;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.worldBounds.set(0, 0, 3200, 320);
		FlxG.mouse.visible = false;
		
		entities = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();
		
		loader = new FlxOgmoLoader(AssetPaths.Level__oel);
		loader.loadEntities(entityCreator, "Entities");
		tilemapSetUp();
		
		cameraSetUp();
		hudSetUp();
		
		entities.add(enemies);
		add(enemies);
		
		enemiesFollowingTargetSetUp();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.overlap(entities, tilemap, entityTileMapCollision);
		FlxG.overlap(player, enemies, playerEnemyCollision);
		FlxG.overlap(player.pistolBullets, enemies, bulletEnemyCollision);
		FlxG.overlap(player.knife, enemies, knifeEnemyCollision);
		FlxG.collide(player.grenades, tilemap);
		for (grenade in player.grenades)
			if (grenade.currentState == GrenadeState.EXPLODING)
				FlxG.overlap(grenade.explosionBox, enemies, grenadeEnemyCollision);
			
		hud.updateHUD(Player.lives, player.totalAmmo, player.grenadesAmmo, Reg.score);
	}
	
	// Set Up Methods
	private function tilemapSetUp():Void 
	{
		tilemap = loader.loadTilemap(AssetPaths.tileset__png, 32, 32, "Tiles");
		tilemap.setTileProperties(0, FlxObject.NONE);
		for (i in 1...4)
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
				add(player);
			case "Drone":
				var drone = new Drone(x, y);
				enemies.add(drone);
			case "RifleSoldier":
				var rifleSoldier = new RifleSoldier(x, y);
				enemies.add(rifleSoldier);
		}
	}
	
	private function cameraSetUp():Void 
	{
		camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
		camera.followLerp = 0.5;
		camera.targetOffset.set(96, -64);
		camera.setScrollBounds(0, 3200, 0, 320);
		camera.bgColor = 0xFF224466;
		camera.pixelPerfectRender = false;
	}
	
	private function hudSetUp():Void 
	{
		hud = new HUD(player);
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
}