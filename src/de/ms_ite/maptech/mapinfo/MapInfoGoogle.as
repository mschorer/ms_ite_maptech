package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoGoogle extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		import flash.geom.*;
		import flash.events.*;
		
		protected static var roundRobin:int = 0;

		// http://mt0.google.com/vt/lyrs=h@140&hl=de&x=992&y=663&z=11&s=Galileo
		protected var __hybridVersion:String = 'h@140';
		
		//	http://mt1.google.com/vt/lyrs=m@140&hl=de&x=987&y=666&z=11&s=Gal
		protected var __roadVersion:String = 'm@140';	//'w2.88';
		
		// http://khm1.google.com/kh/v=74&x=493&y=333&z=10&s=Gali
		protected var __aerialVersion:String = '74';
		
		// http://mt1.google.com/vt/lyrs=t@126,r@140&hl=de&x=987&y=665&z=11&s=Ga
		protected var __terrainVersion:String = 't@126,r@140';
		
		protected var __moonVersion:String = 'lunarmaps_v1';
		
		protected var __marsVisVersion:String = 'visible';
		protected var __marsIRVersion:String = 'infrared';
		protected var __marsElevVersion:String = 'elevation';
		
		
		public function MapInfoGoogle( mode:int) {
			//TODO: implement function
			super( null, mode);

			modes.push( { name:'Google (Map)', value:MODE_MAP, version:__roadVersion});
			modes.push( { name:'Google (Aerial)', value:MODE_AERIAL, version:__aerialVersion});
			modes.push( { name:'Google (Streets)', value:MODE_OVERLAY, version:__hybridVersion});
			modes.push( { name:'Google (Terrain)', value:MODE_TERRAIN, version:__terrainVersion});
			modes.push( { name:'Google (Moon)', value:MODE_EXT_MOON, version:__moonVersion});
			modes.push( { name:'Google (Mars Vis)', value:MODE_EXT_MARS_VIS, version:__marsVisVersion});
			modes.push( { name:'Google (Mars IR)', value:MODE_EXT_MARS_IR, version:__marsIRVersion});
			modes.push( { name:'Google (Mars Elev)', value:MODE_EXT_MARS_ELEV, version:__marsElevVersion});

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
			
			layers = 17;
			
			width = Math.pow( 2, layers + 8);
			height = Math.pow( 2, layers + 8);
			tileSize = 256;
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
				case MODE_EXT_MOON: url = getMoonTileURL( tier, x, y); break;

				case MODE_EXT_MARS_VIS: url = getMarsVisTileURL( tier, x, y); break;
				case MODE_EXT_MARS_IR: url = getMarsIRTileURL( tier, x, y); break;
				case MODE_EXT_MARS_ELEV: url = getMarsElevTileURL( tier, x, y); break;

				case MODE_AERIAL: url = getAerialTileURL( tier, x, y); break;	        
				case MODE_OVERLAY: url = getHybridTileURL( tier, x, y); break;
				case MODE_TERRAIN: url = getTerrainTileURL( tier, x, y); break;
				
				case MODE_MAP:
				default:  
					url = getMapTileURL( tier, x, y);
			}
			
			return url;
		}

		protected function getMapTile( tier:int, x:int, y:int):String {
	        return "&x="+x +"&y="+y+"&zoom="+(17 - tier);
		}
		
		protected function getMapTileURL( tier:int, x:int, y:int):String {
	        var zoomString:String = getMapTile( tier, x, y);
	        
	        roundRobin = ++roundRobin % 4;
	        
	        var temp:String = "http://mt"+roundRobin+".google.com/vt/lyrs="+__roadVersion+"&hl=en"+zoomString;
	        
	        debug( "url map: "+temp);
	        
			return temp;
		}
		
		protected function getHybridTileURL( tier:int, x:int, y:int):String {
	        var zoomString:String = getMapTile( tier, x, y);
	        
	        roundRobin = ++roundRobin % 4;
	        
	        var temp:String = "http://mt"+roundRobin+".google.com/vt/lyrs="+__hybridVersion+"&hl=en"+zoomString;
	        
	        // http://mt0.google.com/vt/lyrs=h@118&hl=de&x=6&y=6&z=4&s=
	        
	        debug( "url overlay: "+temp);
	        
			return temp;
		}
		
		public function getAerialTileURL( tier:int, x:int, y:int):String {
	        roundRobin = ++roundRobin % 4;
	        
			var temp:String = "http://khm"+roundRobin+".google.com/kh/v="+__aerialVersion+"&hl=en&t="+getAerialTile( tier, x, y);
			
			debug( "url aerial: "+temp);
			
			return temp;
		}
		
		public function getTerrainTileURL( tier:int, x:int, y:int):String {
	        roundRobin = ++roundRobin % 4;
			var zoomString:String = getMapTile( tier, x, y);
				        
			var temp:String = "http://mt"+roundRobin+".google.com/vt/v="+__terrainVersion+"&hl=en"+zoomString;
			
			// http://mt0.google.com/vt/v=w2p.118&hl=de&x=8&y=8&z=4&s=
			
			debug( "url terrain: "+temp);
			
			return temp;
		}

		public function getMoonTileURL( tier:int, x:int, y:int):String {
				        
			var temp:String = "http://mw1.google.com/mw-planetary/lunar/"+__moonVersion+"/apollo/"+tier+"/"+x+"/"+( Math.pow( 2, tier)-1-y)+".jpg";
			debug( "url moon: "+temp);
			
			return temp;
		}

		public function getMarsVisTileURL( tier:int, x:int, y:int):String {
			var temp:String = "http://mw1.google.com/mw-planetary/mars/"+__marsVisVersion+"/"+getAerialTile( tier, x, y)+".jpg";
			debug( "url mars vis: "+temp);
			
			return temp;
		}
		
		public function getMarsIRTileURL( tier:int, x:int, y:int):String {
			var temp:String = "http://mw1.google.com/mw-planetary/mars/"+__marsIRVersion+"/"+getAerialTile( tier, x, y)+".jpg";
			debug( "url mars ir: "+temp);
			
			return temp;
		}
		public function getMarsElevTileURL( tier:int, x:int, y:int):String {
			var temp:String = "http://mw1.google.com/mw-planetary/mars/"+__marsElevVersion+"/"+getAerialTile( tier, x, y)+".jpg";
			debug( "url mars elev: "+temp);
			
			return temp;
		}
