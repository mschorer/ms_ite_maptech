package de.ms_ite.maptech.containers {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.symbols.*;
	import de.ms_ite.maptech.symbols.styles.SymbolStyle;
//	import de.ms_ite.maptech.MapGlue;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import mx.collections.*;
	import mx.events.*;

	public class CompatLayer extends MetaLayer {

		protected var _style:SymbolStyle;
		protected var _dataProvider:ICollectionView;
		
		protected var geom:SymbolLayer;
		protected var charts:ChartLayer;
		protected var text:SymbolLayer;
		protected var sym:SymbolLayer;
		
		protected var mapG:MapGlue;
		protected var mapInited:Boolean;
				
		public function CompatLayer( st:SymbolStyle) {
			super();
			_style = st;
			
			mapG = new MapGlue();
			mapInited = false;
/*						
			geom = new SymbolLayer();
			geom.symbolClass = de.ms_ite.maptech.symbols.GeomSymbol;
			addChild( geom); 					

			charts = new ChartLayer();
			addChild( charts); 					

			text = new SymbolLayer();
			text.symbolClass = de.ms_ite.maptech.symbols.TextSymbol;
			addChild( text); 					

			sym = new SymbolLayer();
			sym.symbolClass = de.ms_ite.maptech.symbols.IconSymbol;
			addChild( sym);
*/ 					
		}

		public function get selectedItems():Array {
			return ( sym != null) ? sym.selectedItems : geom.selectedItems;
		}
		
		public function set selectedItems( si:Array):void {
			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Object = stack[ i];
				if ( temp is SymbolLayer) SymbolLayer( temp).selectedItems = si;
			}
		}
		
		public function get bounds():Bounds {
			var temp:Bounds = new Bounds();
			if ( sym != null) temp.mbrAddBounds( sym.bounds);
			if ( geom != null) temp.mbrAddBounds( geom.bounds);
			debug( "get mbr: "+temp+" / "+(( sym != null) ? sym.bounds : '---')+"/"+(( geom != null) ? geom.bounds : '---'));
			
			return temp;
		}
		
		public function set style( st:SymbolStyle):void {
			debug( "set style: "+st);
//			if ( symbolStyle == st) return;
			
			_style = st;
			
			adaptLayers();
			
			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Object = stack[ i];
				if ( temp is SymbolLayer) SymbolLayer( temp).style = _style;
			}
		}
		
		public function get style():SymbolStyle {
			return _style;
		}

		public function getSymbol(item:Object):Symbol {
			if ( geom != null) return geom.getSymbol( item); 
			if ( sym != null) return sym.getSymbol( item); 
			if ( text != null) return text.getSymbol( item); 
			if ( charts != null) return charts.getSymbol( item);
			
			return null; 
		}		 

		protected function adaptLayers():Boolean {
			mapG.reset();
			
			var hasPoint:Boolean = false;
			var hasGeom:Boolean = false;
			
			if (( _dataProvider != null) ? ( _dataProvider.length > 0) : false) {
				var PCol:String = mapG.getPoint( _dataProvider[0] );
				var GCol:String = mapG.getGeometry( _dataProvider[0]);

				hasPoint = ( PCol != null) ? (_dataProvider[0][ PCol] != '') : false;
				hasGeom = ( GCol != null) ? (_dataProvider[0][ GCol] != '') : false;
			}
			
			if ( hasGeom && geom == null) {
				debug( "gen geom layer");
				geom = new SymbolLayer();
				geom.symbolClass = de.ms_ite.maptech.symbols.GeomSymbol;
				geom.style = _style;
				geom.addEventListener( Event.CHANGE, propagateChange);
				addChild( geom); 					
			}
			if ( ! hasGeom && geom != null) {
				debug( "del geom layer");
				geom.removeEventListener( Event.CHANGE, propagateChange);
				removeChild( geom);
				geom = null;
			}

			if ( _style.data.labelField != '' && text == null) {
				debug( "gen text layer");
				text = new SymbolLayer();
				text.symbolClass = de.ms_ite.maptech.symbols.TextSymbol;
				text.style = _style;
				text..addEventListener( Event.CHANGE, propagateChange);
				addChild( text);
				text.dataProvider = _dataProvider;
			}
			if ( _style.data.labelField == '' && text != null) {
				debug( "del text layer");
				text.removeEventListener( Event.CHANGE, propagateChange);
				removeChild( text);
				text == null; 									
			}
			
			if ( _style.data.vis_fx != 'none' && charts == null) {
				debug( "gen chart layer");
				charts = new ChartLayer();
				charts.style = _style;
				charts.addEventListener( Event.CHANGE, propagateChange);
				addChild( charts);
				charts.dataProvider = _dataProvider;				
			}
			if ( _style.data.vis_fx == 'none' && charts != null) {
				debug( "del chart layer");
				charts.removeEventListener( Event.CHANGE, propagateChange);
				removeChild( charts);
				charts = null;
			}
			
			if ( hasPoint && sym == null) {
				debug( "gen symbol layer");
				sym = new SymbolLayer();
				sym.symbolClass = de.ms_ite.maptech.symbols.IconSymbol;
				sym.style = _style;
				sym.addEventListener( Event.CHANGE, propagateChange);
				addChild( sym); 									
			}
			if ( ! hasPoint && sym != null) {
				debug( "del symbol layer");
				sym.removeEventListener( Event.CHANGE, propagateChange);
				removeChild( sym);
				sym = null;
			}
			
			return ( hasPoint || hasGeom);
		}
		
		protected function propagateChange( evt:Event):void {
			debug( "propagate change");
			
			var src:SymbolLayer = SymbolLayer( evt.target);
			
			if (( geom != null) ? ( src != geom) : false) geom.selectedItems = src.selectedItems;
			if (( sym != null) ? ( src != sym) : false) sym.selectedItems = src.selectedItems;
			if (( charts != null) ? ( src != charts) : false) charts.selectedItems = src.selectedItems;
			if (( text != null) ? ( src != text) : false) text.selectedItems = src.selectedItems;
			
			dispatchEvent( evt);
		}

		public function set dataProvider( dp:ICollectionView):void {
			_dataProvider = dp;

			if (_dataProvider) {
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
			}

			_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);

			adaptLayers();

			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Object = stack[ i];
				if ( temp is SymbolLayer) SymbolLayer( temp).dataProvider = dp;
			}			
		}
		
		override public function addChild( temp:DisplayObject):DisplayObject {
			
			if ( temp is Layer) {
				debug( "addLayer: "+temp+" : "+width+"x"+height);
				
				var layer:Layer = Layer( temp);
				layer.width = width;
				layer.height = height;
				layer.viewport = _viewlinear;
				layer.lighttable = lighttable;
				if ( layer is MapLayer) {
					MapLayer( layer).mapInfo = _mapInfo;
					MapLayer( layer).loadQueue = _loadQueue;
				}
				if ( layer is SymbolLayer) {
					SymbolLayer( layer).style = _style;
					SymbolLayer( layer).dataProvider = _dataProvider;
				}
			} else {
				debug( "addChild: "+temp+" : "+width+"x"+height);
			}
			
			return super.addChild( layer);
		}
		
		protected function collectionChangeHandler( evt:CollectionEvent):void {
			var i:int;
			debug( "collChanged "+evt.kind);
			
			switch( evt.kind) {
				case CollectionEventKind.ADD:
				case CollectionEventKind.REPLACE:
				case CollectionEventKind.UPDATE:
				case CollectionEventKind.MOVE:
					if ( mapInited) break;
					
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
					adaptLayers();
					mapInited = false;
				break;
				
				default:
					debug( "change???: "+evt.kind);
			}
		}
		
		//-----------------------------------------------------------------------------

		override protected function debug( txt:String):void {
			trace( "DBG MetaLayer: "+txt);
		}			
	}
}