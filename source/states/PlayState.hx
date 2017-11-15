package states;

import entities.Player;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.FlxG;

class PlayState extends FlxState
{
	private var player:Player;
	private var loader:FlxOgmoLoader;
	private var tilemap:FlxTilemap;
	
	override public function create():Void
	{
		super.create();
		
		FlxG.worldBounds.set(0, 0, 6400, 480);
		FlxG.mouse.visible = false;
		
		tilemapSetUp();
		loader.loadEntities(entityCreator, "Entities");
		
		cameraSetUp();
	
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.collide(player, tilemap);
	}
	
	private function tilemapSetUp():Void 
	{
		loader = new FlxOgmoLoader(AssetPaths.Level__oel);
		tilemap = loader.loadTilemap(AssetPaths.tileset__png, 32, 32, "Tiles");
		tilemap.setTileProperties(0, FlxObject.NONE);
		for (i in 1...3)
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
				add(player);
		}
	}
	
	private function cameraSetUp():Void 
	{
		camera.follow(player, FlxCameraFollowStyle.SCREEN_BY_SCREEN);
		camera.followLerp = 0.5;
		camera.setScrollBounds(0, 6400, 0, 480);
	}
}