/*
		public function GoogleMoonSattelite() {
			subDomain = "http://mw1";
			queryString = "/mw-planetary/lunar/lunarmaps_v";
		}

		public function request(pos : TileData) : URLRequest {
			var tileUrl : String = subDomain + domain + queryString + version + "/apollo/" +pos.depth+"/"+pos.col+"/"+(pos.maxCols-1-pos.row)+".jpg";
			return new URLRequest(tileUrl);
		}
*/		
		private function getAerialTile( tier:int, x:int, y:int):String {		
			y = Math.pow(2, tier) - y - 1;
//			x = x;
            tier += 1;
                                    
			// convert row + col to zoom string
			var rowBinaryString:String = BinaryUtil.convertToBinary( y);
			rowBinaryString = rowBinaryString.substring(rowBinaryString.length - tier);
			
			var colBinaryString:String = BinaryUtil.convertToBinary( x);
			colBinaryString = colBinaryString.substring(colBinaryString.length - tier);
	
			// generate zoom string by combining strings
			var urlChars:String = 'tsqr';
			var zoomString:String = "";
	
			for(var i:Number = 0; i < tier; i++)
			    zoomString += urlChars.charAt(BinaryUtil.convertToDecimal(rowBinaryString.charAt(i) + colBinaryString.charAt(i)));
	                         
			return zoomString; 
		}
	}
}