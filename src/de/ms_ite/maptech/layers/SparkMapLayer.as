package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.mapinfo.*;
	import de.ms_ite.maptech.tools.*;
	
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import spark.components.Image;
	import spark.core.IContentLoader;
	
	public class SparkMapLayer extends Layer {
		
		protected var tileMap:Array;
		protected var tileMapUnused:Array;
		
		public var _mapInfo:MapInfo;
		protected var _layer:int;		
		
		protected var _prio:int;
		public var contentCache:IContentLoader;
		
		public var tileClass:Class = spark.components.Image;
		
		public function SparkMapLayer() {
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
			var tempA:Array = new Array();
			if ( useRect != null) {
				for( var i:int = useRect.x; i < useRect.x + useRect.width; i++) {
					for( var j:int = useRect.y; j < useRect.y + useRect.height; j++) {
						var temp:Image;
						var url:String = _mapInfo.getTileURL( _layer, i + toffx, j + toffy);
						//						debug( "  T "+(i+toffx)+" , "+(j+toffy)+" : "+(url != null));
						
						var key:String = _mapInfo.name+"/"+_layer+"/"+(i + toffx)+"/"+(j + toffy);
						
						temp = tileMap[ key];
						
						if ( temp == null && url != null) {
							temp = createTile( url);
							addChild( temp);
							tileMap[ key] = temp;
							
							//						debug( "loading: "+url);
						} else {
							//							debug( "reuse: "+url);
						}
						
						//						debug( "use: "+key);
						delete tileMapUnused[ key];
						
						if ( temp != null) {
							tempA[ key] = temp;
							
							temp.x = i * _mapInfo.tileSize + _mapInfo.tileOffsetX - poffx;
							temp.y = j * _mapInfo.tileSize + _mapInfo.tileOffsetY - poffy;
						}
						//					temp.scaleY = _mapInfo.tileAspect;
						
						//						temp.width = _mapInfo.tileSize;
						//						temp.height = _mapInfo.tileSize;
					}
				}
			}
			
			for( var tkey:String in tileMapUnused) {
				//				debug( "removing: "+tkey);
				var tile:Image = Image( tileMapUnused[ tkey]);
				destroyTile( tile);
				removeChild( tile);
				delete tileMapUnused[ tkey];
				delete tileMap[ tkey];
			}
			
			tileMapUnused = tempA;
		}
		
		protected function createTile( url:String):Image {
			var temp:Image = null;
			if ( url != null) {
				temp = Image( new tileClass());		//new SmoothTile();
				if ( temp.contentLoader == null && contentCache != null) {
					temp.contentLoader = contentCache;
					temp.contentLoaderGrouping = 'grp_'+_prio;
				}
				
				temp.source = url;
			}
			
			return temp;
		}
		
		protected function destroyTile( tile:Image):void {
//			loadQueue.unqueue( tile, _prio);
		}		
		
		override protected function debug( txt:String):void {
			//			trace( "DBG ML("+name+"): "+txt);
		}
	}
}