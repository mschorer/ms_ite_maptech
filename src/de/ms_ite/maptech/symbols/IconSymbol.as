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

	public class IconSymbol extends ScalingSymbol {
		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#circle')]
		[Bindable]
		protected var symbolCircle:Class;
		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#cross')]
		[Bindable]
		protected var symbolCross:Class;
		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#default')]
		[Bindable]
		protected var symbolDefault:Class;
		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#hexa')]
		[Bindable]
		protected var symbolHexa:Class;
		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#square')]
		[Bindable]
		protected var symbolSquare:Class;
		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#triangle')]
		[Bindable]
		protected var symbolTriangle:Class;

		[Embed(source='de/ms_ite/assets/document.png')]
		[Bindable]
		protected var mapSymClass:Class;
		
//		protected var icon:Bitmap;
		protected var icon:Sprite;

		protected var dragMode:Boolean = false;

		private var iconType:String;
		
		public function IconSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);

			iconType = '';

			addEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener( MouseEvent.MOUSE_UP, mouseUp);
		}

		override public function destroy():void {
			if ( icon != null) {
				removeChild( icon);
				icon = null;
			}
			super.destroy();
//			debug( "destroy");
			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener( MouseEvent.MOUSE_UP, mouseUp);
		}
		
		override public function set style( st:SymbolStyle):void {
			super.style = st;

			var iconTemp:String = st.icon.icon;
			try {
				if ( iconType != iconTemp) {
					debug( "setting icon: "+iconTemp);
					var c:Class = null;
					switch( iconTemp) {
						case 'Default': c = symbolDefault; break;
						case 'Circle': c = symbolCircle; break;
						case 'Square': c = symbolSquare; break;
						case 'Triangle': c = symbolTriangle; break;
						case 'Hexa': c = symbolHexa; break;
						case 'Cross': c = symbolCross; break;
					}
					if ( c != null) {
						if ( icon != null) removeChild( icon);
						icon = new c();
						addChild( icon);
					}
					iconType = iconTemp;
				}
			} catch( e:Error) {
				debug( "error loading icon: "+e.toString());
			}
			
			var r:Number, g:Number, b:Number;
			
			if ( rowData == null) return;
			
			if ( rowData.hasOwnProperty( st.data.scaleField) && !isNaN(st.data.scaleRowMin) && !isNaN(st.data.scaleRowMax)) {
				var vtxt:String = rowData[ st.data.scaleField];
				
				var relScale:Number = ( parseFloat( vtxt) - st.data.scaleRowMin ) / ( st.data.scaleRowMax - st.data.scaleRowMin);

				var r1:int = (st.data.colorFrom >> 16) & 255;
				var g1:int = (st.data.colorFrom >> 8) & 255;
				var b1:int = (st.data.colorFrom >> 0) & 255;
				
				var r2:int = (st.data.colorTo >> 16) & 255;
				var g2:int = (st.data.colorTo >> 8) & 255;
				var b2:int = (st.data.colorTo >> 0) & 255;
				
				r = ( r1 + relScale * ( r2 - r1)) / 255;
				g = ( g1 + relScale * ( g2 - g1)) / 255;
				b = ( b1 + relScale * ( b2 - b1)) / 255;
				
				debug( "relScale: "+relScale+" : "+r+"/"+g+"/"+b);
			} else {
				r = ((st.icon.color >> 16) & 255) / 255;
				g = ((st.icon.color >> 8) & 255) / 255;
				b = (st.icon.color & 255) / 255;
				debug( "color("+st.icon.color+"): "+r+"/"+g+"/"+b);
			}
//				var col:uint = 0xff000000 | (r << 16) | (g << 8) | (b);

			var desat:Array = new Array ( r, 0, 0, 0, 0,
			  			 				0, g, 0, 0, 0,
			   			 				0, 0, b, 0, 0,
			    		 				0, 0, 0, 1, 0 );

			filters = [ new ColorMatrixFilter( desat)];
		}
		
		protected function mouseDown( evt:MouseEvent):void {
//			debug( "mdown "+evt.ctrlKey);
			
			if ( evt.shiftKey) {
				dragMode = true;
				startDrag();
				evt.stopPropagation();
			}
		}

		protected function mouseUp( evt:MouseEvent):void {
//			debug( "mup @ "+dragMode);
			
			if ( dragMode) {
				dragMode = false;
				
				stopDrag();
				
				var newPos:Point = SymbolLayer( parent).screen2map( x, y);
				
				var rc:Boolean = mapGlue.setPoint( rowData, newPos.x, newPos.y);				
				SymbolLayer( parent).updateRow( rowData);
//				debug( "upd sym "+rc);
			}			
		}

		override public function highlight( state:Boolean):void {	
			super.highlight( state);
			scaleX = scaleY = _symbolStyle.icon.scale * dataScale * ( _highlight ? 1.4 : 1.0);
		}
		
		override protected function debug( txt:String):void {
//			trace( "icSym: "+txt);
		}
	}
}