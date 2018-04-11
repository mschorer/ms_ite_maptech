/*

(c) by ms@ms-ite.org

v0.1

todo:
- rework to be a true v2 component

v0.1: startet v2 development			(20060215)
*/

package de.ms_ite.maptech {

	import de.ms_ite.maptech.mapinfo.MapInfo;
	
	import flash.events.*;
	import flash.utils.*;
	
	import spark.components.Image;
	
	public class LoadQueue extends EventDispatcher implements ILoadQueue {
	
		protected var waitqueues:Array;
		protected var loadMap:Dictionary;
		
		public var bytesTotal:int = 0;		
		public var bytesLoaded:int = 0;
		protected var tilesLoading:int = 0;
		protected var tilesRatio:Number = 0;
	
		public var PARLOADS:Number = 2;
		
		public function LoadQueue() {
			super()		

			waitqueues = new Array();
			loadMap = new Dictionary;
			
			debug( "createloadComponent");
		};
		
		// return the queue status
		public function isEmpty():Boolean {
			for( var i:int=0; i < waitqueues.length; i++) {
				if (( waitqueues[i] != null) ? (waitqueues[ i].length > 0) : false) return false;
			}
			return true;
		}
		
		// print debug messages
		protected function debug( txt:String):void {
//			trace( "DBG LQ: "+txt);
		};
		protected function error( txt:String):void {
//			trace( "ERR LQ: "+txt);
		};
		
		public function queue( tile:TileInfo, prio:int=0, sort:int=0):Boolean {
//			debug( "queue: "+tile.name);
			
			bytesTotal++;

			if ( tilesLoading < PARLOADS) {
				queueLoading( tile);
				
				return false;
			} else {
				queueWaiting( tile, prio);

				return true;
			}
		}
		
		// add to the load queue
		protected function queueLoading( tile:TileInfo):void {
			debug( "queue loading: "+tile.url);
			
			tile.tile.addEventListener( Event.COMPLETE, tileDone);
			tile.tile.addEventListener( ProgressEvent.PROGRESS, tileProgress);
			tile.tile.addEventListener( IOErrorEvent.IO_ERROR, tileError);
			tile.tile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, tileError);
			
			loadMap[ tile.tile] = tile;
			
			tile.load();
			tilesLoading++;
		}
		
		// add to the wait queue
		protected function queueWaiting( tile:TileInfo, prio:int=0):void {
			debug( "queue waiting: "+tile.url+" / "+tilesLoading);
			if ( waitqueues[ prio] == null) waitqueues[ prio] = new Array();
			waitqueues[ prio].push( tile);
		}
		
		public function unqueue( tile:TileInfo, prio:int=0):void {
			var j:Number = 0;
	
			if ( waitqueues[ prio] == null) return;
			
			var i:int = waitqueues[ prio].indexOf( tile);
			debug( "unqueue "+tile.url+" @ "+i);

			if ( i >= 0) {
				waitqueues[ prio].splice( i, 1);
				bytesTotal--;
			}
		}
		
		// clear the wait-queue, loading tiles are untouched
		public function clear():void {
			for( var i:int=0; i < waitqueues.length; i++) {
				waitqueues[i] = null;
			}
			
			bytesTotal = 0;
			bytesLoaded = 0;
			tileDone( null);
			debug( "clearQueue");
		};
		
		public function getTileInfo( img:Image, mi:MapInfo, lay:int, x:int, y:int):TileInfo {
			return new TileInfo( img, mi, lay, x, y);
		}
		
		//-----------------------------------------------------------------

		protected function tileDone( evt:Event):void {
			var tile:Image = Image( evt.target);
			tileFinished( tile);
		}
				
		protected function tileProgress( evt:ProgressEvent):void {
			//			debug( "  tile prog: "+tile.name+" / "+tilesRatio);
			var tile:Image = Image( evt.target);			
			tilesRatio = (evt.bytesTotal != 1) ? ( evt.bytesLoaded / evt.bytesTotal) : 1;
		}
		
		protected function tileError( evt:Event):void {
			error( "  tile error: "+tile.name+" : "+evt.toString());
			var tile:Image = Image( evt.target);
			tileFinished( tile);
		}
		
		protected function tileFinished( tile:Image):void {
			debug( "  tile done: "+tile.name);
			
			var tileInfo:TileInfo = loadMap[ tile] as TileInfo;

			tilesLoading--;			
			bytesLoaded++;
						
			tile.removeEventListener( Event.COMPLETE, tileDone);
			tile.removeEventListener( ProgressEvent.PROGRESS, tileProgress);
			tile.removeEventListener( IOErrorEvent.IO_ERROR, tileError);
			tile.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, tileError);

			delete loadMap[ tile];

			// fill queue
			for( var i:int=0; i < waitqueues.length; i++) {
				if (((waitqueues[i] != null) ? ( waitqueues[i].length > 0) : false)) {
					while( tilesLoading < PARLOADS && waitqueues[i].length > 0) {
						var ti:TileInfo = TileInfo( waitqueues[i].shift());
//						error( "next("+i+"): "+tile.source);
						queueLoading( ti);
					}
				}
			}
			var pe:ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS);
			pe.bytesLoaded = bytesLoaded;
			pe.bytesTotal = bytesTotal;
			dispatchEvent( pe);
			
			if ( bytesLoaded == bytesTotal) {
				bytesLoaded = bytesTotal = 0;
			}
		}
	}			
}
//==================================================