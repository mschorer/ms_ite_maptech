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
	
//	import de.msite.Point;
//	import de.ms_ite.ogc.*;
//	import de.ms_ite.symbols.*;
	
	public class OGCLinestring extends OGCGeometry {
		protected var points:Array;
		
		public function OGCLinestring( wkt:String='', from:Number=0) {
			debug( "LN create: "+wkt);
			points = new Array();
			type = LINESTRING;
			super( wkt, from);
			
//			parse( wkt, from);
		}
		
		override public function getOrigin():Point {
			return points[0];
		}
	
		override public function toString( prependType:Boolean=false):String {
			var temp:String = '('+parr2string( points)+')';
			return (prependType ? 'LINESTRING'+temp : temp);
	
		}
		
		public function parr2string( parr:Array):String {
			var temp:String = '';
			var plen:Number = parr.length;
			for( var i:Number=0; i < plen; i++) {
				if ( i > 0) temp += ',';
				temp += parr[i].x+' '+parr[i].y;
			}
			
			return temp;
		}
	
	
		override public function parse( wkt:String='', from:int=0):int {
	//		debug( "linestring:["+wkt+"]");
			return parsePList( wkt, from, points);
		}
	
		override public function drawGraphics( graphics:Graphics, origin:Point, proj:Projection, res:Point, lineWidth:Number, style:GeometryStyle):void {
			debug( "linestring: draw. "+points.length);
			
			graphics.lineStyle( lineWidth, style.line.color, style.line.alpha);
			drawLinestring( graphics, origin, proj, res, style, points);
		}
	}
}
//------------------------------------------------------------------------------