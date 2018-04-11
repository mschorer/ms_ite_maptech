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
	
	public class OGCPolygon extends OGCLinestring {
		private var inner_rings:Array;
		
		public function OGCPolygon( wkt:String, from:Number) {
			type = POLYGON;
			inner_rings = new Array();
			super( wkt, from);
//			parse( wkt, from);
		}
		
		override public function toString( prependType:Boolean=false):String {
			var temp:String = '(('+parr2string( points)+')';
			for( var i:Number = 0; i < inner_rings.length; i++) {
				temp += '('+parr2string( inner_rings[i])+')';
			}
			temp += ')';
			
			return (prependType ? 'POLYGON'+temp : temp);
		}
	
		override public function parse( wkt:String='', from:int=0):int {
	//		var from:Number = getContainerSize( wkt, 0)+1;
			var outer:String = getContainer( wkt, from);
			parsePList( outer, 0, points);
			debug( "     outer:"+outer);
	//		debug( "polygon outer: "+points.join( ', '));
			
			var from:int = outer.length+1;
			while ( from < wkt.length) {
				var len:Number = getContainerSize( wkt, from);
				if ( len < 0) break;
				
				var temp:String = getContainer( wkt, from);
				
				var ring:Array = new Array();
				var rc:int = parsePList( temp, 0, ring);
				inner_rings.push( ring);
	
				debug( "     inner:"+temp);
	//			debug( "  inner: "+ring.join( ', '));
				from = len+1;
			}
			
			return rc;
		}
	
		override public function drawGraphics( graphics:Graphics, origin:Point, proj:Projection, res:Point, lineWidth:Number, style:GeometryStyle):void {
			debug( "polygon: draw.");
	
			if ( style.surface.fill == 1) graphics.beginFill( style.surface.color, style.surface.alpha);
			super.drawGraphics( graphics, origin, proj, res, lineWidth, style);
	
			// as we import from shape, all holes are in ccw order
			for( var i:Number = 0; i < inner_rings.length; i++) {
				super.drawLinestring( graphics, origin, proj, res, style, inner_rings[ i]);
			}
			if ( style.surface.fill == 1) graphics.endFill();
		}
	}
}
//------------------------------------------------------------------------------