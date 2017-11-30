package environment;

import flixel.FlxG;
import flixel.system.FlxSound;
import others.Collectable;
import flixel.group.FlxGroup.FlxTypedGroup;

class Barrel extends Object 
{
	private var droppedItem:Int;
	private var breakSound:FlxSound;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.barrel__png, true, 48, 64, false);
		animation.add("destroy", [0, 1, 2, 3, 4], 24, false, false, false);
		breakSound = FlxG.sound.load(AssetPaths.breakBarrel__wav, 0.4);
		breakSound.proximity(x, y, camera.target, FlxG.width);
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
		breakSound.play();
		
		solid = false;
		if (Reg.random.bool(45))
		{
			droppedItem = Reg.random.int(0,  Reg.numberOfCollectables - 1);
			var collectable = new Collectable(x + width / 2 - 16, y + height / 2, droppedItem);
			collectables.add(collectable);
		}		
	}
	
	override public function getType():String
	{
		return "Barrel";
	}
}