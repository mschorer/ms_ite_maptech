package de.ms_ite.maptech.layers {
	
	import de.ms_ite.maptech.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import spark.components.Image;

	public class WrappingLayer extends AdaptiveLayer {

		protected var _fixLayer:Boolean = false;
		public var preventCleanup:Boolean = false;
		
		public function WrappingLayer() {
			super();
		}
		
		override public function set layer( i:int):void {
			debug( "lay: "+i);
			_fixLayer = ( i >= 0);
			if ( _layer != i) {
				_layer = i;
				updateView();
			}
			debug( "  set lay: "+_fixLayer+" / "+i);
		}

		public function set fixLayer( f:Boolean):void {
			debug( "fixlay: "+f);
			_fixLayer = f;
		}

		override protected function getEffectiveRes( res:Point):Point {
			// return MapLayer
			if ( _fixLayer)	return Point( _mapInfo.resolutionPerLevel[ _layer]);
			else return super.getEffectiveRes( res);
		}
		
		override protected function updateContent( res:Point, effRes:Point, scale:Point):void {

			if ( loadQueue == null) loadQueue = new LoadQueue();
			
			var off:Point = _mapInfo.projection.coord2pixel( new Point( viewport.left, viewport.top), mapInfo.bounds, effRes);
/*			
			var tl:Point = _mapInfo.coord2pixel( _viewlinear.left, _viewlinear.top, _layer, effRes);
			var tr:Point = _mapInfo.coord2pixel( _viewlinear.right, _viewlinear.top, _layer, effRes);
			var bl:Point = _mapInfo.coord2pixel( _viewlinear.left, _viewlinear.bottom, _layer, effRes);
			var br:Point = _mapInfo.coord2pixel( _viewlinear.right, _viewlinear.bottom, _layer, effRes);
			var c:Point = _mapInfo.coord2pixel( _viewlinear.centerx, _viewlinear.centery, _layer, effRes);
*/			
			debug( "vp: "+_viewlinear.centerx+","+_viewlinear.centery+" / "+_viewlinear);
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
//			debug( "  -- ("+this+"): "+_layer+" : "+useRect.x+" , "+useRect.y+" : "+useRect.width+"x"+useRect.height);
//			debug( "  -- save: "+fx+"x"+fy+" vs "+useRect.width+"x"+useRect.height+" = "+((useRect.width*useRect.height) / (fx * fy)));
			
			var tempA:Array = new Array();
			if ( useRect != null) {
				for( var i:int = 0; i < fx; i++) {
					for( var j:int = 0; j < fy; j++) {
						var temp:TileInfo;
						var url:String = _mapInfo.getTileURL( _layer, i + toffx, j + toffy);
//						debug( "  T "+(i+toffx)+" , "+(j+toffy)+" : "+(url != null));
						
						var key:String = _mapInfo.name+"/"+_layer+"/"+(i + toffx)+"/"+(j + toffy);
						
						temp = tileMap[ key];
						
						if ( url != null) {
							if ( temp == null) {
								temp = loadQueue.getTileInfo( Image( new tileClass()), _mapInfo, _layer, (i + toffx), (j + toffy));
								loadQueue.queue( temp, _prio);
//								temp = createTile( url, key);
								addChild( temp.tile);
								tileMap[ key] = temp;
								
		//						debug( "loading: "+url);
							} else {
		//							debug( "reuse: "+url);
								temp.tile.visible = true;
							}
						}
						
	//					debug( "use: "+key);
						delete tileMapUnused[ key];
						
						if ( temp != null) {
							tempA[ key] = temp;
							
							temp.tile.x = i * ( _mapInfo.tileSize - _mapInfo.tileOffsetX) - poffx;
							temp.tile.y = j * ( _mapInfo.tileSize - _mapInfo.tileOffsetY) - poffy;
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
				if ( preventCleanup) {
					tile.tile.visible = false;	
				} else {
					destroyTile( tile);
					removeChild( tile.tile);
					delete tileMapUnused[ tkey];
					delete tileMap[ tkey];					
				}
			}
			
			tileMapUnused = tempA;
		}		
	}
}