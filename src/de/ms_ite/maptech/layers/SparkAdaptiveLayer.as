package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.events.ClipEvent;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.controls.*;
	
	public class SparkAdaptiveLayer extends SparkMapLayer {
		
		public static var SCALE_UP:int = -1;
		public static var SCALE_DOWN:int = 0;
		
		protected var _scaleMode:int = SCALE_DOWN;
		
		public function SparkAdaptiveLayer() {
			super();
		}
		
		override public function set layer( i:int):void {
			//			debug( "lay");
		}
		
		public function set scaleMode( sm:int):void {
			_scaleMode = sm;
		}
		public function get scaleMode():int {
			return _scaleMode;
		}

		override protected function getEffectiveRes( res:Point):Point {
			
			_layer = _mapInfo.findNearestLayer( _viewlinear.centerx, _viewlinear.centery, res, scaleMode);
			var newRes:Point = _mapInfo.getResolution( _viewlinear.centerx, _viewlinear.centery, _layer);
			
			debug( "  res ["+_scaleMode+"] ("+_layer+"): "+res.length+"/"+newRes.length);
			
			return newRes;
		}
		
		override protected function clipResolution():void {
			if ( mapInfo == null) return;
			
			// _resolution < _mapInfo.resolution
			if ( Math.min( _mapInfo.resolution.x, _mapInfo.resolution.y) > Math.max( _resolution.x, _resolution.y)) {
				var evt:ClipEvent = new ClipEvent( ClipEvent.CLIP_MAXRES);
				evt.resolution = _mapInfo.resolution;
				//				debug( "clip res");
				
				dispatchEvent( evt);
			}
		}
		/*		
		override protected function debug( txt:String):void {
		trace( this.className+"("+name+"): "+txt);
		}
		*/
	}
}