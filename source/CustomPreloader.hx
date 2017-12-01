package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.system.FlxBasePreloader;
import flash.display.*;
import flash.Lib;
import flixel.text.FlxText;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;


class CustomPreloader extends FlxBasePreloader 
{
	var text:TextField;
	
	public function new(MinDisplayTime:Float=3, ?AllowedURLs:Array<String>) 
	{
		super(MinDisplayTime, AllowedURLs);
		
	}
	
	override function create():Void
	{
		_width = Lib.current.stage.stageWidth;
		_height = Lib.current.stage.stageHeight;
		
		text = new TextField();
		text.defaultTextFormat = new TextFormat("Nokia Cellphone FC Small", 48, 0xffffff, false, false, false, " ", " ", TextFormatAlign.CENTER);
		text.selectable = false;
		text.multiline = false;
		text.x = 0;
		text.y = _height / 2;
		text.width = _width;
		text.height = 64;
		text.text = "Loading:";
		addChild(text);
		
		super.create();
	}
	
	override function update(Percent:Float):Void
	{
		text.text = "Loading: " + Std.int(Percent * 100) + "%";
		super.update(Percent);
	}	
}