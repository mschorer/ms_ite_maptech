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
	import de.ms_ite.maptech.symbols.styles.*;
	import de.ms_ite.ogc.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.core.*;
	import mx.effects.*;
	import mx.events.*;
	import mx.managers.*;

	public class IconImageSymbol extends Symbol {
/*		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#cross')]
		[Bindable]
		protected var symbolCross:Class;
*/
//		protected var icon:Bitmap;
		protected var icon:Image;
		
		protected var bmd:BitmapData;		
		protected var bitmap:Bitmap;
				
		protected var dragMode:Boolean = false;

		private var iconType:String;
		
		public function IconImageSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);

			iconType = '';

			addEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener( MouseEvent.MOUSE_UP, mouseUp);

			icon = new Image();
			icon.addEventListener( Event.COMPLETE, imgDone);
//			icon.autoLoad = true;
			icon.scaleContent = false;
//			addChild( icon);
			debug( "create icon: "+icon);
//			debug( "add icon: "+iconTemp+" / "+findRoot().iconMapList[ iconTemp]);

			bitmap = new Bitmap();
			addChild( bitmap);
			bitmap.x = -8;
			bitmap.y = -33;
			
//			addChild( new symbolCross());
		}

		override public function init( row:Object):void {
//			debug( "init "+this);

			rowData = row;
			toolTip = row.company+"\n"+'SHIFT and drag to move. Click to select.';

			if ( style == null) style = new SymbolStyle();
			else style = _symbolStyle;

			update();
		}
		
		protected function findRoot():Object {
			var temp:Object = parent;
			while( temp != null) {
				if ( temp is Application) return temp;
				temp = temp.parent;
			}
			return null;
		}

		override public function destroy():void {
			if ( icon != null) {
				removeChild( bitmap);
				icon = null;
			}
			super.destroy();
//			debug( "destroy");
			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener( MouseEvent.MOUSE_UP, mouseUp);
		}
		
		private function imgDone( e:Event):void {
//			debug( "done: "+icon.contentWidth+"x"+icon.contentHeight);
			
			if ( bmd == null && icon != null) {
				bmd = new BitmapData( icon.contentWidth, icon.contentHeight, true, 0x00ffffff);
			}
			bitmap.bitmapData = bmd;
			
//			bmd.fillRect( new Rectangle( 0, 0, bmd.width, bmd.height), 0x80ffffff);
			bmd.draw( icon);
		}
		
		override public function set style( st:SymbolStyle):void {
//			debug( "st: "+st.toXML().toString());
			var iconTemp:String = st.icon.icon;
			try {
				if ( iconType != iconTemp) {
					debug( "setting icon: "+iconTemp);
/*
					var ict:Sprite = findRoot().getIconFromLib( iconTemp, true);
					if ( ict != null) {
						if ( icon != null) removeChild( icon);
						addChild( ict);
						icon = ict;
						icon.doubleClickEnabled = true;
						debug( "add icon: "+ict);
					}
*/
					icon.load( findRoot().iconMapList[ iconTemp]);
					debug( "add icon: "+iconTemp+" / "+icon.source);
					
					iconType = iconTemp;
/*
					debug( "iconColor: "+style.icon.color);
					var testColor = new Color( icon.bg);
*/
				}
			} catch( e:Error) {
				debug( "error loading icon: "+e.toString());
				icon == null;
			}
			
			var r:Number, g:Number, b:Number;
			
			if ( rowData == null) return;
/*			
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

			if ( ( icon != null) ? icon.hasOwnProperty( 'bg') : false) {
				var ct:ColorTransform = MovieClip( Object( icon).bg).transform.colorTransform;
				if ( ct == null) ct = new ColorTransform();
				ct.color = st.icon.color; 
				MovieClip( Object( icon).bg).transform.colorTransform = ct;
			}
*/
			debug( "donest: "+x+","+y+" / "+width+"x"+height);
			super.style = st;
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
			
			dispatchEvent( new MouseEvent( MouseEvent.CLICK));			
		}

		override public function highlight( state:Boolean):void {	
			super.highlight( state);
			scaleX = scaleY = _symbolStyle.icon.scale * /*dataScale **/ ( _highlight ? 1.4 : 1.0);
			debug( "scale: "+scaleX);
		}

		override protected function debug( txt:String):void {
			trace( "DBG ILS("+name+"): "+txt);
		}					

	}
}