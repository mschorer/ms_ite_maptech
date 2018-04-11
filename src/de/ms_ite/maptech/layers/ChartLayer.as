package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.events.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.symbols.*;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.xml.*;
	
	import mx.collections.*;
	import mx.controls.*;
	import mx.events.*;
	import mx.managers.*;
	import mx.utils.*;

	public class ChartLayer extends SymbolLayer {

		protected var _renderQueue:ChartRenderQueue;

		public function ChartLayer() {
			super();
			
			symbolClass = de.ms_ite.maptech.symbols.BitmapSymbol;
			
			_selectedItems = new Array();
			_selectedSymbols = new Array();
			
			_renderQueue = new ChartRenderQueue();
			_renderQueue.addEventListener( RenderEvent.RENDER_COMPLETE, renderingComplete);
			addChild( _renderQueue);
		}		

		override public function set style( st:SymbolStyle):void {
			super.style = st;
			_renderQueue.style = st;
		}
				
		//-------------------------------------------------------------------------------
		// drawing functions
		
		override protected function addItem( item:Object):Symbol {
			_renderQueue.queue( item);
			
			return super.addItem( item);
		}
		
		override protected function updateItem( item:Object, doUpdate:Boolean):void {
			super.updateItem( item, doUpdate);
			_renderQueue.queue( item);
		}

		// creating a symbol
		override protected function createSymbol( row:Object):Symbol {
			_renderQueue.queue( row);
			
			return super.createSymbol( row);
		}

		protected function renderingComplete( evt:RenderEvent):void {
			
			var key:String = findUID( evt.item);	
			var temp:BitmapSymbol = symbolMap[ key];

			debug( "DBG LCH: "+key);
			temp.draw( _renderQueue);			
		}
		
		//==============================================================================
		override protected function debug( txt:String):void {
//			trace( "DBG LCharts("+name+"): "+txt);
		}					
	}
}