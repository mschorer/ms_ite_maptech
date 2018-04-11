package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoYahoo extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		import flash.geom.*;
		import flash.events.*;
		
		protected static var roundRobin:int = 0;

		protected var __hybridVersion:String = '1.7';
		protected var __hybridVersion2:String = '2.2';
		protected var __aerialVersion:String = '1.7';
		protected var __overlayVersion:String = '2.0';
		protected var __roadVersion:String = '3.52';
		
		public function MapInfoYahoo( mode:int) {
			//TODO: implement function
			super( null, mode);
			
			modes.push( { name:'Yahoo (Map)', value:MODE_MAP, version:__roadVersion});
			modes.push( { name:'Yahoo (Aerial)', value:MODE_AERIAL, version:__aerialVersion});
			modes.push( { name:'Yahoo (Routes)', value:MODE_OVERLAY, version:__overlayVersion});
			modes.push( { name:'Yahoo (Borders)', value:MODE_OVERLAY1, version:__hybridVersion2});
			
			for each( var obj:Object in modes) {
				if ( obj.value == mapMode) {
					name = obj.name;
					version = obj.version;
				}
			}
						
			genMapProperties();
		}

		public function genMapProperties():Boolean {
			var rc:Boolean = false;
			
			_projection = new ProjectionMercator();
			
			layers = 18;
			
			width = Math.pow( 2, layers + 8);
			height = Math.pow( 2, layers + 8);
			tileSize = 256;
			tileOffsetX = -1;
			tileOffsetY = -1;
//			tileAspect = 0.5;
			tileExt = '';
			
//			debug("map loaded: " + width + "," + height + "pix ts" + tileSize + " v" + version + " / "+tileExt+".");

			bounds = new Bounds( -180, -85.05112878, 180, 85.05112878);
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
				case MODE_OVERLAY: url = getOverlayTileURL( tier, x, y); break;	        
				case MODE_OVERLAY1: url = getHybridTileURL( tier, x, y); break;

				case MODE_AERIAL: url = getAerialTileURL( tier, x, y); break;	        
				
				case MODE_MAP:
				default:  
					url = getMapTileURL( tier, x, y);
			}
			
			return url;
		}

		protected function getZoomString( x:int, y:int, zoom:int) : String
		{		
	        var row : Number = ( Math.pow( 2, zoom ) /2 ) - y - 1;
			return "&x=" + x + "&y=" + row + "&z=" + (18 - zoom);
		}
		
		protected function getMapTileURL( tier:int, x:int, y:int):String {
//	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v="+__roadVersion+"&t=m" + getZoomString( x, y, tier);
	        debug( "url map: "+temp);
	        
			return temp;
		}
		
		protected function getOverlayTileURL( tier:int, x:int, y:int):String {
//	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200608221700&v="+__overlayVersion+"&t=h" + getZoomString( x, y, tier);
			
//			"http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v=2.2&t=h" + getZoomString(sourceCoordinate(coord)) ;
			debug( "url ovl: "+temp);
	        
			return temp;
		}
		
		protected function getHybridTileURL( tier:int, x:int, y:int):String {
//	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v="+__hybridVersion2+"&t=h" + getZoomString( x, y, tier);
			
//			"http://us.maps3.yimg.com/aerial.maps.yimg.com/png?v=2.2&t=h" + getZoomString(sourceCoordinate(coord)) ;
			debug( "url hyb2: "+temp);
	        
			return temp;
		}
		
		public function getAerialTileURL( tier:int, x:int, y:int):String {
//	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://us.maps3.yimg.com/aerial.maps.yimg.com/tile?v="+__aerialVersion+"&t=a" + getZoomString( x, y, tier);			
			debug( "url aer: "+temp);
			
			return temp;
		}
	}
}