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
	
	import mx.controls.*;
	import mx.core.*;
	import mx.effects.*;
	import mx.events.*;
	import mx.managers.*;

	public class IconDrawSymbol extends Symbol {

		protected var icon:Sprite;
		protected var label:TextField;
		protected var dragMode:Boolean = false;
		
		protected var calloutOffsetX:int = 0;
		protected var calloutOffsetY:int = 5;
		
		protected var hitAreaOffset:int = 0;

		protected var calloutPointerWidth:int = 7;
		protected var cornerRadius:int = 4;
		
		protected var alphaOver:Number = 1.0;
		protected var alphaOut:Number = 0.8;
		
		protected var abbrevLen:int = 6;

		public function IconDrawSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);

//			addEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener( MouseEvent.MOUSE_UP, mouseUp);
			
			icon = new Sprite();
			icon.width = 50;
			icon.height = 30;
			icon.y = -icon.height;
			
			addChild( icon);
			
			label = new TextField();
			label.selectable = false;
			label.x = 4;
			label.y = -20;
			label.width = 10;
			label.height = 10;
			
			var format:TextFormat = new TextFormat();
            format.font = "Verdana";
//            format.color = 0xffffff;
            format.size = 9;

            label.defaultTextFormat = format;
			addChild( label);
			
			alpha = alphaOut;
		}

		override public function destroy():void {
			super.destroy();
		
			if ( icon != null) {
//				removeChild( icon);
				icon = null;
			}

//			debug( "destroy");
//			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener( MouseEvent.MOUSE_UP, mouseUp);
		}
		
		override public function update():void {
//			debug( "commit props!");

			super.update();
			var geom:String = mapGlue.getGeometry( rowData);
			geometry.parse( geom);

			alpha = _highlight ? alphaOver : alphaOut;
			
			var title:String = ( rowData['title'] == null) ? '' : rowData['title'];
			label.htmlText = (_highlight || title.length < abbrevLen+3) ? title : ( title.substr( 0, abbrevLen)+'...');
			
			var metrics:TextLineMetrics = label.getLineMetrics(0);
			label.width = metrics.width + 4;
			label.height = metrics.height + metrics.descent + 4;
			label.y = -6 - label.height;

			var tt:String = ((rowData['pubDate'] != undefined) ? (rowData['pubDate']+'\n') : '');
			if ( rowData['categories'] != undefined && rowData['categories'] != '') tt += "("+rowData['categories']+")\n"; 
			tt += rowData['title'];
			
			toolTip = tt;
			
			updateDisplayList( label.width + 21, label.height + 21);

			icon.width = label.width + 8;
			icon.height = label.height + 8;
			icon.y = -icon.height;
		}

		protected function mouseUp( evt:MouseEvent):void {
//			debug( "mup @ "+dragMode);
			
			var url:String = rowData['link'];

			if ( url != null ? (url.length > 0) : false) {
				debug( "going to: "+url);
				debug( "bye.");
//				navigateToURL( new URLRequest( url));
			}			
			
			var me:MouseEvent = new MouseEvent( MouseEvent.CLICK, true);
			dispatchEvent( me);

/*
			if ( dragMode) {
				dragMode = false;
				
				stopDrag();
				
				var newPos:Point = SymbolLayer( parent).screen2map( x, y);
				debug( "set point1: "+rowData['location']);
				var rc:Boolean = mapGlue.setPoint( rowData, newPos.x, newPos.y);	
				
				debug( "set point2: "+rowData['location']);			
				SymbolLayer( parent).updateRow( rowData);
//				debug( "upd sym "+rc);
			}
*/			
		}
/*		
	
		protected function mouseDown( evt:MouseEvent):void {
//			debug( "mdown "+evt.ctrlKey);
/*			
			if ( evt.shiftKey) {
				dragMode = true;
				startDrag();
				evt.stopPropagation();
			}
* /
		}
*/		

		override protected function rollOver( evt:MouseEvent):void {
			debug( "over");
			highlight( true);

			var me:ToolTipEvent = new ToolTipEvent( ToolTipEvent.TOOL_TIP_SHOW, true);
			dispatchEvent( me);
/*			var me:MouseEvent = new MouseEvent( MouseEvent.MOUSE_OVER, true);
			dispatchEvent( me);
*/		}
		
		override protected function rollOut( evt:MouseEvent):void {
			debug( "out");
			highlight( false);

			var me:ToolTipEvent = new ToolTipEvent( ToolTipEvent.TOOL_TIP_HIDE, true);
			dispatchEvent( me);
/*			var me:MouseEvent = new MouseEvent( MouseEvent.MOUSE_OUT, true);
			dispatchEvent( me);
*/		}

		override public function select( state:Boolean):void {	
			super.select( state);
			if ( state) rollOver( null);
			debug( "select: "+state);
		}
