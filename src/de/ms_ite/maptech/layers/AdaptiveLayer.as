package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	import de.ms_ite.events.ClipEvent;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.controls.*;
	
	[Event(name="change", type="flash.events.Event")]

	public class AdaptiveLayer extends MapLayer {
		
		public static var SCALE_UP:int = -1;
		public static var SCALE_DOWN:int = 0;
		
		protected var _scaleMode:int = SCALE_DOWN;

		public function AdaptiveLayer() {
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
/*
		override protected function getEffectiveResOrig( res:Point):Point {
			var effRes:Point;
//			_layer = 0;
			
			var lowerRes:Point;
			var higherRes:Point;

			// don't go beyond deepeest layer
			for( var j:int = 0; j < _mapInfo.resolutionPerLevel.length; j++) {
//				debug( "  res("+j+"): "+res+" / "+_mapInfo.resolutionPerLevel[ j]+" == "+_mapInfo.getResolution( _viewport.centerx, _viewport.centery, j));
				
				higherRes = _mapInfo.getResolution( _viewlinear.centerx, _viewlinear.centery, j);
//				effRes = _mapInfo.resolutionPerLevel[j];

//				debug( "  res("+j+"): "+res+" / "+higherRes+" / "+lowerRes);
				
//				if ( res > _mapInfo.resolutionPerLevel[ j]) break;
				if ( Math.min( res.x, res.y) * aspect >= Math.max( higherRes.x, higherRes.y)) break;
//				_layer++;
				lowerRes = higherRes;
			}
			
			switch( _scaleMode) {
				case SCALE_UP:
					_layer = Math.min( j + _scaleMode, _mapInfo.resolutionPerLevel.length-1);
					effRes = lowerRes;
					break;
					
				case SCALE_DOWN:
				default:
					_layer = Math.min( j, _mapInfo.resolutionPerLevel.length-1);
					effRes = higherRes;
			}

//			_layer = Math.min( j, _mapInfo.resolutionPerLevel.length-1);
			debug( "  res ["+_scaleMode+"] ("+_layer+"): "+res+" / "+lowerRes+"/"+effRes+"/"+higherRes);
			
			return effRes;
		}
*/
		override protected function getEffectiveRes( res:Point):Point {
			
			var new_layer:int = _mapInfo.findNearestLayer( _viewlinear.centerx, _viewlinear.centery, res, scaleMode);
			
			if ( new_layer != _layer) {
				_layer = new_layer;
				dispatchEvent( new Event( Event.CHANGE));
			}
			
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