package de.ms_ite.maptech.projections {
	public class Projection {
		
		import de.ms_ite.maptech.*;
		
		import flash.geom.*;

		public static var PROJ_UNKNOWN:int = -1;
		public static var PROJ_LINEAR:int = 0;
		public static var PROJ_WGS84:int = 1;
		
		protected var projectionType:int;
		
		public var bounds:Bounds;
		public var aspect:Number;
		
		public function Projection() {
			projectionType = PROJ_LINEAR;
			aspect = 1;
		}
		
		public function screen2coord( p:Point, _viewport:Bounds, res:Point):Point {

			var temp:Point = new Point();
			
			temp.x = p.x * res.x + _viewport.left;
			temp.y = _viewport.top - p.y * res.y;

			return temp;
		}
/*		
		public function pixel2coord( p:Point, bounds:Bounds, res:Number):Point {
			var temp:Point = new Point();
			
			temp.x = p.x * res + bounds.left;
			temp.y = bounds.top - p.y * res;

			return temp;
		}
*/
		public function coord2pixel( p:Point, bounds:Bounds, res:Point):Point {
			var temp:Point = new Point();
			
			temp.x = ( p.x - bounds.left) / res.x;
			temp.y = ( bounds.top - p.y) / res.y;
			
			return temp;
		}
		
	    //-----------------------------------------------------------------
	    
	    public function linBounds( b:Bounds):Bounds {
	    	return b;
	    }
	    
	    public function linearize( p:Point):Point {
	        return new Point( linearizeX( p.x), linearizeY( p.y));
	    }
	    
	    public function linearizeDeg( p:Point):Point {
	        return new Point( toDeg( linearizeX( toRad( p.x))), toDeg( linearizeY( toRad( p.y))));
	    }

	    public function linearizeX( x:Number):Number {
	        return x;
	    }
	    
	    public function linearizeY( y:Number):Number {
	        return y;
	    }
	    
	    //-----------------------------------------------------------------

	    public function delinBounds( b:Bounds):Bounds {
	    	return b;
	    }
	    
	    public function delinearize( p:Point):Point {
	        return new Point( delinearizeX( p.x), delinearizeY( p.y));
	    }
	    
	    public function delinearizeX( x:Number):Number {
	        return x;
	    }
	    
	    public function delinearizeY( y:Number):Number {
	        return y;
	    }
	    
	    //-----------------------------------------------------------------
		public function toRad( x:Number):Number {
			return ( x * Math.PI / 180);
		}
		
		public function toDeg( x:Number):Number {
			return ( x / ( Math.PI / 180));
		}

	    //-----------------------------------------------------------------
		public function toString():String {
			return "linearLinear";
		}

		protected function debug( txt:String):void {
//			trace( "DBG PJ: "+txt);
		}
	}
}