package entities.player.weapons;
import entities.player.weapons.Weapon;

class Knife extends Weapon 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.knifeAttack__png, true, 32, 64, false);
		animation.add("knifeAttack", [0, 1, 2, 3], 30, false, false, false);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	override public function reset(X, Y)
	{
		super.reset(X, Y);
		
		animation.play("knifeAttack");
	}
	
}