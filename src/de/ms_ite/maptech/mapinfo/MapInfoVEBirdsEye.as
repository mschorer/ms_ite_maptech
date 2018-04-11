package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoVEBirdsEye extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		import de.ms_ite.maptech.tools.*;

		import flash.geom.*;
		import flash.events.*;
		
		protected static var roundRobin:int = 0;
		
 		protected var beParms:BirdsEyeParameterService;

		public function MapInfoVEBirdsEye() {
			//TODO: implement function
			super( null, MODE_BIRDSVIEW);
			
			name = 'Virtual Earth (BirdsView)';
			version = '234';
			
			modes.push( { name:name, value:MODE_BIRDSVIEW, version:version});
												
			_projection = new ProjectionVEBirdsEye();
			
			bounds = new Bounds( -180, -85.05112878, 180, 85.05112878);
			debug( "gref: "+bounds);
			
			beParms = BirdsEyeParameterService.getInstance();
			beParms.addEventListener( Event.COMPLETE, handleBEComplete);
		}

		public function get maxDepth() : Number {
			return 2;
		}
		
		public function get hasView():Boolean {
			return ( beParms.Scene != null);
		}
		
		public function update( p:Point, dir:String):void {
			debug( "getinfo: "+p+" / "+dir);
			beParms.query( p, dir);
		}
		
		protected function handleBEComplete( evt:Event):void {
			debug( "info loaded.");
			
			var rc:Boolean = false;
			
			var layers:int = 2;
			
			var beP:BirdsEyeParameters = beParms.Scene;
			ProjectionVEBirdsEye( _projection).patchParameters = beP;
			
			tileSize = 256;
			width = tileSize * beParms.Scene.hTiles;
			height = tileSize * beParms.Scene.vTiles;
//			tileAspect = 0.5;
//			version = __hybridVersion;
			tileExt = '';
			
//			debug("map loaded: " + width + "," + height + "pix ts" + tileSize + " v" + version + " / "+tileExt+".");

			var tl:Point = ProjectionVEBirdsEye( _projection).screen2coord( new Point( 0, 0), null, new Point( 0, 0));
			var br:Point = ProjectionVEBirdsEye( _projection).screen2coord( new Point( width, height), null, new Point( 0, 0));

			bounds = new Bounds( tl.x, br.y , br.x, tl.y);
			debug( "gref: "+bounds.toString());

			resolution.x = bounds.width / width;
			resolution.y = bounds.height / height;
			
			_projection.aspect = resolution.x / resolution.y;
			
			debug( "resolution: "+resolution+" u/px @ "+_projection.aspect);
						
			var w:Number = width;
			var h:Number = height;
			var res:Point = resolution;
			var tw:Number;
			var th:Number;
			
			var levl:int = 2;
			while( levl > 0 && ( w > tileSize || h > tileSize)) {
				tw = Math.ceil( w / tileSize);
				th = Math.ceil( h / tileSize);
				
//				debug( "size: "+w+"x"+h);
//				debug( "layer: "+tw+"x"+th	/*+" / "+res*/);
				
				tilesPerLevel.push( new Point( tw, th));
				resolutionPerLevel.push( new Point( res.x, res.y));
				
				w = Math.floor( w / 2);
				h = Math.floor( h / 2);
				res.x *= 2;
				res.y *= 2;
				
				levl--;
			}

			tw = Math.ceil( w / tileSize);
			th = Math.ceil( h / tileSize);
			debug( "layer: "+tw+"x"+th +" / "+res);

//			tilesPerLevel.push( new Point( 1, 1));
			tilesPerLevel.reverse();
			
//			resolutionPerLevel.push( res);
			resolutionPerLevel.reverse();
					
			initialized = true;
			
			dispatchEvent( new Event( Event.COMPLETE));
		}

		override public function getTileURL( tier:int, x:int, y:int):String {
	        roundRobin = ++roundRobin % 4;

			var clid:String = beParms.Scene.id;	//'12023000221';
			var bkid:int = beParms.Scene.patch_id;	//'3443'
			var level:String = ''+( 19+tier);
			var tileID:int = x + y * (( tier == 0) ? (beParms.Scene.hTiles / 2) : beParms.Scene.hTiles);
			
			var url:String = "http://t"+roundRobin+".tiles.virtualearth.net/tiles/o"+clid+"-"+bkid+"-"+level+"-"+tileID+".jpeg?g="+version;
//	        debug( "url map("+tier+" / "+x+","+y+"): "+url);
	        
			return url;
		}
	}
}
