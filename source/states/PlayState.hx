package states;

import entities.enemies.Drone;
import entities.enemies.Enemy;
import entities.player.Bullet;
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
	private var entities:FlxGroup;
	private var player:Player;
	private var loader:FlxOgmoLoader;
	private var tilemap:FlxTilemap;
	private var enemies:FlxTypedGroup<Enemy>;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.worldBounds.set(0, 0, 3200, 512);
		FlxG.mouse.visible = false;
		
		entities = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();
		entities.add(enemies);
		add(enemies);
		
		tilemapSetUp();
		loader.loadEntities(entityCreator, "Entities");
		
		cameraSetUp();	
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.overlap(entities, tilemap, enityTileMapCollision);
		FlxG.overlap(player, enemies, playerEnemyCollision);
		FlxG.overlap(player.pistolBullets, enemies, bulletEnemyCollision);
		
		trace(Reg.score);
	}
	
	// Set Up Methods
	private function tilemapSetUp():Void 
	{
		loader = new FlxOgmoLoader(AssetPaths.Level__oel);
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
		}
	}
	
	private function cameraSetUp():Void 
	{
		camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
		camera.followLerp = 0.5;
		camera.targetOffset.set(96, -64);
		camera.setScrollBounds(0, 3200, 0, 512);
		camera.pixelPerfectRender = false;		
	}
	
	// Collision Methods	
	private function enityTileMapCollision(e:Dynamic, t:FlxTilemap):Void 
	{
		if (e.getType() != "Drone")
		{
			FlxObject.separate(e, t);
		}
	}
	
	private function playerEnemyCollision(p:Player, e:Enemy):Void 
	{
		if (!player.isInvincible)
		{
			FlxObject.separate(p, e);
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.RED, 0.25);
			p.kill();
		}
	}
	
	private function bulletEnemyCollision(b:Bullet, e:Enemy):Void
	{
		e.getDamage();
		player.pistolBullets.remove(b);
	}
}