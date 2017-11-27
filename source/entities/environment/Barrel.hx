package entities.environment;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import others.Collectable;

class Barrel extends FlxSprite 
{
	private var droppedItem:Int;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.barrel__png, true, 48, 64, false);
		animation.add("destroy", [0, 1, 2, 3, 4], 24, false, false, false);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (animation.name == "destroy" && animation.finished)
			kill();
	}
	
	public function dropItem(collectables:FlxTypedGroup<Collectable>):Void
	{
		animation.play("destroy");
		solid = false;
		if (Reg.random.bool(35))
		{
			droppedItem = Reg.random.int(0, Reg.numberOfCollectables);
			var collectable = new Collectable(x, y + 16, droppedItem);
			collectables.add(collectable);
		}		
	}
}