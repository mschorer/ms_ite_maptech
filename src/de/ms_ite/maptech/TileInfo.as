package de.ms_ite.maptech {
	import de.ms_ite.maptech.mapinfo.MapInfo;
	
	import spark.components.Image;
	
	public class TileInfo {
		
		protected var _tile:Image;
		protected var _remote_url:String;
		
		protected var _mapInfo:MapInfo;
		
		protected var _layer:int;
		protected var _x:int;
		protected var _y:int;
		
		public var sort:int=0;
		
		public function TileInfo( img:Image=null, mi:MapInfo=null, lay:int=-1, x:int=-1, y:int=-1, sort:int=0) {
			_tile = img;
			_mapInfo = mi;
			
			_layer = lay;
			_x = x;
			_y = y;
			
			this.sort = sort;

			if ( _mapInfo != null) _remote_url = _mapInfo.getTileURL( _layer, _x, _y);
		}
		
		public function get url():String {
			return _remote_url;
		}
		public function set url( u:String):void {
			_remote_url = u;
		}
		
		public function isCached():Boolean {
			return false;
		}
		
		public function get tile():Image {
			return _tile;
		}
		
		public function load():void {
			_tile.source = _remote_url;
		}
		
		public function key():String {
			return _mapInfo.name+"/"+_layer+"/"+_x+"/"+_y;
		}
		
		protected function debug( txt:String, level:int=0):void {
			trace( 'ti: '+txt);
		}
	}
}