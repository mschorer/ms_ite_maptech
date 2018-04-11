package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.mapinfo.*;
	import de.ms_ite.maptech.tools.*;
	
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import spark.components.Image;						

	public class MapLayer extends Layer {
		
		protected var tileMap:Array;
		protected var tileMapUnused:Array;
		
		public var _mapInfo:MapInfo;
		protected var _layer:int;		
		
		protected var _prio:int;
		public var loadQueue:ILoadQueue;
		
		public var tileClass:Class = spark.components.Image;
/*		
		protected var workX:int;
		protected var workY:int;
		protected var workToffX:Number;
		protected var workToffY:Number;			
		protected var workPoffX:Number;
		protected var workPoffY:Number;
		protected var workUseRect:Rectangle;
		protected var workTiles:Array;
*/
		public function MapLayer() {
			super();

			_prio = 0;

			tileMap = new Array();
			tileMapUnused = new Array();			
		}
		
		public function set mapInfo( mi:MapInfo):void {
//			debug( "set mapinfo");
			_mapInfo = mi;
			if ( viewport == null) viewport = mi.bounds;
//			updateView();
		}
			
		public function get mapInfo():MapInfo {
			return _mapInfo;
		}

		public function set priority( i:int):void {
//			debug( "lay");
			_prio = i;
		}
			
		public function get priority():int {
			return _prio;
		}
				
		public function set layer( i:int):void {
//			debug( "lay");
			_layer = i;
//			updateView();
		}
			
		public function get layer():int {
			return _layer;
		}
		
		override public function set visible( state:Boolean):void {
			super.visible = state;
			if ( state) lighttable.updateView( true);
		}
/*		
		override public function get aspect():Number {
			return (( _mapInfo != null) ? _mapInfo.tileAspect : 1);
		}
*/				
		override public function get ready():Boolean {
			if ( ! super.ready) return false;
			if ( (( _mapInfo == null) ? true : (! _mapInfo.initialized))) return false;
			
			return true;			
		}				
		
		override protected function getEffectiveRes( res:Point):Point {
			return Point( _mapInfo.resolutionPerLevel[ _layer]);
		}

		override protected function updateContent( res:Point, effRes:Point, scale:Point):void {

			if ( ! visible) return;
			
			if ( loadQueue == null) loadQueue = new LoadQueue();
			
			var off:Point = _mapInfo.projection.coord2pixel( new Point( viewport.left, viewport.top), mapInfo.bounds, effRes);
/*			
			var tl:Point = _mapInfo.coord2pixel( _viewlinear.left, _viewlinear.top, _layer, effRes);
			var tr:Point = _mapInfo.coord2pixel( _viewlinear.right, _viewlinear.top, _layer, effRes);
			var bl:Point = _mapInfo.coord2pixel( _viewlinear.left, _viewlinear.bottom, _layer, effRes);
			var br:Point = _mapInfo.coord2pixel( _viewlinear.right, _viewlinear.bottom, _layer, effRes);
			var c:Point = _mapInfo.coord2pixel( _viewlinear.centerx, _viewlinear.centery, _layer, effRes);
*/			
//			debug( "vp: "+_viewlinear.centerx+","+_viewlinear.centery+" / "+_viewlinear);
//			debug( "vp:\n  "+tl+"\n  "+tr+"\n  "+bl+"\n  "+br+"\n  "+c);

//			var off:Point = _mapInfo.coord2pixel( _viewlinear.centerx, _viewlinear.centery, _layer, effRes);
//			debug( " center: "+center.x+" "+center.y);
/*			
			var offx:Number = (_viewlinear.left - _mapInfo.bounds.left) / effRes;
			var offy:Number = (_mapInfo.bounds.top - _viewlinear.top) / effRes;
			
			debug( " equals: x:"+( offx - off.x)+" y:"+( off.y - off.y));
*/
//			var toffx:Number = ( off.x < 0) ? Math.ceil( off.x / _mapInfo.tileSize) : Math.floor( off.x / _mapInfo.tileSize);
//			var toffy:Number = ( off.y < 0) ? Math.ceil( off.y / _mapInfo.tileSize) : Math.floor( off.y / _mapInfo.tileSize);
			var toffx:Number = Math.floor( off.x / _mapInfo.tileSize);
			var toffy:Number = Math.floor( off.y / _mapInfo.tileSize);

			var poffx:Number = ( Math.ceil(off.x) % _mapInfo.tileSize) + (( off.x < 0) ? _mapInfo.tileSize : 0);
			var poffy:Number = ( Math.ceil(off.y) % _mapInfo.tileSize) + (( off.y < 0) ? _mapInfo.tileSize : 0);
//			var poffx:Number = Math.ceil(off.x) % _mapInfo.tileSize;
//			var poffy:Number = Math.ceil(off.y) % _mapInfo.tileSize;
			
//			debug( "offset: "+off.x+"/"+off.y+" : "+poffx+"/"+poffy);
			
			var fx:int = Math.ceil(( width / scale.x + Math.abs( poffx)) / _mapInfo.tileSize);
			var fy:int = Math.ceil(( height / scale.y + Math.abs( poffy))/ _mapInfo.tileSize);
//			debug( "sizes: "+poffx+","+poffy+"  |  "+toffx+","+toffy+" / "+fx+"x"+fy);
			
//			debug( "sizes: "+off.x+" : "+toffx+" | "+off.y+" : "+toffy+" / "+fx+"x"+fy);
//			debug( "fille: "+width+" / "+scale+" + "+poffx+" = "+(width / scale  + poffx)+" : "+fx);
			
//			debug( "layer("+this+"): "+_layer+" : "+toffx+" , "+toffy+" : "+fx+"x"+fy);
			var useRect:Rectangle = _mapInfo.getTileIndices( _layer, toffx, toffy, fx, fy);
/*			
			if ( useRect != null) {
				debug( "  -- : "+_layer+" : "+useRect.x+" , "+useRect.y+" : "+useRect.width+"x"+useRect.height);
				debug( "  -- save: "+fx+"x"+fy+" vs "+useRect.width+"x"+useRect.height+" = "+((useRect.width*useRect.height) / (fx * fy)));
			} else {
				debug( "error.");
			}
*/			
			var complete:Boolean = true;
			
			var tempA:Array = new Array();
			if ( useRect != null) {
				for( var workX:int = useRect.x; workX < useRect.x + useRect.width; workX++) {
					for( var workY:int = useRect.y; workY < useRect.y + useRect.height; workY++) {
						var temp:TileInfo;
						var url:String = _mapInfo.getTileURL( _layer, workX + toffx, workY + toffy);
//						debug( "  T "+(i+toffx)+" , "+(j+toffy)+" : "+(url != null));
						
						var key:String = _mapInfo.name+"/"+_layer+"/"+(workX + toffx)+"/"+(workY + toffy);
						
						temp = tileMap[ key];
						
						if ( temp == null && url != null) {
							temp = loadQueue.getTileInfo( (tileClass != null) ? Image( new tileClass()) : null, _mapInfo, _layer, (workX + toffx), (workY + toffy));
							if ( ! loadQueue.queue( temp, _prio)) complete = false;
							
//							temp = createTile( url, _mapInfo, _layer, (i + toffx), (j + toffy));
							addChild( temp.tile);
							tileMap[ key] = temp;
							
	//						debug( "loading: "+url);
						} else {
	//							debug( "reuse: "+url);
						}
						
//						debug( "use: "+key);
						delete tileMapUnused[ key];
						
						if ( temp != null) {
							tempA[ key] = temp;
							
							temp.tile.x = workX * _mapInfo.tileSize + _mapInfo.tileOffsetX - poffx;
							temp.tile.y = workY * _mapInfo.tileSize + _mapInfo.tileOffsetY - poffy;
						}
	//					temp.scaleY = _mapInfo.tileAspect;
						
	//						temp.width = _mapInfo.tileSize;
	//						temp.height = _mapInfo.tileSize;
					}
				}
			}
			
			for( var tkey:String in tileMapUnused) {
//				debug( "removing: "+tkey);
				var tile:TileInfo = TileInfo( tileMapUnused[ tkey]);
				
				try {
					delete tileMapUnused[ tkey];
					delete tileMap[ tkey];
					destroyTile( tile);
					removeChild( tile.tile);
				} catch( e:Error) {
					debug( "error cleaning tile 2"+tile);					
				}
			}
			
			tileMapUnused = tempA;
		}
		
/*
		override protected function updateContent( res:Point, effRes:Point, scale:Point):void {
			var complete:Boolean = true;
						
			if ( ! visible) return;
			
			if ( loadQueue == null) loadQueue = new LoadQueue();
			
			var off:Point = _mapInfo.projection.coord2pixel( new Point( viewport.left, viewport.top), mapInfo.bounds, effRes);
			workToffX = Math.floor( off.x / _mapInfo.tileSize);
			workToffY = Math.floor( off.y / _mapInfo.tileSize);			
			workPoffX = ( Math.ceil(off.x) % _mapInfo.tileSize) + (( off.x < 0) ? _mapInfo.tileSize : 0);
			workPoffY = ( Math.ceil(off.y) % _mapInfo.tileSize) + (( off.y < 0) ? _mapInfo.tileSize : 0);
			var fx:int = Math.ceil(( width / scale.x + Math.abs( workPoffX)) / _mapInfo.tileSize);
			var fy:int = Math.ceil(( height / scale.y + Math.abs( workPoffY))/ _mapInfo.tileSize);
			workUseRect = _mapInfo.getTileIndices( _layer, workToffX, workToffY, fx, fy);

			debug( "fill map layer");
			
			workTiles = new Array();
			if ( workUseRect != null) {
				complete = updateIncremental( workUseRect.x, workUseRect.y);				
			}
			
//			if ( complete) cleanTiles();
		}
		
		protected function cleanTiles():void {
			debug( "clean tile map.");
			
			for( var tkey:String in tileMapUnused) {
				//				debug( "removing: "+tkey);
				var tile:TileInfo = TileInfo( tileMapUnused[ tkey]);
				destroyTile( tile);
				removeChild( tile.tile);
				delete tileMapUnused[ tkey];
				delete tileMap[ tkey];
			}
			
			tileMapUnused = workTiles;
		}
		
		protected function updateIncremental( currX:int, currY:int):Boolean {
			var tilesTbCreated:int = 32;
			var complete:Boolean = true;
			
			var tempY:int = currY;

			for( var tempX:int = currX; tempX < workUseRect.x + workUseRect.width; tempX++) {
				while( tempY < workUseRect.y + workUseRect.height) {
					var temp:TileInfo;
					var url:String = _mapInfo.getTileURL( _layer, tempX + workToffX, tempY + workToffY);
					
//					debug( "  T "+(tempX+workToffY)+" , "+(tempY+workToffY)+" : "+(url != null));
					
					var key:String = _mapInfo.name+"/"+_layer+"/"+(tempX + workToffX)+"/"+(tempY + workToffY);
					
					temp = tileMap[ key];
					
					if ( temp == null && url != null) {
						temp = loadQueue.getTileInfo( (tileClass != null) ? Image( new tileClass()) : null, _mapInfo, _layer, (tempX + workToffX), (tempY + workToffY));
						if ( ! loadQueue.queue( temp, _prio)) {
							complete = false;
							
							tilesTbCreated--;
						}
						
						addChild( temp.tile);
						tileMap[ key] = temp;
					} else {
						//							debug( "reuse: "+url);
					}
					
					delete tileMapUnused[ key];
					
					if ( temp != null) {
						workTiles[ key] = temp;
						
						temp.tile.x = tempX * _mapInfo.tileSize + _mapInfo.tileOffsetX - workPoffX;
						temp.tile.y = tempY * _mapInfo.tileSize + _mapInfo.tileOffsetY - workPoffY;
					}
					
					tempY++;
					
					if ( tilesTbCreated <= 0) break;
				}
				if ( tilesTbCreated <= 0) break;

				tempY = workUseRect.y;
			}
			
			debug( "  tile patch #"+tilesTbCreated+" ["+workUseRect.x+" "+currX+" "+workUseRect.width+" x "+workUseRect.y+" "+currY+" "+workUseRect.height+"]");
			
			if ( tilesTbCreated <= 0) {
				callLater( updateIncremental, [ tempX, tempY]);
			} else {
				cleanTiles();
			}

			return (tilesTbCreated > 0);
		}
*/
/*		
		protected function createTile( url:String, mi:MapInfo, l:int, x:int, y:int):Image {
			var tile:Image = null;
			if ( url != null) {
				tile = Image( new tileClass());		//new SmoothTile();
				
				tile.autoLoad = false;
				tile.source = url;
				loadQueue.queue( tile, _prio);
			}
			
			return tile;
		}
*/		
		protected function destroyTile( tile:TileInfo):void {
			loadQueue.unqueue( tile, _prio);
		}		

		override protected function debug( txt:String):void {
//			trace( "DBG ML("+name+"): "+txt);
		}
	}
}