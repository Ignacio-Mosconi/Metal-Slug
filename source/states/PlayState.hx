package states;

import entities.Player;
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
		
		//player = new Player(128, 320);
		//add(player);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	private function tilemapSetUp():Void 
	{
		loader = new FlxOgmoLoader(AssetPaths.Level__oel);
		tilemap = loader.loadTilemap(AssetPaths.tileset__png, 32, 32, "Tiles");
		tilemap.setTileProperties(0, FlxObject.NONE);
		tilemap.setTileProperties(1, FlxObject.ANY);
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
}