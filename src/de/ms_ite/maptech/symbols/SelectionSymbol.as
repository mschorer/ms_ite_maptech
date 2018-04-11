/*
 *
 * the base class for a symbol
 * started on 20050328
 *
 */

package de.ms_ite.maptech.symbols {

//	import de.msite.ZfGis;
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.ogc.*;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.controls.*;
	import mx.core.*;
	import mx.effects.*;
	import mx.events.*;
	import mx.managers.*;

	public class SelectionSymbol extends GeomSymbol {
		
		public var fillColor:int;
		
		public function SelectionSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);
			
			fillColor = 0x00ff00;
		}

		override public function drawGraphics():void {
			debug( "redraw "+rowData.x+","+rowData.y+" @ "+res);
			
			var res:Point = Layer( parent).resolution;
			
			if ( rowData != null) {
				graphics.clear();
				graphics.lineStyle( 2, 0);
				graphics.beginFill( fillColor, 0.2);
				graphics.drawCircle( 0, 0, rowData.radius / res.x);
				graphics.endFill(); 
			}

//			needRedraw = false;	
//			debug( "lsize: "+textLabel.width+"/"+textLabel.textWidth+" "+textLabel.height+"/"+textLabel.textHeight);
		}
		
		public function drawLinestring( graphics:Graphics, origin:Point, res:Point, style:GeometryStyle, points:Array):void {
	//		debug( "drawLinestring: "+graphics+"/"+origin+"/"+res+" #"+points.length+" : "+style.line.alpha);
			
			var x:Number = ( points[0].x - origin.x) / res.x;
			var y:Number = ( origin.y - points[0].y) / res.y;
			graphics.moveTo( x, y);
			
			var pcnt:Number = points.length;
			
			if ( pcnt > 1) {
				for( var i:int=1; i < pcnt; i++) {
					x = ( points[i].x - origin.x) / res.x;
					y = ( origin.y - points[i].y) / res.y;
					graphics.lineTo( x, y);
	//				debug( "lineTo: "+x+","+y);
				}
			} else {
					graphics.lineTo( x+1, y);
					graphics.lineTo( x-1, y);
					graphics.lineTo( x, y+1);
					graphics.lineTo( x, y-1);
			}
		}
	}
}