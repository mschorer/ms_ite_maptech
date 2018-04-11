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

	public class BitmapSymbol extends Symbol {

		protected var bmd:BitmapData;		
		protected var bitmap:Bitmap;		

		public function BitmapSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);

			bitmap = new Bitmap();
			addChild( bitmap);
		}

		override public function update():void {
//			debug( "commit props!");
			super.update();
			if ( rowData == null) return;

			var geom:String = mapGlue.getGeometry( rowData);
			geometry.parse( geom);

//			toolTip = 'SHIFT and drag to move. Click (+CTRL) to select.';
		}		
		
		public function draw( di:DisplayObject):void {
			var w:Number = di.width;	// * scale;
			var h:Number = di.height;	// * scale;
			var scale:Number = 1.0;

			if ( bmd != null && ( w != bmd.width || h != bmd.height)) {
				bmd.dispose();
				bmd = null;
			}
			
			if ( bmd == null) {
				bmd = new BitmapData( w, h, true, 0x00ffffff);
			}
			bitmap.bitmapData = bmd;
			
			bitmap.x = -bmd.width/2;
			bitmap.y = -bmd.height/2;
				
			bmd.fillRect( new Rectangle( 0, 0, bmd.width, bmd.height), 0x00ffffff);			
			bmd.draw( di, new Matrix( scale, 0, 0, scale));			
		}
	}
}