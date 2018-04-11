package de.ms_ite.maptech {
	
	public class MapGlue {
		
		private static var MODE_TBD:int = -1;
		private static var MODE_NULL:int = 0;
		private static var MODE_OGC:int = 1;
		private static var MODE_XY:int = 2;
		
		private var pointMode:int = MODE_TBD;
		private var pointXProp:String = null;
		private var pointYProp:String = null;
		
		private var propsPos:Array = [
									{propx:'location',propy:null},
									{propx:'zentroid',propy:null},
									{propx:'longitude',propy:'latitude'},
									{propx:'lon',propy:'lat'},
									{propx:'lng',propy:'lat'},
									{propx:'x',propy:'y'}
									];
				
		private var geomMode:int = MODE_TBD;
		private var geometryProp:String = null;
		
		private var propsGeom:Array = [
									'geometry',
									'geometrie'
									];

		public function MapGlue():void {
			debug( "created. "+propsPos.length+"/"+propsGeom.length);
			pointMode = MODE_TBD;
			geomMode = MODE_TBD;
		}
		
		public function reset():void {
			debug( "reset. "+propsPos.length+"/"+propsGeom.length);
			pointMode = MODE_TBD;
			geomMode = MODE_TBD;
		}
		
		public function limitDecimals( val:Number, decs:int):Number {
			var mult:Number = Math.pow( 10, decs);
			return Math.round( val * mult) / mult;
		}

		public function setPoint( row:Object, x:Number, y:Number):Boolean {
			var rc:Boolean = false;
			
			x = limitDecimals( x, 6);
			y = limitDecimals( y, 6);

			switch( pointMode) {
				case MODE_OGC:
					var temp:String = 'POINT( '+x+' '+y+")";
					if ( row[ pointXProp] != temp) {
						row[ pointXProp] = temp;
						rc = true;
					}
				break;

				case MODE_XY:
					if ( row[ pointXProp] != x) {
						row[ pointXProp] = x;
						rc ||= true;
					}
					if ( row[ pointYProp] != y) {
						row[ pointYProp] = y;
						rc ||= true;						
					}
				break;
				
				default:
			}
			
			return rc;
		}

		public function getPoint( row:Object):String {
			var temp:String = null;
			
			if ( pointMode == MODE_TBD) {
				// preset mode
				pointMode = MODE_NULL;
				for( var i:int = 0; i < propsPos.length; i++) {
					if ( checkProp( row, propsPos[ i].propx, propsPos[ i].propy)) {
						debug( "detected: "+pointXProp+", "+pointYProp);
						break;
					}
					debug( "detection failed: "+pointXProp+", "+pointYProp);
				}
			}
			
			switch( pointMode) {
				case MODE_OGC:
					temp = row[ pointXProp];
					debug( "mode OGC @ "+pointXProp+" : "+temp);
				break;

				case MODE_XY:
					temp = 'POINT( '+row[ pointXProp]+' '+row[ pointYProp]+")";
					debug( "mode XY @ "+pointXProp+" / "+pointYProp+" : "+temp);
				break;
				
				default:
			}
			
			return temp;
		}

		protected function checkProp( row:Object, propx:String, propy:String = null):Boolean {
			var rc:Boolean = false;
			
			debug( "check mapping: "+propx+"/"+propy);
			if ( propy == null) {
				if ( row.hasOwnProperty( propx)) {
					pointXProp = propx;
					pointMode = MODE_OGC;
					rc = true;
				}
			} else {
				if ( row.hasOwnProperty( propx) && row.hasOwnProperty( propy)) {
					pointXProp = propx;
					pointYProp = propy;					
					pointMode = MODE_XY;
					
					rc = true;
				}
			}
			return rc;
		}

		public function getGeometry( row:Object):String {
			var temp:String = null;
			
			if ( geomMode == MODE_TBD) {
				// preset mode
				geomMode = MODE_NULL;
				for( var i:int = 0; i < propsGeom.length; i++) {
					if ( row.hasOwnProperty( propsGeom[ i])) {
						geometryProp = propsGeom[ i];
						geomMode = MODE_OGC;
						debug( "detected: "+propsGeom[ i]);
						break;
					}
					debug( "geom detection failed: "+propsGeom[ i]);
				}
			}
			
			switch( geomMode) {
				case MODE_OGC:
					temp = row[ geometryProp];
				break;

				default:
			}
			
			return temp;
		}
		
		public function getToolTip( row:Object, prop:String):String {
			var temp:Array = new Array;
			
			var val:String = getText( row, prop);
			if ( val != null) temp.push( val);
			
			if ( temp.length == 0) {
				for( var key:String in row) {
					val = getText( row, key);
					if ( val != null) temp.push( val);
				}
			}
			
			debug( "get TT("+prop+"): "+temp.join( ' - '));
			return temp.join( ' - ');			
		}
		
		protected function getText( row:Object, key:String):String {
			debug( "mg getText: "+key);
			if ( key == pointXProp || key == pointYProp || key == geometryProp) return null;

			var val:Object = row.hasOwnProperty( key) ? row[ key] : null;
			if ( val is String) {
				debug( "  mg get: is string");
//				var rxp:RegExp = /[\d]{2,}/;
//				if ( String( val).match( rxp) != null) {
					debug( "  mg get: "+val);
					return String( val);
//				}
			}
			return null;
		}

		
		private function debug( txt:String):void {
//			trace( "DBG MG: "+txt);
		}
	}
}