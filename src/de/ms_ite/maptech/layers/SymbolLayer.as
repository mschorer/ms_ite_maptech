package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.symbols.*;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import spark.events.IndexChangeEvent;
	
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

	public class SymbolLayer extends Layer {

		public var symbolClass:Class = de.ms_ite.maptech.symbols.Symbol;
		protected var MAX_CPU:int = 500;
				
		protected var collection:ICollectionView;
		protected var _bounds:Bounds;
		protected var incrTimer:int;
		protected var incrIdx:int;

		protected var symbolStyle:SymbolStyle;

		protected var mapG:MapGlue;						
		
		protected var symbolMap:Array;
		protected var symbolMapUnused:Array;
		
		protected var _selectedItems:Array;
		protected var _selectedSymbols:Array;
		
		protected var _offset:Point;
		
		public var allowMultipleSelection:Boolean;
		
		public function SymbolLayer() {
			super();

			symbolMap = new Array();
			symbolMapUnused = new Array();			

			_selectedItems = new Array();
			_selectedSymbols = new Array();
			
			_offset = null;
			
			mapG = new MapGlue();
		}
		
		public function set style( st:SymbolStyle):void {
			debug( "set style: "+st);
//			if ( symbolStyle == st) return;
			
			symbolStyle = st;
			refresh( true);
		}
		
		public function get symbolList():Array {
			return symbolMap;
		}
		
		public function get style():SymbolStyle {
			return symbolStyle;
		}
		
		public function set offset( o:Point):void {
			_offset = o;
		}		
		
		override protected function getEffectiveRes( res:Point):Point {
			return res;
		}
		
		override protected function updateContent( res:Point, effRes:Point, scale:Point):void {
			if ( collection == null) return;

			if ( symbolStyle == null) symbolStyle = new SymbolStyle();			
			
			var tempA:Array = new Array();
			var clength:int = collection.length;
			debug( "uc: "+clength);

			for( var i:int = 0; i < clength; i++) {
				var row:Object = collection[ i];
				var key:String = findUID( row);
				
				var temp:Symbol = symbolMap[ key];

				if ( temp == null) {
					temp = createSymbol( row);
//					addChild( temp);
					symbolMap[ key] = temp;
					
//						debug( "loading: "+url);
				} else {
//							debug( "reuse: "+url);
				}
//				debug( "use: "+key);

				delete symbolMapUnused[ key];
				tempA[ key] = temp;
				
//				debug( "pos: "+_viewlinear+" ? "+tempPos);
				
				updateSymbol( temp);

//				debug( "px: ( "+tempPos.x+" - "+_viewlinear.left+") / "+res);
//				debug( "py: ( "+_viewlinear.top+" - "+tempPos.y+") / "+res);
//				debug( "pos: "+temp.x+","+temp.y+" / "+temp.width+","+temp.height);				
			}

			for( var tkey:String in symbolMapUnused) {
				debug( "removing: "+tkey);
				var symbol:Symbol = Symbol( symbolMapUnused[ tkey]);
				rawChildren.removeChild( symbol);
				delete symbolMapUnused[ tkey];
				delete symbolMap[ tkey];
			}
			
			symbolMapUnused = tempA;
		}

		// creating a symbol
		protected function createSymbol( row:Object):Symbol {
			var cr:Symbol = new symbolClass( mapG, symbolStyle);
			cr.projection = lighttable.projection;

			rawChildren.addChild( cr);
//			cr.filters = [symFilter];
			cr.init( row);
			var temp:Bounds = cr.getMBR();
			
			cr.addEventListener( ListEvent.ITEM_CLICK, symbolClick);
			
			if ( rawChildren.numChildren == 1 && temp != null) _bounds = temp;
			else _bounds.mbrAddBounds( temp);
	
			return cr;
		}

		protected function updateSymbol( temp:Symbol):void {
			var origPos:Point = temp.getOrigin();
			var tempPos:Point = (origPos == null) ? null : origPos.clone();
			
			if ( tempPos != null && viewport != null) {
				temp.inView = temp.intersects( viewport);
				
//				var pj:Projection = lighttable.projection;

//				debug( " -- symbol: "+tempPos+" / "+_offset);
				if (_offset != null) {
					tempPos.x += _offset.x;
					tempPos.y += _offset.y;
				}
//				debug( "          : "+tempPos);
				
				tempPos = lighttable.projection.coord2pixel( tempPos, _viewlinear, _resolution);
				
				temp.x = tempPos.x;
				temp.y = tempPos.y;
				temp.resolution = _resolution;
				temp.style = temp.style;
/*				
				var pr:Point = new Point( pj.toRad( tempPos.x), pj.toRad( tempPos.y));
				var p:Point = pj.linearize( pr);
				
				var px:Point = new Point( pj.toDeg( p.x), pj.toDeg( p.y));

//				debug( " -- xform : "+tempPos);
//				debug( "    rad   : "+pr);
//				debug( "    proj  : "+p);
//				debug( "    deg   : "+px);

				temp.x = ( px.x - _viewlinear.left) / _resolution.x;
				temp.y = ( _viewlinear.top - px.y) / _resolution.y;
				temp.resolution = _resolution;
*/				
//				debug( " -- symbol: "+tempPos+" / "+temp.x+","+temp.y+" vs "+temp2);
			}
		}

		protected function removeSymbol( sym:Symbol):void {
//			symbolLayer.removeChild( sym);
			var item:Object = sym.rowData;
			
			var i:int = 0;
			while( i < _selectedSymbols.length) {
				if ( sym == _selectedSymbols[ i]) break;
				i++;
			}

			if ( i < _selectedSymbols.length) {
				_selectedSymbols.splice(i, 1);
				_selectedItems.splice( i, 1);
				debug( "  remove: "+item+" @ #"+_selectedSymbols.length+"/"+_selectedItems.length);
			}

			removeChild( sym);
			sym.removeEventListener( ListEvent.ITEM_CLICK, symbolClick);
			sym.destroy();
		}

		public function get dataProvider():Object {
			return collection;
		}

		/**
		 *  @private
		*/
		public function set dataProvider(value:Object):void {
			if (collection) {
				collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
			}

			if (value is ArrayCollection) {
				collection = value as ArrayCollection;
			} else if (value is Array) {
				collection = new ArrayCollection(value as Array);
			} else if (value is ICollectionView) {
				collection = ICollectionView(value);
			} else if (value is IList) {
				collection = new ListCollectionView(IList(value));
			} else if (value is XMLList) {
				collection = new XMLListCollection(value as XMLList);
			} else if (value is XML) {
				var xl:XMLList = new XMLList();
				xl += value;
				collection = new XMLListCollection(xl);
			} else {
				// convert it to an array containing this one item
				var tmp:Array = [];
				if (value != null)
				tmp.push(value);
				collection = new ArrayCollection(tmp);
			}

			// debug("ListBase added change listener");
			collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);

			// unselect all
			// clearSelectionData();

			mapG.reset();			

			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.RESET;
			collectionChangeHandler(event);
			dispatchEvent(event);
			
			reset();
		}
		
		//-----------------------------------------------------------------------
		// handling changes on dataProvider
		
		private function collectionChangeHandler( evt:CollectionEvent):void {
			var i:int;
			var items:Array;
			var item:Object;
			
			debug( "collChanged ["+evt.kind+"] ["+collection.length+"]");
			
			switch( evt.kind) {
				case CollectionEventKind.ADD:
					// handle evt.items as items
					// evt.location
//					// evt.oldLocation
//					debug( evt.kind+": "+evt.oldLocation+" @ "+evt.location);
					items = evt.items;
					for( i = 0; i < items.length; i++) {
						item = items[i];
						/*
						debug( "  object("+i+"):");
						for( var key:String in item) {
							debug( "    "+key+" = "+item[ key]);
						}
						*/
						addItem( item);
					}
				break;
				case CollectionEventKind.REMOVE:
					// handle evt.items as items
					// evt.location
					// evt.oldLocation
//					debug( evt.kind);
					items = evt.items;
					for( i = 0; i < items.length; i++) {
						item = items[i];
					
						debug( "  object("+i+"):");
						for( var key:String in item) {
							debug( "    "+key+" = "+item[ key]);
						}
					
						removeItem( item);
					}
				break;


				case CollectionEventKind.REPLACE:
					// evt.location
					// evt.oldLocation
//					debug( evt.kind+": "+evt.oldLocation+" with "+evt.location);
				case CollectionEventKind.UPDATE:
//					debug( evt.kind);
					// handle evt.items as PropertyChangeEvents
					var propEvts:Array = evt.items;
					for( i = 0; i < propEvts.length; i++) {
						var pvt:PropertyChangeEvent = propEvts[i];
						switch( pvt.kind) {
							case PropertyChangeEventKind.UPDATE:
/*								debug( "  change prop: "+pvt.property+" from "+pvt.oldValue+" to "+pvt.newValue);
								
								for( var key:String in pvt.source) {
									debug( "    "+key+" = "+pvt.source[ key]+((pvt.property == key) ? ' <=' : ''));
								}
*/							break;
							
							case PropertyChangeEventKind.DELETE:
								debug( "  delete prop: "+pvt.property);
							break;
							
							default:
								// null
						}
						updateItem( pvt.source, true);
					}
				break;

				case CollectionEventKind.MOVE:
					// evt.location
					// evt.oldLocation
//					debug( evt.kind+": "+evt.oldLocation+" to "+evt.location);
				break;

				case CollectionEventKind.REFRESH:
//					debug( evt.kind+".");
					// sort/filter
					refresh( false);
				break;
				
				case CollectionEventKind.RESET:
					// complete update/init
//					debug( evt.kind+".");
					reset();
				break;
				
				default:
					debug( "change???: "+evt.kind);
			}
		}
		
		//-----------------------------------------------------------------------------
		
		//-----------------------------------------------------------------------------
		// external interface

		public function get bounds():Bounds {
			return _bounds;
		}
	
		public function set bounds( mbr:Bounds):void {
			_bounds = mbr;
		}

		//-------------------------------------------------------------------------------
		// drawing functions
		
		protected function reset():void {
			debug( "reset");
			
			removeAll();
			_bounds = new Bounds();
			
			refresh( true);
		}
				
		protected function refresh( doUpdate:Boolean):void {
			debug( "refresh "+doUpdate);
			var sym:Symbol;
			
			if ( collection == null) return;
			
			refreshIncr( true, doUpdate);
		}
			
		protected function refreshIncr( init:Boolean, doUpdate:Boolean):void {
			debug( "refreshing layer: #"+collection.length);
			
			var cnt:int = 0;

			clearTimeout( incrTimer);

			if ( init) {
				if ( incrIdx > 0) {
					incrTimer = setTimeout( refreshIncr, 100, true, doUpdate);
					debug( "  postponing redraw");
				}
			} 

			var start:int = getTimer();
			
			var clength:int = collection.length;
			while( incrIdx < clength) {
				var item:Object = collection[ incrIdx];
//				debug( "update: "+item+" / "+item.hasOwnProperty( 'mx_internal_uid'));
				var uid:String = findUID(item);
				
				if ( symbolMap[ uid] != null) {
					updateItem( item, doUpdate);
				} else {
					addItem( item);
				}
				incrIdx++;
				cnt++;
				
				if (( getTimer() - start) > MAX_CPU) {
					incrTimer = setTimeout( refreshIncr, 100, false, doUpdate);
//					debug( "postpone after: "+cnt);
					break;
				} 
			}
			debug( "  ran for: "+(getTimer() - start));
			if ( incrIdx == clength) {
				incrIdx = 0;
				debug( "run completed.");
				updateView();
			}
		}

		public function refreshBounds( visOnly:Boolean=false):Bounds {
			_bounds = new Bounds();		
			for( var uid:String in symbolMap) {
				var sym:Symbol = Symbol( symbolMap[ uid]);
//				debug( "  bounds: "+sym.getMBR());
				if ( visOnly ? sym.visible : true) _bounds.mbrAddBounds( sym.getMBR());				
			}
			debug( "refresh bounds: "+_bounds);
			
			return _bounds;
		}

		protected function removeAll():void {
			debug( "removeAll");
			
			_selectedSymbols = new Array();
			_selectedItems = new Array();

			for( var uid:String in symbolMap) {
				var sym:Symbol = Symbol( symbolMap[ uid]);
				removeSymbol( sym);
				delete symbolMap[ uid];
				delete symbolMapUnused[ uid];
			}
		}
		
		protected function addItem( item:Object):Symbol {
			var uid:String = findUID(item);
			debug( "addSymbol ["+uid+"]");
			
			var sym:Symbol = createSymbol( item);
			symbolMap[ uid] = sym;
			updateSymbol( sym);
			
			return sym;
		}
		
		protected function removeItem( item:Object):Boolean {
			debug( "removeSymbol  "+symbolMap.length);
			var uid:String = findUID(item);
			var sym:Symbol = Symbol( symbolMap[ uid]);
		
			removeSymbol( sym);	
			delete symbolMap[ uid];
			delete symbolMapUnused[ uid];
			debug( "removedSymbol "+symbolMap.length+" / "+uid);

			return true;
		}
		
		protected function updateItem( item:Object, doUpdate:Boolean):void {
			debug( "updateSymbol "+doUpdate);
			var uid:String = findUID(item);
			var sym:Symbol = Symbol( symbolMap[ uid]);
			
			if ( doUpdate) {
				sym.style = symbolStyle;
			}
			sym.update();
			updateSymbol( sym);
			_bounds.mbrAddBounds( sym.getMBR());
//			debug( "    updated: "+sym.getMBR()+" / "+_bounds);
		}
		
		protected function findUID( item:Object):String {
//			if ( ! item.hasOwnProperty( 'mx_internal_uid')) item.mx_internal_uid = UIDUtil.getUID(item);
			
			return UIDUtil.getUID( item);	//item.mx_internal_uid;
		}
		
		public function updateRow( row:Object):void {
			debug( "updating row");
			collection.itemUpdated( row);
		}
		
		// click event for a symbol
		// to be overridden in subclass
