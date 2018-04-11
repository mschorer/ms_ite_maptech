package de.ms_ite.maptech.projections {
	
	public class ProjectionMercator extends Projection {
		
		import de.ms_ite.maptech.*;
		import flash.geom.*;

		protected var tMatrix:Matrix;
						
		public function ProjectionMercator() {
			super();
			
			projectionType = PROJ_WGS84;
			
			tMatrix = new Matrix( 1 / ( 2 * Math.PI), 0, 0, -1 / (2 * Math.PI), 0.5, 0.5);
			
			bounds = new Bounds();
			bounds.left =  - Math.PI;
			bounds.bottom = toRad( -85.05112878);
			bounds.right = Math.PI;
			bounds.top = toRad( 85.05112878);
		}
		
		override public function coord2pixel( p:Point, bounds:Bounds, res:Point):Point {
			var xp:Point = linearize( new Point( toRad( p.x), toRad( p.y)));

			return super.coord2pixel( new Point( p.x, toDeg( linearizeY( toRad( p.y)))), bounds, res);
		}
		
		override public function screen2coord( p:Point, _viewlinear:Bounds, res:Point):Point {
			debug( "drop @ "+p);
			var temp:Point = super.screen2coord( p, _viewlinear, res);

			debug( "drop dlin @ "+temp);			
			var xr:Point = new Point( temp.x, toDeg( delinearizeY( toRad( temp.y))));

			debug( " -- drop  : "+xr);
			return xr;
		}

	    //-----------------------------------------------------------------

	    override public function linBounds( b:Bounds):Bounds {
	    	var nb:Bounds = new Bounds();
	    	nb.left = b.left;
	    	nb.right = b.right;
	    	nb.top = toDeg( linearizeY( toRad( b.top)));
	    	nb.bottom = toDeg( linearizeY( toRad( b.bottom)));
	    	
	    	return nb;
	    }
	    
	    override public function delinBounds( b:Bounds):Bounds {
	    	var nb:Bounds = new Bounds();
	    	nb.left = b.left;
	    	nb.right = b.right;
	    	nb.top = toDeg( delinearizeY( toRad( b.top)));
	    	nb.bottom = toDeg( delinearizeY( toRad( b.bottom)));
	    	
	    	debug( "conv:\n"+b+"\n"+nb);
	    	
	    	return nb;
	    }

	    override public function linearizeY( y:Number):Number {
	    	if ( bounds.bottom <= y && y <= bounds.top) {
//		    	debug( "  in : "+bounds.bottom+" <= "+y+" <= "+bounds.top);
	    		return Math.log( Math.tan(0.25 * Math.PI + 0.5 * y)) / ( Math.PI / bounds.top);
	    	} else {		
//	    		debug( "  out: "+bounds.bottom+" <= "+y+" <= "+bounds.top);
	    		return y;
	    	}
	    }
	    
	    override public function delinearizeY( y:Number):Number {
	    	if ( bounds.bottom <= y && y <= bounds.top) {
//	    		debug( "  in : "+bounds.bottom+" <= "+y+" <= "+bounds.top);
	    		return 2 * Math.atan( Math.pow( Math.E, y * ( Math.PI / bounds.top))) - 0.5 * Math.PI;
	    	} else {
//	    		debug( "  out: "+rebounds.bottom+" <= "+y+" <= "+rebounds.top);
	    		return y;
	    	}
	    }	    

	    //-----------------------------------------------------------------

		override public function toString():String {
			return "projMercator";
		}
		
		override protected function debug( txt:String):void {
//			trace( "DBG PJmerc: "+txt);
		}
	}
}