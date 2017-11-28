package others;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Collectable extends FlxSprite 
{
	public var kindOfCollectable(get, null):Int;
	
	public function new(?X:Float=0, ?Y:Float=0, KindOfCollectable:Int) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.collectables__png, true, 32, 32, false);
		animation.add("ammo", [0], 30, false, false, false);
		animation.add("life", [1], 30, false, false, false);
		animation.add("grenades", [2], 30, false, false, false);
		animation.add("powerUp", [3], 30, false, false, false);
		
		kindOfCollectable = KindOfCollectable;
		
		switch (kindOfCollectable)
		{
			case 0:
				animation.play("ammo");
			case 1:
				animation.play("life");
			case 2:
				animation.play("grenades");
			case 3:
				animation.play("powerUp");
		}
	}
	
	function get_kindOfCollectable():Int 
	{
		return kindOfCollectable;
	}
	
}