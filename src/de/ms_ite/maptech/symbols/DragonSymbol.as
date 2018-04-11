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

	public class DragonSymbol extends Symbol {
/*
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#cross')]
		[Bindable]
		protected var symbolCross:Class;
*/		
		protected var icon:Image;
		protected var dragMode:Boolean = false;
		protected var iconURL:String;

		protected var bmd:BitmapData;		
		protected var bitmap:Bitmap;

		public function DragonSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);

//			addEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
//			addEventListener( MouseEvent.MOUSE_UP, mouseUp);
						
			icon = new Image();
//			icon.scaleContent = false;
			icon.addEventListener( Event.COMPLETE, handleComplete);
			//addChild( icon);

			bitmap = new Bitmap();
			addChild( bitmap);

//			addChild( new symbolCross());
			debug( "create.");
		}

		override public function destroy():void {
			if ( bitmap != null) {
				removeChild( bitmap);
				bitmap = null;
			}
			super.destroy();
			debug( "destroy");
			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener( MouseEvent.MOUSE_UP, mouseUp);
		}
		
		protected function handleComplete( evt:Event):void {
			debug( "loaded: "+icon.contentWidth+"x"+icon.contentHeight);
			icon.width = icon.contentWidth;
			icon.height = icon.contentHeight;
//			debug( "      : "+icon.width+"x"+icon.height);
//			debug( "      : "+width+"x"+height);
			
			if ( bmd == null) {
				bmd = new BitmapData( icon.width, icon.height, true, 0x00ffffff);
			}
			if ( bitmap != null) { 
				bitmap.bitmapData = bmd;
			
				bmd.fillRect( new Rectangle( 0, 0, bmd.width, bmd.height), 0x80ffffff);
				bmd.draw( icon);
			}
		}
/*		
		override public function set style( st:SymbolStyle):void {

			super.style = st;
		}
*/		
		protected function setIcon( path:String):void {
			try {
				if ( iconURL != path) {
					debug( "setting icon: "+path);
					if ( path != null) icon.load( path);
					
					iconURL = path;
				}
			} catch( e:Error) {
				debug( "error loading icon: "+e.toString());
			}
		}
		
		override public function update():void {
//			debug( "commit props!");
			super.update();

			bitmap.x = rowData.hasOwnProperty( 'off_x') ? parseFloat( rowData[ 'off_x']) : 0;
			bitmap.y = rowData.hasOwnProperty( 'off_y') ? parseFloat( rowData[ 'off_y']) : 0;

			if ( _selected) setIcon( rowData.hasOwnProperty( 'icon_sel') ? rowData[ 'icon_sel'] : null);
			else setIcon( rowData.hasOwnProperty( 'icon') ? rowData[ 'icon'] : null);

			toolTip = rowData.hasOwnProperty( 'tooltip') ? rowData[ 'tooltip'] : '';
			
			debug( "icon off: "+bitmap.x+", "+bitmap.y);
			debug( "tooltip: "+toolTip);
//			toolTip = 'SHIFT and drag to move. Click (+CTRL) to select.';
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

		override public function select( state:Boolean):void {	
			super.select( state);
			debug( "select "+state);
			update();
		}

		override public function highlight( state:Boolean):void {	
			super.highlight( state);
			scaleX = scaleY = _symbolStyle.icon.scale * ( _highlight ? 1.1 : 1.0);
			debug( "highlight "+state);
		}
	}
}