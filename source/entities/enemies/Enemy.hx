package entities.enemies;

import entities.Entity;
import entities.player.Player;
import flixel.group.FlxGroup.FlxTypedGroup;

class Enemy extends Entity
{
	private var speed:Int;
	@:isVar public var currentState(get, set):Dynamic;
	public var isGettingDamage(get, null):Bool;
	private var followingTarget:Player;
	
	public function new(?X, ?Y) 
	{
		super(X, Y);
		
		isGettingDamage = false;
	}
	
	public function getDamage(?damage:Int):Void
	{
		isGettingDamage = true;
	}
	
	public function setFollowingTarget(target:Player):Void
	{
		followingTarget = target;
	}
	
	public function accessWeapon():FlxTypedGroup<Dynamic>
	{
		return null;
	}
	
	function get_isGettingDamage():Bool 
	{
		return isGettingDamage;
	}
	
	function get_currentState():Dynamic
	{
		return currentState;
	}
	
	function set_currentState(value:Dynamic):Dynamic 
	{
		return currentState = value;
	}
}