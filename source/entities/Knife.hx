package entities;

class Knife extends Weapon 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		makeGraphic(32, 16, 0x00000000, false);
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
}