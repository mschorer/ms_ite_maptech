package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.mapinfo.*;
	import de.ms_ite.maptech.tools.*;
	
	import flash.events.Event;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import spark.components.Image;						

	public class BirdsEyeLayer extends AdaptiveLayer {
		
		public function BirdsEyeLayer() {
			super();
		}

		override public function set mapInfo( mi:MapInfo):void {
			debug( "set mapinfo");
			
			if ( _mapInfo != mi && _mapInfo != null) _mapInfo.removeEventListener( Event.COMPLETE, handleMIComplete);

			_mapInfo = mi;
			if ( _mapInfo != null) _mapInfo.addEventListener( Event.COMPLETE, handleMIComplete);
			
			if ( viewport == null) viewport = mi.bounds;
//			updateView();
		}
		
		override public function updateView():void {
			debug( "updateView: "+MapInfoVEBirdsEye( _mapInfo).hasView);
			if ( !MapInfoVEBirdsEye( _mapInfo).hasView) {
				// load new ve_info
				
				MapInfoVEBirdsEye( _mapInfo).update( new Point( _viewlinear.centerx, _viewlinear.centery), '"North"');
			} else {
				super.updateView();
			}
		}

		override protected function updateContent( res:Point, effRes:Point, scale:Point):void {
			debug( "updateContent.");
			
			if ( ! visible) return;
			
			if ( loadQueue == null) loadQueue = new LoadQueue();
/*			
			if ( _layer != 19 && _layer != 20) {
				debug( "invalid layer: "+_layer);
				
				return;
			}
*/			
			var off:Point = _mapInfo.projection.coord2pixel( new Point( viewport.left, viewport.top), _mapInfo.bounds, effRes);
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
			
			debug( "offset: "+off.x+"/"+off.y+" : "+poffx+"/"+poffy);
			
			var fx:int = Math.ceil(( width / scale.x + Math.abs( poffx)) / _mapInfo.tileSize);
			var fy:int = Math.ceil(( height / scale.y + Math.abs( poffy))/ _mapInfo.tileSize);
			debug( "sizes: "+poffx+","+poffy+"  |  "+toffx+","+toffy+" / "+fx+"x"+fy);
			
//			debug( "sizes: "+off.x+" : "+toffx+" | "+off.y+" : "+toffy+" / "+fx+"x"+fy);
//			debug( "fille: "+width+" / "+scale+" + "+poffx+" = "+(width / scale  + poffx)+" : "+fx);

			var layerDim:Point = Point( _mapInfo.tilesPerLevel[ layer]);
			if ( !MapInfoVEBirdsEye( _mapInfo).hasView /*|| toffx < 0 || toffy < 0 || fx > layerDim.x || fy >= layerDim.y*/) {
				// load new ve_info
				
				MapInfoVEBirdsEye( _mapInfo).update( new Point( _viewlinear.centerx, _viewlinear.centery), '"North"');
			} else {
				debug( "layer("+this+"): "+_layer+" : "+toffx+" , "+toffy+" : "+fx+"x"+fy);
				var useRect:Rectangle = _mapInfo.getTileIndices( _layer, toffx, toffy, fx, fy);
	//			debug( "  -- ("+this+"): "+_layer+" : "+useRect.x+" , "+useRect.y+" : "+useRect.width+"x"+useRect.height);
	//			debug( "  -- save: "+fx+"x"+fy+" vs "+useRect.width+"x"+useRect.height+" = "+((useRect.width*useRect.height) / (fx * fy)));

				if ( useRect != null) updateLayer( useRect, toffx, toffy, poffx, poffy);
			}
		}
		
		protected function handleMIComplete( evt:Event):void {
			var hv:Boolean = MapInfoVEBirdsEye( _mapInfo).hasView;
			
			debug( "hasView: "+hv);
			if ( hv) updateView();
		}
		
		protected function updateLayer( useRect:Rectangle, toffx:int, toffy:int, poffx:int, poffy:int):void {
			debug( "updateLayer: "+useRect.x+","+useRect.y+"/"+(useRect.x+useRect.width)+","+(useRect.y+useRect.height)+"/"+toffx+","+toffy);
			
			var tempA:Array = new Array();
			if ( useRect != null) {
				for( var i:int = useRect.x; i < useRect.x + useRect.width; i++) {
					for( var j:int = useRect.y; j < useRect.y + useRect.height; j++) {
						var temp:TileInfo;
						var url:String = _mapInfo.getTileURL( _layer, i + toffx, j + toffy);
//						debug( "  T "+(i+toffx)+" , "+(j+toffy)+" : "+(url != null));
						
						var key:String = _mapInfo.name+"/"+_layer+"/"+(i + toffx)+"/"+(j + toffy);
						
						temp = tileMap[ key];
						
						if ( temp == null && url != null) {
							temp = loadQueue.getTileInfo( Image( new tileClass()), _mapInfo, _layer, (i + toffx), (j + toffy));
							loadQueue.queue( temp, _prio);
//							temp = createTile( url, key);
							addChild( temp.tile);
							tileMap[ key] = temp;
							
//							debug( "  T "+(i+toffx)+" , "+(j+toffy)+" : "+(url != null));
	//						debug( "loading: "+url);
						} else {
	//							debug( "reuse: "+url);
						}
						
	//					debug( "use: "+key);
						delete tileMapUnused[ key];
						
						if ( temp != null) {
							tempA[ key] = temp;
							
							temp.tile.x = i * _mapInfo.tileSize + _mapInfo.tileOffsetX - poffx;
							temp.tile.y = j * _mapInfo.tileSize + _mapInfo.tileOffsetY - poffy;
//							debug( "  T"+_layer+" "+i+","+j+" / "+(i+toffx)+" , "+(j+toffy)+" @ :"+temp.x+","+temp.y+" / "+url);
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
				destroyTile( tile);
				removeChild( tile.tile);
				delete tileMapUnused[ tkey];
				delete tileMap[ tkey];
			}
			
			tileMapUnused = tempA;
		}

		override protected function debug( txt:String):void {
			trace( "DBG BirdsEye("+name+"): "+txt);
		}

	}
}