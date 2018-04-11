package de.ms_ite.maptech.containers {
	import de.ms_ite.*;
	import de.ms_ite.events.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.mapinfo.*;
	import de.ms_ite.maptech.projections.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import mx.containers.Canvas;
	import mx.effects.Tween;
	import mx.events.*;
	
	import spark.components.Group;
	
	[Event(name="change", type="flash.events.Event")]
	[Event(name="renderChanging", type="de.ms_ite.events.RenderEvent")]
	[Event(name="renderComplete", type="de.ms_ite.events.RenderEvent")]
/*	
	[Event(name=Event.CHANGE,type="flash.events.Event")]
	[Event(name=RenderEvent.RENDER_CHANGING,type="de.msite.events.RenderEvent")]
	[Event(name=RenderEvent.RENDER_COMPLETE,type="de.msite.events.RenderEvent")]
*/	

	public class Lighttable extends Canvas {

		public static var CLIP_NONE:int = 0;
		
		public static var CLIP_LEFT:int = 1;
		public static var CLIP_RIGHT:int = 2;
		public static var CLIP_BOTTOM:int = 4;
		public static var CLIP_TOP:int = 8;
		
		public static var CLIP_H:int = 3;
		public static var CLIP_V:int = 12;
		public static var CLIP_BOUNDS:int = 15;

		public static var CLIP_MIN:int = 16;
		public static var CLIP_MAX:int = 32;

		public static var CLIP_RES:int = 48;
		
		protected var _snapToLevel:Boolean;
		
		protected var mapMask:Shape;
		protected var grip:Point;
		protected var container:Canvas;
		
		protected var _viewlinear:Bounds;
		
		protected var _position:Point;
		protected var _resolution:Point;
		
		protected var _projection:Projection;
		
		protected var _clipBox:Bounds;
		protected var _clipResMin:Number;
		protected var _clipResMax:Number;
		protected var _clipMode:int;
		
		protected var _mapInfo:MapInfo;

		protected var _loadQueue:LoadQueue;
		protected var _moveTween:Tween;
		protected var _tweenPos:Point;
		
		protected var updateLevel:int;
		
//		protected var _tweenBase:Number;
//		protected var _tweenDelta:Number;
		
		public function Lighttable()
		{
			super();
			doubleClickEnabled = true;
		
			_snapToLevel = false;
			
			updateLevel = 0;	
			_clipMode = CLIP_NONE;
			
			grip = new Point();
			mapMask = new Shape();
			rawChildren.addChild( mapMask);
			mask = mapMask;
			
			container = new Canvas();
			container.clipContent = false;
			container.horizontalScrollPolicy = 'off';
			container.verticalScrollPolicy = 'off';
			container.percentWidth = 100;
			container.percentHeight = 100;
			addChild( container);
			
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';
			percentWidth = 100;
			percentHeight = 100;

			addEventListener( MouseEvent.DOUBLE_CLICK, handleMouseDClick);
			addEventListener( Event.RESIZE, handleResize);
			handleResize( null);

			addEventListener( MouseEvent.MOUSE_DOWN, handleMouseDown);
			addEventListener( MouseEvent.MOUSE_UP, handleMouseUp);
			addEventListener( MouseEvent.MOUSE_OUT, handleMouseUp);
			
			addEventListener( MouseEvent.MOUSE_WHEEL, handleMouseWheel);		
		}
		
		override public function addChild( temp:DisplayObject):DisplayObject {
			
			if ( temp is Layer) {
//				debug( "addLayer: "+temp+" : "+width+"x"+height);
				
				var layer:Layer = Layer( temp);
				layer.lighttable = this;
				layer.width = width;
				layer.height = height;
				layer.viewport = viewport;
				
				return container.addChild( layer);
			} else {
//				debug( "addChild: "+temp+" : "+width+"x"+height);
				
				return super.addChild( temp);
			}
		}

		override public function removeChild( temp:DisplayObject):DisplayObject {
			
			if ( temp is Layer) {
//				debug( "removeLayer: "+temp);				
				Layer( temp).lighttable = null;
				return container.removeChild( temp);
			} else {
//				debug( "addChild: "+temp);
				return super.removeChild( temp);
			}			
		}

		override public function setChildIndex( child:DisplayObject, newIndex:int):void {
			container.setChildIndex( child, newIndex);
		}

		override public function getChildIndex( child:DisplayObject):int {
			return container.getChildIndex( child);
		}


		public function set projection( p:Projection):void {
			_projection = p;
		}
		
		public function get projection():Projection {
			return _projection;
		}
		
		public function toFront( layer:DisplayObject):void {
			if ( layer is Layer) container.setChildIndex( layer, container.numChildren -1);
			else setChildIndex( layer, numChildren -1);
		}

	    public function get bounds():Bounds {
	    	return _mapInfo.bounds;
	    }

		public function set mapInfo( mi:MapInfo):void {
			debug( "mi");
			_mapInfo = mi;
			_projection = mi.projection;
/*
			var stack:Array = container.getChildren();			
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Layer = Layer( stack[ i]);
				if ( temp is MapLayer) MapLayer( temp).mapInfo = _mapInfo;
			}
*/
			handleResize( null);

			var vp:Bounds = viewport;
			if ( vp != null) {
//				viewport = vp;
				if ( mi.bounds.isWithinCoord( vp.left, vp.bottom) && mi.bounds.isWithinCoord( vp.right, vp.top)) updateView();
			} else viewport = mi.bounds;			
		}
			
		public function get mapInfo():MapInfo {
			return _mapInfo;
		}
		
		public function get aspect():Number {
			return (( _mapInfo != null) ? _mapInfo.projection.aspect : 1);
		}

		public function set viewport( vp:Bounds):void {
//			debug( "set vp: "+vp.top+" / "+vp.bottom);
			var v:Bounds = projection.linBounds( vp);
//			debug( "set vp lin: "+v.top+" / "+v.bottom);
			viewlinear = v;
		}

		public function get viewport():Bounds {
			if ( _viewlinear == null) return null;
			
//			debug( "get vp lin: "+_viewlinear.top+" / "+_viewlinear.bottom);
			var v:Bounds = ( _viewlinear != null) ? projection.delinBounds( _viewlinear) : null;
//			debug( "get vp: "+v.top+" / "+v.bottom);
			return v;
		}		

		public function set viewlinear( vp:Bounds):void {
//			debug( "# vp "+vp);
			
			if ( vp == null) return;
//			debug( "vp set     "+Math.round(vp.width)+"x"+Math.round(vp.height)+" @ "+vp);

			/**FIXME: correct clipping for non-linear projections */
			var clip:int = CLIP_NONE;

			if ( _clipMode & CLIP_BOUNDS) {
				if ( _clipMode & CLIP_LEFT && vp.left < mapInfo.bounds.left) { clip |= CLIP_LEFT; vp.left = mapInfo.bounds.left; }
				if ( _clipMode & CLIP_RIGHT && vp.right > mapInfo.bounds.right) { clip |= CLIP_RIGHT; vp.right = mapInfo.bounds.right; }
	
				if ( _clipMode & CLIP_BOTTOM && vp.bottom < mapInfo.bounds.bottom) { clip |= CLIP_BOTTOM; vp.bottom = mapInfo.bounds.bottom; }
				if ( _clipMode & CLIP_TOP && vp.top > mapInfo.bounds.top) { clip |= CLIP_TOP; vp.top = mapInfo.bounds.top; }
				
 //				if ( clip & CLIP_BOUNDS) debug( "clip X: "+clip);
			}
 			
//			debug( "   clipped "+Math.round(vp.width)+"x"+Math.round(vp.height)+" @ "+clip+" / "+vp);
			
//			debug( "# aspect: "+aspect);
			debug( "VIEW: "+vp);
			
			if ( vp.width != 0 && vp.height != 0) {
				debug( "# view: "+width+" x "+height+" / "+(width / height));
				var vasp:Number = width / height;
				var masp:Number = (vp.width / aspect) / vp.height;
				
				debug( "# view/map: "+vasp+" / "+masp);
				
				var w:Number;
				var h:Number;
				
				if ( vasp < masp) {
					// soll ist breiter als view
					debug( "V");
					if ( clip == CLIP_V) {
						h = vp.height;
						w = vp.height * masp * aspect;

						debug( "1: "+w+" = "+vp.height+" * "+masp+" * "+aspect);
					} else {
						w = vp.width;
						h = vp.width / masp / aspect;
						
						debug( "2: "+h+" = "+vp.width+" / "+masp+" / "+aspect);
					}
				} else {
					// soll ist schmäler als view
					debug( "H");
					if ( clip == CLIP_H) {
						w = vp.width;
						h = vp.width / vasp / aspect;						

						debug( "1: "+h+" = "+vp.width+" / "+vasp+" / "+aspect);
					} else {
						h = vp.height;
						w = vasp * vp.height * aspect;

						debug( "2: "+w+" = "+vp.height+" * "+vasp+" * "+aspect);
					}
				}
//				debug( "# asp: "+vasp+" : "+masp);
//				debug( "# siz: "+w+","+h+" : "+( w/ h));
				
				var temppos:Point = new Point( vp.centerx, vp.centery);
				
				var tempview:Bounds = new Bounds( temppos.x - w / 2, temppos.y - h / 2, temppos.x + w / 2, temppos.y + h / 2);
				debug( "  VIEW2: "+tempview);
/*
				_viewlinear.left = _position.x - w / 2;
				_viewlinear.right = _position.x + w / 2;
				_viewlinear.bottom = _position.y - h / 2;
				_viewlinear.top = _position.y + h / 2;
*/				
//				debug( "## lt: "+_projection.c2p( new Point( _viewlinear.left, _viewlinear.top)));
//				debug( "## rb: "+_projection.c2p( new Point( _viewlinear.right, _viewlinear.bottom)));

//				debug( "# set view: "+tempview);
				var tempres:Point = new Point( tempview.width / width, tempview.height / height);

				if ( _resolution != null) {
					if ( _clipMode & CLIP_MAX && Math.min( tempres.x, tempres.y) < _clipResMax) {
//						debug( "clip max: "+_clipResMax+" / "+Math.min( tempres.x, tempres.y));
						clip |= CLIP_MAX;
					}
					if ( _clipMode & CLIP_MIN && Math.max( tempres.x, tempres.y) < _clipResMin) {
//						debug( "clip min: "+_clipResMin+" / "+Math.max( tempres.x, tempres.y));
						clip |= CLIP_MIN;
					}
					if ( clip & CLIP_RES) {
						debug( "clip Z "+(clip & CLIP_MIN)+" / "+(clip & CLIP_MAX));
						return;
					}
				}
				
				if ( _snapToLevel) {
					var matchLevel:int = _mapInfo.findNearestLayer( 0,0, tempres);
					var matchRes:Point = _mapInfo.getResolution( 0,0, matchLevel);

//					var pView:Bounds = projection.delinBounds( tempview);
//					var pRes:Point = new Point( pView.width / width, pView.height / height);
					
					var scale:Number = matchRes.y / tempres.y;
					
					var vn:Bounds = tempview.scale( scale);
					
					debug( " => "+scale+" : "+tempres.y+" / "+matchRes.y+" : "+tempview.width+","+tempview.height+" / "+vn.width+","+vn.height);
					
					tempres = matchRes;
					tempview = vn;
					
					debug( "  view: "+vn);
				}
			
				_resolution = tempres;
				_position = temppos;				

				if ( _viewlinear == null) _viewlinear = new Bounds();
				
				debug( "view: "+vp.width+","+vp.height+" - "+tempview.width+","+tempview.height);
				debug( "view: "+vp.centerx+","+vp.centery+" - "+tempview.centerx+","+tempview.centery);
				
				_viewlinear = tempview;
			
//				debug( "# res: "+_resolution);
			} else {
//				debug( "max zoom: "+vp.left+","+vp.top);
				_viewlinear = vp;
				resolution = new Point( _mapInfo.bounds.width / _mapInfo.width, _mapInfo.bounds.height / _mapInfo.height);
			}
//				invalidateProperties();
//			handleClipping();
/*
			var stack:Array = container.getChildren();			
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Layer = Layer( stack[ i]);
//				if ( temp is MapLayer) MapLayer( temp).mapInfo = _mapInfo;
				temp.viewport = _viewlinear.clone();
			}
*/
			updateView( true);
//			debug( "set viewport: "+_viewlinear);
		}
		
		public function get viewlinear():Bounds {
			return _viewlinear;
		}
		
		public function set snapToLevel( b:Boolean):void {
			_snapToLevel = b;
			if ( viewlinear != null) viewlinear = viewlinear.clone();
		}
		
		public function get snapToLevel():Boolean {
			return _snapToLevel;
		}
/*
		public function screen2map( x:Number, y:Number):Point {
			return projection.screen2coord( new Point( x, y), _viewlinear, _resolution);
		}
*/		
		protected function setClipBox():void {
			if ( mapInfo == null) return;
			if ( _clipBox == null) _clipBox = new Bounds();
			
			_clipBox.left = (_viewlinear.left - mapInfo.bounds.left) / _resolution.x;	
			_clipBox.right = (_viewlinear.right - mapInfo.bounds.right) / _resolution.x;	
			_clipBox.bottom = ( mapInfo.bounds.bottom - _viewlinear.bottom) / _resolution.y;	
			_clipBox.top = ( mapInfo.bounds.top - _viewlinear.top) / _resolution.y;
			
//			debug( "set clipbox: "+int(_clipBox.left)+","+int(_clipBox.bottom)+","+int(_clipBox.right)+","+int(_clipBox.top));
		}
		
		public function setClipMode( m:int, val:Number=-1, valmax:Number=-1):void {
			debug( "clip mode: "+m+" / "+val+"/"+valmax);
			
			_clipMode = m;
			
			if ( m & CLIP_MIN && m & CLIP_MAX) {
				_clipResMin = val;
				_clipResMax = valmax;
			} else {
				if ( m & CLIP_MIN) _clipResMin = val;
				if ( m & CLIP_MAX) _clipResMax = val;
			}
		}
/*		
		protected function handleClipping():void {
			if ( _mapInfo == null) return;
			
//			debug( "chk clip: "+_resolution+" < "+_mapInfo.resolution);
			if ( _clipMode & CLIP_MAX && Math.min( _resolution.x, _resolution.y) < _clipResMax) {
				debug( "clip max: "+_clipResMax+" / "+Math.min( _resolution.x, _resolution.y));
			}
			if ( _clipMode & CLIP_MIN && Math.max( _resolution.x, _resolution.y) < _clipResMin) {
				debug( "clip min: "+_clipResMin+" / "+Math.max( _resolution.x, _resolution.y));
			}
			
			if ( _resolution.x < _mapInfo.resolution.x || _resolution.y < _mapInfo.resolution.y) {
//				debug( "clip res");
			}
		}
*/
		public function set resolution( r:Point):void {
//			debug( "res "+mapInfo.name+" : "+mapInfo.resolution+" / "+r);
			
			if (( _clipMode & CLIP_MAX && Math.min( r.x, r.y) < _clipResMax) || 
				( _clipMode & CLIP_MIN && Math.max( r.x, r.y) < _clipResMin)) {
				debug( "clip RES.");
				return;		
			}
			
			_resolution = r;

			_position = new Point( _viewlinear.centerx, _viewlinear.centery);
			
			var dw:Number = width * r.x * 0.5;
			var dh:Number = height * r.y * 0.5;
			
			if ( _viewlinear == null) _viewlinear = new Bounds();
			_viewlinear.left = _position.x - dw;
			_viewlinear.right = _position.x + dw;
			_viewlinear.bottom = _position.y - dh;
			_viewlinear.top = _position.y + dh;
			
//			debug( "  view: "+dw+"/"+dh+" @ "+_resolution+" : "+_viewlinear);
		}
			
		public function get resolution():Point {
			return _resolution;
		}	

 		public function zoomOut():void {
 			viewlinear = _viewlinear.scale( _snapToLevel ? 2.0 : 1.05);
 		}

 		public function zoomIn():void {
 			viewlinear = _viewlinear.scale( _snapToLevel ? 0.5 : 0.95); 			
 		}
 		
 		protected function handleMouseWheel( evt:MouseEvent):void {
 			if ( evt.delta < 0) zoomOut();
 			else zoomIn();
 		}

		protected function handleMouseMove( evt:MouseEvent):void {
			var dx:Number = evt.stageX - grip.x;
			var dy:Number = evt.stageY - grip.y;
			
//			debug( "clipbox: "+int(_clipBox.left)+" > "+dx+" > "+int(_clipBox.right)+"  |  "+int(_clipBox.bottom)+" < "+dy+" < "+int(_clipBox.top));

			if ( _clipMode & CLIP_RIGHT && dx < _clipBox.right) dx = _clipBox.right;
			if ( _clipMode & CLIP_LEFT && dx > _clipBox.left) dx = _clipBox.left;

			if ( _clipMode & CLIP_BOTTOM && dy < _clipBox.bottom) dy = _clipBox.bottom;
			if ( _clipMode & CLIP_TOP && dy > _clipBox.top) dy = _clipBox.top;
		
			container.x = dx;
			container.y = dy;

//			debug( "move "+dx+","+dy);
		}
		
		protected function handleMouseDown( evt:MouseEvent):void {
			
			if ( _moveTween == null) {
//				removeEventListener( MouseEvent.MOUSE_MOVE, handleMouseMove);
/*
				addEventListener( MouseEvent.MOUSE_MOVE, handleMouseMove);
				grip.x = evt.stageX;
				grip.y = evt.stageY;
*/				
				container.startDrag( false);	//, new Rectangle( _clipBox.left, _clipBox.right, _clipBox.width, _clipBox.height));
			}
			
			dispatchEvent( new RenderEvent( RenderEvent.RENDER_CHANGING));

//			debug( "drag start");
			// prevent events from "falling through"
//			evt.stopPropagation();
		}

		protected function handleMouseUp( evt:MouseEvent):void {
			container.stopDrag();			
//			removeEventListener( MouseEvent.MOUSE_MOVE, handleMouseMove);

//			debug( "drag stop");
//			invalidateProperties();
			if ( _moveTween == null) updateView();
		}		
		
		protected function handleMouseOut( evt:MouseEvent):void {
//			container.stopDrag();
			
//			removeEventListener( MouseEvent.MOUSE_MOVE, handleMouseMove);
			debug( "------------------------------------------  drag stop");
//			invalidateProperties();
			if ( _moveTween == null) updateView();
		}		
		
		
		public function handleMouseDClick( evt:MouseEvent):void {
//			debug( "tween start @ "+click);
			if ( _moveTween != null) return;
			
			var click:Point = globalToLocal( new Point( evt.stageX, evt.stageY));
			
			if ( _tweenPos == null) _tweenPos = new Point();
			
			_tweenPos.x = ( width * 0.5) - click.x;
			_tweenPos.y = ( height * 0.5) - click.y;

/*			var r:Number = Math.max( resolution.x, resolution.y)
//			_tweenBase = r;
			if ( evt.ctrlKey) _tweenDelta = r * 0.2;
			else _tweenDelta = - r * 0.2;
*/			
			var dist:Number = 6 * Math.sqrt( _tweenPos.x*_tweenPos.x + _tweenPos.y*_tweenPos.y);
			
			_moveTween = new Tween( this, 0, 1, dist);				
        }

        // Override onTweenUpdate() method.
        public function onTweenUpdate( val:Number):void {
            container.x = val * _tweenPos.x;
            container.y = val * _tweenPos.y;
            
            debug( "tween: "+container.x+","+container.y);
/*
//			_resolution = _tweenBase + _tweenDelta * val;
			var stack:Array = container.getChildren();			
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Layer = Layer( stack[ i]);
				temp.resolution = _tweenBase + _tweenDelta * val;
				temp.updateView();
			}
*/
        }
  
        // Override onTweenEnd() method.
        public function onTweenEnd(val:Number):void {
        	_moveTween = null;
        	updateView();
        	
        	dispatchEvent( new RenderEvent( RenderEvent.RENDER_COMPLETE));
        }

		protected function handleResize( evt:ResizeEvent):void {
//			debug( "resize:  "+_viewlinear+" @ "+_resolution);
			debug( "  resize:  "+width+" x "+height);

			if ( width == 0 || height == 0) return;
			
			//recalc viewport based on current resolution, left and top
			if ( _viewlinear != null) {
//				debug( "from: "+_viewlinear.right+" x "+_viewlinear.bottom);
				_viewlinear.right = _viewlinear.left + width * _resolution.x; 
				_viewlinear.bottom = _viewlinear.top - height * _resolution.y;
//				debug( "  to: "+_viewlinear.right+" , "+_viewlinear.bottom);
			} 

			mapMask.graphics.clear();
			mapMask.graphics.lineStyle(1, 0x000000);
			mapMask.graphics.beginFill( 0xff0000, 0.4);
			mapMask.graphics.drawRect(0, 0, width, height);
			mapMask.graphics.endFill();
			
			updateView( true);
		}

		public function updateView( setView:Boolean=false):void {			
//			super.commitProperties();
			if ( _viewlinear == null) return;
/*
			_resolution.x = _viewlinear.width / width;
			_resolution.y = _viewlinear.height / height;			
*/
			// get offset						
			var vx:Number = container.x;
			var vy:Number = container.y;

			// reset container to zero
			container.x = 0;
			container.y = 0;

			// calculate offset in coordinate space
			var zeroX:Number = vx * _resolution.x;
			var zeroY:Number = vy * _resolution.y;
			
			debug( "#zero: "+width+","+height+"  /  "+zeroX+" , "+zeroY /*+" @ "+_resolution*/);
			debug( "#zero: "+_resolution);

			// correct coordinates
			_viewlinear.left -= zeroX;
			_viewlinear.right -= zeroX;
			_viewlinear.top += zeroY;
			_viewlinear.bottom += zeroY;

			// let listeners know about new coordiantes
			if ( updateLevel++ == 0) dispatchEvent( new Event( Event.CHANGE));
			updateLevel--;
			
//			debug( "zero("+setView+"): "+_viewlinear);
/*
			if ( _viewlinear.left > _mapInfo.bounds.right) _viewlinear.translate( -_mapInfo.bounds.width, 0);
			if ( _viewlinear.left < _mapInfo.bounds.left) _viewlinear.translate( _mapInfo.bounds.width, 0);

			if ( _viewlinear.bottom > _mapInfo.bounds.top) _viewlinear.translate( 0, -_mapInfo.bounds.height);
			if ( _viewlinear.bottom < _mapInfo.bounds.bottom) _viewlinear.translate( 0, _mapInfo.bounds.height);
*/
//			debug( "      zero3: "+_viewlinear);
			
//			handleClipping();
							
			var vw:Number = width;
			var vh:Number = height;

			// shift off the content, let the content recalculate and re-zero
			debug( "------layers-------");
			var stack:Array = container.getChildren();			
			for( var i:int = 0; i < stack.length; i++) {
				var temp:Layer = Layer( stack[ i]);
				
				temp.x = vx;
				temp.y = vy;
				temp.width = vw;
				temp.height = vh;

//				if ( setView) temp.viewport = viewport;
				temp.updateView();
				temp.viewport = viewport;
			}
			debug( "-------------------");
			
			setClipBox();
			
//			dispatchEvent( new Event( Event.CHANGE));
		}
		
		protected function debug( txt:String):void {
//			trace( "DBG LT: "+txt);
		}
	}
}