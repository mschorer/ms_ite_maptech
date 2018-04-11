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

	public class GeomSymbol extends Symbol {
		protected var needRedraw:Boolean = true;
		
		public function GeomSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);
			
			addEventListener( Event.RENDER, doRender);
		}

		override public function destroy():void {
			removeEventListener( Event.RENDER, doRender);
			super.destroy();
		}
		
		override public function set resolution( r:Point):void {
			if ( _resolution== null || ! r.equals( _resolution)) needRedraw = true;
			super.resolution = r;
		}

		override public function set style( st:SymbolStyle):void {

			var r:Number, g:Number, b:Number;
			
			if ( rowData == null) return;
			
			if ( rowData.hasOwnProperty( _symbolStyle.data.scaleField) && !isNaN(_symbolStyle.data.scaleRowMin) && !isNaN(_symbolStyle.data.scaleRowMax)) {
				var vtxt:String = rowData[ _symbolStyle.data.scaleField];
				
				var relScale:Number = ( parseFloat( vtxt) - _symbolStyle.data.scaleRowMin ) / ( _symbolStyle.data.scaleRowMax - _symbolStyle.data.scaleRowMin);

				var r1:int = (_symbolStyle.data.colorFrom >> 16) & 255;
				var g1:int = (_symbolStyle.data.colorFrom >> 8) & 255;
				var b1:int = (_symbolStyle.data.colorFrom >> 0) & 255;
				
				var r2:int = (_symbolStyle.data.colorTo >> 16) & 255;
				var g2:int = (_symbolStyle.data.colorTo >> 8) & 255;
				var b2:int = (_symbolStyle.data.colorTo >> 0) & 255;
				
				r = ( r1 + relScale * ( r2 - r1)) / 255;
				g = ( g1 + relScale * ( g2 - g1)) / 255;
				b = ( b1 + relScale * ( b2 - b1)) / 255;
				
				debug( "relScale: "+relScale+" : "+r+"/"+g+"/"+b);
			} else {
				/*
				r = ((_symbolStyle.icon.color >> 16) & 255) / 255;
				g = ((_symbolStyle.icon.color >> 8) & 255) / 255;
				b = (_symbolStyle.icon.color & 255) / 255;
				*/
				r = g = b = 1;
			}
//				var col:uint = 0xff000000 | (r << 16) | (g << 8) | (b);

			var desat:Array = new Array ( r, 0, 0, 0, 0,
			  			 				0, g, 0, 0, 0,
			   			 				0, 0, b, 0, 0,
			    		 				0, 0, 0, 1, 0 );

			filters = [ new ColorMatrixFilter( desat)];

			super.style = st;
		}
		

		override public function update():void {
//			debug( "commit props!");
			super.update();
			if ( rowData == null) return;

			toolTip = '';	//rowData.hasOwnProperty( 'tooltip') ? rowData[ 'tooltip'] : '';

			var geom:String = mapGlue.getGeometry( rowData);
			geometry.parse( geom);
			drawGraphics();
//			toolTip = 'SHIFT and drag to move. Click (+CTRL) to select.';
		}
		
		protected function doRender( evt:Event):void {
			if ( needRedraw) drawGraphics();	
		}
		
		public function drawGraphics():void {
			debug( "redraw "+geometry.getMBR());
			var res:Point = Layer( parent).resolution;
			var zoomScale:Number = scaleX;
	
			var geoStyle:GeometryStyle = ( _selected || _highlight) ? _symbolStyle.selected : _symbolStyle.normal;
			geometry.draw( graphics, getOrigin(), _projection, res, _symbolStyle.scale( geoStyle.line.width, zoomScale, res), geoStyle);
		
			needRedraw = false;	
//			debug( "lsize: "+textLabel.width+"/"+textLabel.textWidth+" "+textLabel.height+"/"+textLabel.textHeight);
		}

		override public function select( state:Boolean):void {
			super.select( state);
			needRedraw = true;
			stage.invalidate();
		}
		
		override public function highlight( state:Boolean):void {	
			super.highlight( state);
			needRedraw = true;
			stage.invalidate();
		}
	}
}