/*		
		public function click( evt:Event):void {
			select( Symbol( evt.currentTarget));
		}

		public function isSelected():Boolean {
			return ( _selectedItems.length > 0);
		}
*/		

		public function getSymbol(item:Object):Symbol {
			var uid:String = findUID(item);
			debug( "getSymbol: "+uid);
			
			return symbolMap[ uid];
		}
		 
		public function selectItem( item:Object):void {
			var uid:String = findUID(item);			
			var sym:Symbol = symbolMap[ uid];
			select( sym, true, true);
			debug( "selected: "+sym);
		}
	
		public function select( sym:Symbol, multipleMode:Boolean, state:Boolean=true, postEvent:Boolean=true):void {
			debug( "select("+state+"): "+(( sym != null) ? sym.name : 'null')+" / "+multipleMode);
			var item:Object = null;
			var rmv:Array;
			
			if ( sym != null) {
				toFront( sym);
				item = sym.rowData;
			}
	
			var unSelected:Boolean = true;
			var i:int = 0;
			while( i < _selectedSymbols.length) {
				if ( sym == _selectedSymbols[ i]) {
					if ( state) {
						unSelected = false;
						debug( "found selected: "+sym.name);
					} else {
						rmv = _selectedSymbols.splice( i, 1);
						_selectedItems.splice( i, 1);

						debug( "unselect("+multipleMode+"): "+rmv[0].name);
						Symbol( rmv[0]).select( false);
						continue;						
					}
				} else {
					if ( ! multipleMode) {
						rmv = _selectedSymbols.splice( i, 1);
						_selectedItems.splice( i, 1);
						
						debug( "unselect("+multipleMode+"): "+rmv[0].name);
						Symbol( rmv[0]).select( false);
						continue;
					}
				}
				i++;
			}

			if ( sym != null) {
				// we need to add it
				if ( state && unSelected) {
					debug( "  selecting: "+sym.name+" @ #"+_selectedSymbols.length+"/"+_selectedItems.length);
					_selectedSymbols.push( sym);
					_selectedItems.push( item);
					debug( "  selected : "+item+" @ #"+_selectedSymbols.length+"/"+_selectedItems.length);
					sym.select( true);
	//				selectedSymbol.highlight( false);
				}
			}
	
			if ( postEvent) {
				debug( "signalling CHANGE");
				dispatchEvent( new IndexChangeEvent( IndexChangeEvent.CHANGE));
//				dispatchEvent( new ListEvent( ListEvent.ITEM_CLICK));
			}
		}
		
		protected function symbolClick( evt:ListEvent):void {
			debug( "click: "+evt.target);
			dispatchEvent( evt);
		}
		
		public function get selectedItems():Array {
			debug( "get selection.");
			return _selectedItems.concat();
		}
		
		public function set selectedItems( list:Array):void {
			debug( "set selection: #"+list.length);
			var uid:String;			
			var sym:Symbol;
				
			// unselect all
			select( null, false, false, false);
			
			// copy selection
			for( var i:int = 0; i < list.length; i++) {
				uid = findUID( list[i]);			
				sym = symbolMap[ uid];
				
				debug( "select: "+uid+" / "+sym);
				select( sym, true, true, false);
			}
		}
	/*
		public function selectDown( idx:Number, state:Boolean):String {
			debug( "selectdown: "+idx);
	
			if ( selectedSymbol != null) selectedSymbol.select( false);
//			selectedSymbol = rsyms[ idx];
			selectedSymbol.select( state);
			return "";
		}
	
		public function deselectLayer():void {
			debug( "deselect: "+selectedSymbol);
			
			if ( selectedSymbol != null) selectedSymbol.select( false);
		}
	*/
		public function toFront( symbol:Symbol):void {
//			debug( "tofront");
			rawChildren.setChildIndex( symbol, rawChildren.numChildren -1);
//			if ( superStore != null) superStore.toFront( symbolLayerDepth);
		}

		override protected function debug( txt:String):void {
			if ( debugLevel > 0) trace( "DBG LSym("+name+"): "+txt);
		}					
	}
}