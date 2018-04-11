/*
 *
 * ogc datatype: polygon
 * (c) ms@ms-ite.de
 *
 * started on 20061128
 *
 */

package de.ms_ite.ogc {

	import de.ms_ite.maptech.projections.Projection;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import flash.display.*;
	import flash.geom.*;

	public class OGCPoint extends OGCGeometry {
		private var p:Point;
		
		public function OGCPoint( wkt:String='', from:Number=0) {
			debug( "PNT create: "+wkt);
			type = POINT;
//			parse( wkt, from);
			super( wkt, from);
		}
		
		override public function getOrigin():Point {
			return p;
		}
	
		override public function toString( prependType:Boolean=false):String {
			var temp:String = p.x+' '+p.y;
			return (prependType ? 'POINT('+temp+')' : temp);
		}
	
		override public function parse( wkt:String='', from:int=0):int {
	//		debug( "point:["+wkt+"]");
			p = new Point();
			return parsePoint( wkt, from, p);
		}
	
		override public function drawGraphics( graphics:Graphics, origin:Point, proj:Projection, res:Point, lineWidth:Number, style:GeometryStyle):void {
			debug( "point: draw.");

//			graphics.lineStyle( lineWidth, style.line.color, style.line.alpha);
//			drawLinestring( graphics, origin, proj, res, style, new Array( p));
		}
	}
}
//------------------------------------------------------------------------------