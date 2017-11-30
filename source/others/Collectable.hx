package others;

import entities.player.Player;
import flixel.FlxSprite;

class Collectable extends FlxSprite 
{
	public var kindOfCollectable(get, null):Int;
	private var enitityWhoPickedItUp:Player;
	
	public function new(?X:Float=0, ?Y:Float=0, KindOfCollectable:Int) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.collectables__png, true, 32, 32, false);
		animation.add("ammo", [0], 30, false, false, false);
		animation.add("life", [1], 30, false, false, false);
		animation.add("grenades", [2], 30, false, false, false);
		animation.add("powerUp", [3], 30, false, false, false);
		animation.add("score", [4], 30, false, false, false);
		
		animation.add("pickUpAmmo", [5, 6, 7], 3, false, false, false);
		animation.add("pickUpLife", [8, 9, 10, 11], 3, false, false, false);
		animation.add("pickUpGrenade", [12, 13, 14], 3, false, false, false);
		animation.add("pickUpPowerUp", [15, 16], 3, false, false, false);
		animation.add("pickUpScore", [17, 18, 19, 20], 3, false, false, false);
		
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
			case 4:
				animation.play("score");
		}
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (animation.name != "ammo" && animation.name != "life" && animation.name != "grenades" && animation.name != "powerUp"
		&& animation.name != "score" && animation.finished)
		{
			enitityWhoPickedItUp.hasJustPickedUpCollectable = false;
			kill();
		}
	}
	
	public function bePicked(player:Player):Void
	{
		enitityWhoPickedItUp = player;
		
		switch (kindOfCollectable)
		{
			case 0:
				animation.play("pickUpAmmo");
			case 1:
				animation.play("pickUpLife");
			case 2:
				animation.play("pickUpGrenade");
			case 3:
				animation.play("pickUpPowerUp");
			case 4:
				animation.play("pickUpScore");
		}
	}
	
	function get_kindOfCollectable():Int 
	{
		return kindOfCollectable;
	}	
}