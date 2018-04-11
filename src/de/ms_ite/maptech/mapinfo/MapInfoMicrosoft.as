package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoMicrosoft extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		import flash.geom.*;
		import flash.events.*;
		
		protected static var roundRobin:int = 0;

		protected var __hybridVersion:String = '213';
		protected var __aerialVersion:String = '213';
		protected var __roadVersion:String = '213';
		
		public function MapInfoMicrosoft( mode:int) {
			//TODO: implement function
			super( null, mode);
			
			modes.push( { name:'Virtual Earth (Map)', value:MODE_MAP, version:__roadVersion});
			modes.push( { name:'Virtual Earth (Aerial)', value:MODE_AERIAL, version:__aerialVersion});
			modes.push( { name:'Virtual Earth (Hybrid)', value:MODE_HYBRID, version:__hybridVersion});
									
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
			
			// used for europe
			layers = 19;
			
			width = Math.pow( 2, layers + 8);
			height = Math.pow( 2, layers + 8);
			tileSize = 256;
//			tileAspect = 0.5;
//			version = __hybridVersion;
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
				case MODE_AERIAL: url = getAerialTileURL( tier, x, y); break;	        
				case MODE_HYBRID: url = getHybridTileURL( tier, x, y); break;
				
				case MODE_MAP:
				default:  
					url = getMapTileURL( tier, x, y);
			}
			
			return url;
		}

		protected function getMapTileURL( tier:int, x:int, y:int):String {
	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://r"+roundRobin+".ortho.tiles.virtualearth.net/tiles/r"+TileXYToQuadKey( tier, x, y)+".png?g="+__roadVersion;
			//+"&shading=hill";
//	        debug( "url map: "+temp);
	        
			return temp;
		}
		
		protected function getHybridTileURL( tier:int, x:int, y:int):String {
	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://h"+roundRobin+".ortho.tiles.virtualearth.net/tiles/h"+TileXYToQuadKey( tier, x, y)+".jpeg?g="+__hybridVersion;
//			debug( "url hyb: "+temp);
	        
			return temp;
		}
		
		public function getAerialTileURL( tier:int, x:int, y:int):String {
	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://a"+roundRobin+".ortho.tiles.virtualearth.net/tiles/a"+TileXYToQuadKey( tier, x, y)+".jpeg?g="+__aerialVersion;			
//			debug( "url aer: "+temp);
			
			return temp;
		}			

       public function TileXYToQuadKey( levelOfDetail:int, tileX:int, tileY:int):String {
            var quadKey:String = '';
            var digit:int;
            
            for ( var i:int = levelOfDetail; i > 0; i--)
            {
                digit = 0;
                var mask:int = 1 << (i - 1);
                if ((tileX & mask) != 0)
                {
                    digit++;
                }
                if ((tileY & mask) != 0)
                {
                    digit++;
                    digit++;
                }
                quadKey += digit;
            }
            return quadKey;
        }
	}
}