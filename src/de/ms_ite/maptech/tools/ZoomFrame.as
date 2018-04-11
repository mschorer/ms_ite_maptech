package de.ms_ite.maptech.tools {
	import de.ms_ite.*;
	import de.ms_ite.events.MouseSelectionEvent;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.containers.*;
	import de.ms_ite.maptech.layers.*;
	
	import flash.events.*;
	import flash.geom.Point;
	
	import mx.containers.*;

	public class ZoomFrame extends Canvas {
		
		protected var _origin:Point;
		protected var _release:Point;
		
		public var minSel:Number = -1;
		public var maxSel:Number = -1;
		
		public function ZoomFrame() {
			super();
			
			percentWidth = 100;
			percentHeight = 100;
			
			addEventListener( MouseEvent.DOUBLE_CLICK, handleDown);
			addEventListener( MouseEvent.MOUSE_UP, handleUp);
		}
		
		override public function set enabled( b:Boolean):void {
			if ( b) {
				graphics.clear();
				_origin = null;
			}
			
			super.enabled = b;
		}

		protected function handleDown( evt:MouseEvent):void {
			
//			if ( !evt.ctrlKey) return;

			debug( "down: "+evt.ctrlKey+" / "+evt.localX+" , "+evt.localY);
			
			if ( _origin == null) addEventListener( MouseEvent.MOUSE_MOVE, handleMove);
			graphics.clear();
			
			_origin = new Point( evt.localX, evt.localY);
			
			evt.stopImmediatePropagation();
			
			handleMove( evt);
		}		

		protected function handleUp( evt:MouseEvent):void {
			debug( "up: "+evt.localX+" , "+evt.localY);
			
			if ( _origin == null) return;
			
			_release = new Point( evt.localX, evt.localY);
			
			var width:Number = evt.localX - _origin.x;
			var height:Number = evt.localY - _origin.y;
			
			var s:Point = limitPixSize( width, height);
			
			width = s.x;
			height = s.y;
			
			var p1:Point = toCoord( _origin.x, _origin.y);
			var p2:Point = toCoord( _origin.x + width, _origin.y + height);
			
			setSymbol( _origin, _release);
			
			debug( "select: "+_origin+" / "+p1+" / "+p2);
			_origin = null;
			graphics.clear();
			
			removeEventListener( MouseEvent.MOUSE_MOVE, handleMove);

			var me:MouseSelectionEvent = new MouseSelectionEvent( MouseSelectionEvent.MOUSE_SELECT);
			me.origin = p1;
			me.release = p2;
			dispatchEvent( me);			
		}
		
		protected function setSymbol( o:Point, r:Point):void {
		}
		
		protected function limitPixSize( w:Number, h:Number):Point {

			var res:Point = Lighttable( parent).resolution;
			var csize:Point = new Point( w * res.x,h * res.y);
			var size:Point = new Point( w, h);
			
			var len:Number = Math.sqrt( Math.pow( csize.x, 2) + Math.pow( csize.y, 2));
			
			debug( "size: "+len+" : "+csize);
			
			if ( minSel >= 0 && len < minSel) {
				if ( len > 0) {
					size.x = size.x * (minSel / len);
					size.y = size.y * (minSel / len);
				} else {
					size.x = Math.SQRT1_2 * minSel / res.x;
					size.y = Math.SQRT1_2 * minSel / res.y;
				}
				debug( "upscale: "+size);
			}
			if ( maxSel >= 0 && maxSel < len) {
				size.x = size.x * (maxSel / len);
				size.y = size.y * (maxSel / len);					
				debug( "downscale: "+size);
			}
			
			return size;
		}
		
		protected function handleMove( evt:MouseEvent):void {
//			debug( "move");
			if ( _origin != null) {
				var size:Point = limitPixSize( evt.localX - _origin.x, evt.localY - _origin.y);
				
				drawMarker( _origin, size.x, size.y);
			} 
		}
		
		protected function drawMarker( from:Point, w:Number, h:Number):void {
			graphics.clear();
			graphics.lineStyle( 2, 0);
			graphics.beginFill( 0xff0000, 0.2);
			graphics.drawRect( from.x, from.y, w, h);
			graphics.endFill();
		}
		
		protected function toCoord( x:Number, y:Number):Point {
			var vp:Bounds = Lighttable( parent).viewport;
			
//			debug( "  vp: "+vp.width+" x "+vp.height+" / "+vp);
			var temp:Point = new Point();
			temp.x = vp.left + ( x / width) * vp.width;
			temp.y = vp.top - ( y / height) * vp.height;
//			debug( "  pt: "+x+","+y+" => "+temp);
			return temp;  
		}

		protected function debug( txt:String):void {
			trace( "DBG ZF: "+txt);
		}		
	}
}