/*				
		override public function highlight( state:Boolean):void {	
//			debug( "highlight: "+_highlight+" > "+state);
			super.highlight( state);
			update();
		}
*/		
		protected function updateDisplayList(w:Number, h:Number):void {
			
//			debug( "draw: "+w+" x "+h);	
			//
			var fillType:String = GradientType.LINEAR;
	  		var colors:Array = _selected ? [ 0xFFE4CA, 0xFFCC99] : [ 0xCAE4FF, 0x99CCFF];
	  		var alphas:Array = [0.9, 0.9];
	  		var ratios:Array = [0x00, 0x80];
	  		var matr:Matrix = new Matrix();
	  		matr.createGradientBox(w, h, Math.PI/2, 0, 0);
	 		var spreadMethod:String = SpreadMethod.PAD;
	 		
			var dropShadowAlpha:Number = 0.7;
			var shadowAlpha:Number = 0.7;
			
			filters = [ new DropShadowFilter( 3, 45, 0, dropShadowAlpha) ];
			
			if ( icon == null) return;

			var g:Graphics = icon.graphics;
			g.clear();
			
			switch( 3) {				
				case 0:
					// hit area
					g.beginFill(0xFF0000, 0);
					g.moveTo(0, calloutOffsetY - hitAreaOffset)
					g.lineTo(w + calloutOffsetX, 0);
					g.lineTo(w - calloutOffsetX, h);		 
					g.lineTo(0, h + hitAreaOffset);
		
					g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
		
					// border 
		
					g.drawRoundRectComplex(0,
										   calloutOffsetY,
										   w-calloutOffsetX,
									       h-calloutOffsetY,
									       cornerRadius,
										   0,
										   cornerRadius,
										   cornerRadius
										   ); 
		
					// bottomLeft pointer 
		
		 			g.moveTo(w - calloutPointerWidth- calloutOffsetX, calloutOffsetY);
					g.lineTo(w + calloutOffsetX, 0); // tip
					g.lineTo(w - calloutOffsetX, calloutOffsetY);
					g.endFill();
				break;
				
				case 1:
					g.beginFill(0xFF0000, 0);
					g.moveTo(0, -hitAreaOffset)
					g.lineTo(w - calloutOffsetX, 0 );
					g.lineTo(w + calloutOffsetX, h + calloutOffsetY);		 
					g.lineTo(0, h - calloutOffsetY + hitAreaOffset);	
					
					this.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
		
					// border 
		
					g.drawRoundRectComplex(0,					
										   0,
										   w-calloutOffsetX,
									       h-calloutOffsetY,
									       cornerRadius,
										   cornerRadius,
										   cornerRadius,
										   0
										   ); 
		
					// topLeft pointer 
		
		 			g.moveTo(w-calloutOffsetX, h-calloutOffsetY);
					g.lineTo(w + calloutOffsetX, h + calloutOffsetY); // tip
					g.lineTo(w - calloutOffsetX - calloutPointerWidth, h-calloutOffsetY);
					g.endFill();
				break;
				
				case 2:
					g.beginFill(0xFF0000, 0);
					g.moveTo(0, 0)
					g.lineTo(w, calloutOffsetY - hitAreaOffset);
					g.lineTo(w, h + hitAreaOffset);		 
					g.lineTo(calloutOffsetX, h);	

					g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
	
					// border 
					g.drawRoundRectComplex(calloutOffsetX,					
										   calloutOffsetY,
										   w-calloutOffsetX,
									       h-calloutOffsetY,
									       0,
										   cornerRadius,
										   cornerRadius,
										   cornerRadius
										   ); 
	
					// bottomRight pointer 
	
	 				g.moveTo(calloutOffsetX, calloutOffsetY);
					g.lineTo(0,0); // tip
					g.lineTo(calloutOffsetX + calloutPointerWidth, calloutOffsetY);
					g.endFill(); 
				break;
				
				case 3:
									// hit area
					g.beginFill(0xFF0000, 0);
					g.moveTo(calloutOffsetX - hitAreaOffset/4, -hitAreaOffset/4)
					g.lineTo(w + hitAreaOffset, -hitAreaOffset);
					g.lineTo(w + hitAreaOffset, h - calloutOffsetY + hitAreaOffset);		 
					g.lineTo(0, h + calloutOffsetY );	
			 					
					g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
								
					// border 	
					g.drawRoundRectComplex(calloutOffsetX,					
										   0,
										   w-calloutOffsetX,
									       h-calloutOffsetY,
									       cornerRadius,
										   cornerRadius,
										   0,
										   cornerRadius
										   ); 
	
					// topRight pointer 
	 				g.moveTo(calloutOffsetX, h-calloutOffsetY);
					g.lineTo(0, calloutOffsetY + h);
					g.lineTo(calloutOffsetX + calloutPointerWidth, h-calloutOffsetY);
					g.endFill(); 
				break; 
			}
		}

/*
		override public function highlight( state:Boolean):void {	
			super.highlight( state);
			
			var scale:Number = symbolStyle.icon.scale * dataScale * ( _highlight ? 1.4 : 1.0);
			
			icon.width = scale * 50;
			icon.height = scale * 30;
			icon.y = -icon.height;
//			scaleX = scaleY = scale;
		}
*/
/*		override protected function debug( txt:String):void {
			trace( "DBG IDSymbol("+this.name+"): "+txt);
		}
*/	}
}