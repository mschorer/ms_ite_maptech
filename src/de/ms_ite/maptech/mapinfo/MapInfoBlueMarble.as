package de.ms_ite.maptech.mapinfo {
	
	public class MapInfoBlueMarble extends MapInfo {
		
		import de.ms_ite.*;
		import de.ms_ite.maptech.*;
		import de.ms_ite.maptech.projections.*;
		import flash.geom.*;
		import flash.events.*;
		
		public function MapInfoBlueMarble() {
			//TODO: implement function
			super( null, MODE_MAP);
			
			name="BlueMarble";
			
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
			var temp:String = 'http://s3.amazonaws.com/com.modestmaps.bluemarble/'+tier+'-r'+y+'-c'+x+'.jpg' ;
//	        debug( "url map: "+temp);
	        
			return temp;
		}
	}
}