package entities.enemies;

import entities.Entity;
import flixel.FlxObject;

class Enemy extends Entity
{
	private var speed:Int;
	public var isGettingDamage(get, null):Bool;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		isGettingDamage = false;
	}
	
	public function getDamage():Void
	{
		isGettingDamage = true;
	}
	
	function get_isGettingDamage():Bool 
	{
		return isGettingDamage;
	}
}