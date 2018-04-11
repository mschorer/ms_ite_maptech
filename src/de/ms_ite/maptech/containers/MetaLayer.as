package de.ms_ite.maptech.containers {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.mapinfo.*;
	import de.ms_ite.maptech.layers.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import mx.containers.Canvas;

	public class MetaLayer extends Layer {
		
		protected var _mapInfo:MapInfo;
		protected var _loadQueue:LoadQueue;
		
		public function MetaLayer() {
			super();
		}
		
		override public function addChild( temp:DisplayObject):DisplayObject {
			
			if ( temp is Layer) {
				debug( "ml addLayer: "+temp+" : "+width+"x"+height);
				
				var layer:Layer = Layer( temp);
				layer.width = width;
				layer.height = height;
				layer.viewport = viewport;
				if ( layer is MapLayer) {
					MapLayer( layer).mapInfo = _mapInfo;
					MapLayer( layer).loadQueue = _loadQueue;
				}
				layer.updateView();
			} else {
				debug( "ml addChild: "+temp+" : "+width+"x"+height);
			}
			
			return super.addChild( layer);
		}

		override public function removeChild( temp:DisplayObject):DisplayObject {
			
			if ( temp is Layer) debug( "removeLayer: "+temp);
			else debug( "removeChild: "+temp);
			
			return super.removeChild( temp);
		}

		public function set mapInfo( mi:MapInfo):void {
			_mapInfo = mi;
			
			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Object = stack[ i];
				if ( temp is MapLayer) MapLayer( temp).mapInfo = _mapInfo;
			}
			invalidateDisplayList();			
		}
		
		override public function set viewport( vp:Bounds):void {
			super.viewport = vp;
			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Object = stack[ i];
				if ( temp is Layer) Layer( temp).viewport = viewport;
			}
			invalidateDisplayList();			
		}
		
		public function set loadQueue( lq:LoadQueue):void {
			_loadQueue = lq;
			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Object = stack[ i];
				if ( temp is MapLayer) MapLayer( temp).loadQueue = lq;
			}
		}
		
		public function get loadQueue():LoadQueue {
			return _loadQueue;
		}
		
		override public function updateView():void {
//			debug( "zero: "+_viewlinear.width+","+_viewlinear.height+"  /  "+width+","+height);

			if ( _viewlinear == null) return;
			
			var res:Number = _viewlinear.width / width;
			
			var zeroX:Number = x * res;
			var zeroY:Number = y * res;
			
//			debug( "zero: "+x+","+y+"  /  "+zeroX+" , "+zeroY+" @ "+res);
			
			_viewlinear.left -= zeroX;
			_viewlinear.right -= zeroX;
			_viewlinear.top += zeroY;
			_viewlinear.bottom += zeroY;
							
			var vx:Number = x;
			var vy:Number = y;
			var vw:Number = width;
			var vh:Number = height;

			var stack:Array = getChildren();
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Layer = Layer( stack[ i]);
				temp.x = vx;
				temp.y = vy;
				temp.width = vw;
				temp.height = vh;
				temp.updateView();
			}
				
			x = 0;
			y = 0;
		}
		
		override protected function debug( txt:String):void {
//			trace( "DBG MetaLayer: "+txt);
		}			
	}
}