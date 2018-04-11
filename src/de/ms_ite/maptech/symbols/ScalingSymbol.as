/*
 *
 * the base class for a symbol
 * started on 20050328
 *
 */

package de.ms_ite.maptech.symbols {

//	import de.msite.ZfGis;
	import de.ms_ite.*;
	import de.ms_ite.ogc.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
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

	public class ScalingSymbol extends Symbol {
		
		protected var dataScale:Number;

		function ScalingSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);
		}

		override public function update():void {
			debug( "commit props!");
			super.update();
			if ( rowData == null) return;

			dataScale = 1;
				
			if ( hasOwnProperty( _symbolStyle.data.scaleField) && !isNaN(_symbolStyle.data.scaleRowMin) && !isNaN(_symbolStyle.data.scaleRowMax)) {
				var vtxt:String = rowData[ _symbolStyle.data.scaleField];
				
				var relScale:Number = ( parseFloat( vtxt) - _symbolStyle.data.scaleRowMin ) / ( _symbolStyle.data.scaleRowMax - _symbolStyle.data.scaleRowMin);
				dataScale = _symbolStyle.data.scaleMin + relScale * ( _symbolStyle.data.scaleMax - _symbolStyle.data.scaleMin);

				debug( "relScale: "+relScale);
			}
			
			scaleX = scaleY = _symbolStyle.icon.scale * dataScale;
			alpha = _symbolStyle.icon.alpha;
		}		
		
		override public function highlight( state:Boolean):void {	
			super.highlight( state);
		}
	}
}