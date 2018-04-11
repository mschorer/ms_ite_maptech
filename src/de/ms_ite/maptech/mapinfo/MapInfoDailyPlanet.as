package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoDailyPlanet extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		import flash.geom.*;
		import flash.events.*;
		
		public function MapInfoDailyPlanet() {
			//TODO: implement function
			super( null, MODE_MAP);
			
			name="DailyPlanet";
			
			genMapProperties();
		}

		public function genMapProperties():Boolean {
			var rc:Boolean = false;
			
			_projection = new Projection();
			
			layers = 23;
			
			width = Math.pow( 2, layers + 8);
			height = Math.pow( 2, layers + 8);
			tileSize = 512;
//			tileAspect = 0.5;
			
//			debug("map loaded: " + width + "," + height + "pix ts" + tileSize + " v" + version + " / "+tileExt+".");

			bounds = new Bounds( -180, -90, 180, 90);
			debug( "gref: "+bounds);

			resolution.x = bounds.width / width;
			resolution.y = bounds.height / height;
			
			_projection.aspect = resolution.x / resolution.y;
			
			debug( "resolution: "+resolution+" u/px @ "+_projection.aspect);
			
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

			// zoom level 0 is a 512x512 tile containing a linearly projected map of the world in the top half:
			// http://wms.jpl.nasa.gov/wms.cgi?request=GetMap&width=512&height=512&layers=daily_planet&styles=&srs=EPSG:4326&format=image/jpeg&bbox=-180,-270,180,90
			// the -270 there works, and kind of makes sense, and gives the same image as:
			// http://wms.jpl.nasa.gov/wms.cgi?request=GetMap&width=512&height=512&layers=daily_planet&styles=&srs=EPSG:4326&format=image/jpeg&bbox=-180,-90,180,90

//-------------------

			var tilWide:Number = Math.pow(2, tier);
			var tilHigh:Number = Math.ceil(Math.pow(2, tier-1));
			while (y < 0) y += tilHigh;
			while (x < 0) x += tilWide;
			y %= tilHigh;
			x %= tilWide;

//-------------------

			var tilesWide:Number = Math.pow(2, tier);
			var tilesHigh:Number = Math.pow(2, tier);

			var w:Number = -180.0 + (360.0 * x / tilesWide);
			var n:Number = 90 - (180.0 * y / tilesHigh);
			var e:Number = w + (360.0 / tilesWide);
			var s:Number = n + (180.0 / tilesHigh);

			var bbox:String = [ w, s, e, n ].join(',');

			// don't use URLVariables to build this URL, because there's a chance that the cache might require things in a particular order
			// here's the pattern: request=GetMap&layers=daily_planet&srs=EPSG:4326&format=image/jpeg&styles=&width=512&height=512&bbox=-180,88,-178,90
			// from http://onearth.jpl.nasa.gov/wms.cgi?request=GetTileService
			var url:String = "http://wms.jpl.nasa.gov/wms.cgi?" +
								"request=GetMap" +
								"&layers=daily_planet" +
								"&srs=EPSG:4326" +
								"&format=image/jpeg" +
								"&styles=" +
								"&width=512" +
								"&height=512" +
								"&bbox=" + bbox;
								
			debug( "dlp: "+url);
			return url;
		}
	}
}