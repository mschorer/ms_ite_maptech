package de.ms_ite.maptech
{
	import de.ms_ite.maptech.mapinfo.MapInfo;
	
	import flash.display.Sprite;
	import spark.components.Image;

	public interface ILoadQueue
	{
		function isEmpty():Boolean;
		function queue( tile:TileInfo, prio:int=0, sort:int=0):Boolean;
		function unqueue( tile:TileInfo, prio:int=0):void;
		function clear():void;
		function getTileInfo( img:Image, mi:MapInfo, lay:int, x:int, y:int):TileInfo;
	}
}