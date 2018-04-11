package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoWMTS extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		
		import flash.events.*;
		import flash.geom.*;
		
		protected var _url_fmt:String;
		
		public function MapInfoWMTS( u:String=null, _name:String='WMTS') {
			//TODO: implement function
			super( null, MODE_MAP);
			
			name = _name;
			if ( u != null) _url_fmt = u;
			else _url_fmt = "http://wms.touvia.de/geoserver/gwc/service/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=topplan:wegenetz&STYLE=&TILEMATRIXSET=EPSG:900913&TILEMATRIX=EPSG:900913:%1&TILECOL=%2&TILEROW=%3&FORMAT=image/png";
			tileExt = 'png';
			
			genMapProperties();
		}

		public function genMapProperties():Boolean {
			var rc:Boolean = false;
			
			_projection = new ProjectionMercator();
			
			layers = 18;
			
			width = Math.pow( 2, layers + 8);
			height = Math.pow( 2, layers + 8);
			tileSize = 256;
//			tileAspect = 0.5;
			
//			debug("map loaded: " + width + "," + height + "pix ts" + tileSize + " v" + version + " / "+tileExt+".");

			bounds = new Bounds( -180, -85.05112878, 180, 85.05112878);
			debug( "gref: "+bounds);

			resolution.x = bounds.width / width;
			resolution.y = bounds.height / height;
			
			_projection.aspect = resolution.x / resolution.y;
			
			debug( "resolution: "+resolution+" u/px @ "+_projection.aspect);
			debug( "url: "+_url_fmt);
			
			return buildMetaInfo( width, height, resolution);
		}

		override public function getTileURL( tier:int, x:int, y:int):String {
			var url:String;

			switch( mapMode) {
				case MODE_MAP:
				default:  
					url = getMapTileURL( tier, x, y);
			}
			
			return url;
		}

		protected function getMapTileURL( tier:int, x:int, y:int):String {
			// http://46.137.75.201/geoserver/gwc/service/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=topplan:wegenetz&STYLE=&TILEMATRIXSET=EPSG:900913&TILEMATRIX=EPSG:900913:7&TILECOL=67&TILEROW=44&FORMAT=image/png

			var temp:String = _url_fmt;
			temp = temp.replace( "%1", tier);
			temp = temp.replace( "%2", x);
			temp = temp.replace( "%3", y);
			
	        debug( "url map: "+temp);
	        
			return temp;
		}
/*		
		override protected function debug( txt:String, lvl:int=0):void {
			trace( "WMTS: "+txt);
		}
*/
	}
}