package entities.enemies;

import entities.Entity;
import entities.player.Player;
import flixel.group.FlxGroup.FlxTypedGroup;

class Enemy extends Entity
{
	private var speed:Int;
	public var isGettingDamage(get, null):Bool;
	private var followingTarget:Player;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		isGettingDamage = false;
	}
	
	public function getDamage():Void
	{
		isGettingDamage = true;
	}
	
	public function setFollowingTarget(target:Player)
	{
		followingTarget = target;
	}
	
	public function accessWeapon():Dynamic
	{
		return "noWeapon";
	}
	
	function get_isGettingDamage():Bool 
	{
		return isGettingDamage;
	}
}