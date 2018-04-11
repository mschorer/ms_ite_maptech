package de.ms_ite.maptech.layers {
	
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.containers.Lighttable;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.containers.Canvas;
	import mx.controls.Image;					

	import spark.components.Group;

	public class Layer extends Canvas {
/*		
		[Embed(source='de/ms_ite/assets/symbol_lib.swf#hexa')]
		[Bindable]
		protected var symbolHexa:Class;
		
		protected var orig:Sprite;
*/		
		public var lighttable:Lighttable;
		
		public var debugLevel:int = -1;
		
		protected var _position:Point;
		protected var _viewlinear:Bounds;
		
		protected var _resolution:Point;

		protected var grip:Point;
		
		public function Layer() {
			super();
			
//			alpha = 0.6;
			clipContent = false;
//			setStyle( "borderStyle", 'solid');
			percentWidth = 100;
			percentHeight = 100;
			
			grip = new Point();
			
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';				
/*
			var c:Class = symbolHexa;
			orig = new c();
			rawChildren.addChild( orig);
*/
//			debug( "created.");
		}
		
		override public function addChild( temp:DisplayObject):DisplayObject {
//			debug( " layer addChild: "+temp+" : "+width+"x"+height);
			return super.addChild( temp);
		}

		public function set resolution( r:Point):void {
//			debug( "res "+_resolution+" / "+r);
			_resolution = r;

			clipResolution();
			
			_position = new Point( _viewlinear.centerx, _viewlinear.centery);
			
			var dw:Number = width * _resolution.x * 0.5;
			var dh:Number = height * _resolution.y * 0.5;
			
			if ( _viewlinear == null) _viewlinear = new Bounds();
			_viewlinear.left = _position.x - dw;
			_viewlinear.right = _position.x + dw;
			_viewlinear.bottom = _position.y - dh;
			_viewlinear.top = _position.y + dh;
		}
			
		public function get resolution():Point {
			return _resolution;
		}
		
		public function set position( vp:Point):void {
//			debug( "pos");
			_position = vp;
//				invalidateProperties();
//			updateView();
		}
		
		public function get position():Point {
			return _position;
		}
		
		public function get aspect():Number {
//			return (( _mapInfo != null) ? _mapInfo.tileAspect : 1);
			
			var temp:Number = ( lighttable != null) ? lighttable.projection.aspect : 1;
//			trace( "# aspect: "+temp);
			return temp;
		}
					
		public function set viewport( vp:Bounds):void {
			viewlinear = ( lighttable != null) ? lighttable.projection.linBounds( vp) : vp; 
		}

		public function get viewport():Bounds {
			return ( _viewlinear != null && lighttable != null) ? lighttable.projection.delinBounds( _viewlinear) : null;
		}
		
		public function set viewlinear( vp:Bounds):void {			
			if ( vp == null || lighttable == null) return;
			
//			debug( "~vp "+vp.width+"x"+vp.height);
			
			var vasp:Number = width / height;
			var masp:Number = 1;	//vp.width / vp.height;
/*			
			debug( "~asp: "+vasp+" / "+masp);
			debug( "~asp: "+aspect+"#");
*/
			var w:Number;
			var h:Number;
			
			if ( vasp < masp) {
				// soll ist breiter als view
				w = vp.width;
				h = w / vasp / aspect;
			} else {
				// soll ist schmäler als view
				h = vp.height;
				w = h * vasp * aspect;
			}
//			debug( "~siz: "+w+","+h+" : "+( w/ h));
			
			_position = new Point( vp.centerx, vp.centery);
			
			if ( _viewlinear == null) _viewlinear = new Bounds();
			_viewlinear.left = _position.x - w / 2;
			_viewlinear.right = _position.x + w / 2;
			_viewlinear.bottom = _position.y - h / 2;
			_viewlinear.top = _position.y + h / 2;

			_resolution = new Point( _viewlinear.width / width, _viewlinear.height / height);
//			debug( "~res: "+_resolution);
				
			clipResolution();
//				invalidateProperties();
			updateView();
		}
		
		public function get viewlinear():Bounds {
			return _viewlinear;
		}
		
		protected function clipResolution():void {
			// abstract method
		}

		public function get ready():Boolean {
			if ( _viewlinear == null) return false;
			
			return true;			
		}
				
		public function updateView():void {
//			debug( "rc: "+(_mapInfo == null)+"/"+( _viewlinear == null));
		
			if ( ! ready) return;	
			
			_resolution = new Point( _viewlinear.width / width, _viewlinear.height / height);
			
			var effRes:Point;
			effRes = getEffectiveRes( _resolution);

			var scale:Point = new Point( effRes.x / _resolution.x, effRes.y / _resolution.y);
/*
			debug( "#scale: "+scale+" / "+effRes+" / "+_resolution);			
			debug( "measuX: "+_viewlinear.width+" | "+width);
			debug( "measuY: "+_viewlinear.height+" | "+height);
			debug( "usingX: "+scale+" @ "+_resolution+" / "+effRes);
*/
/*
			var _resolutionY:Number = _viewlinear.height / height;
			var effResY:Number;
			effResY = getEffectiveRes( _resolutionY);			
			var scaleY:Number = effResY / _resolutionY;
			debug( "measuY: "+_viewlinear.height+" | "+height);
			debug( "usingY: "+scaleY+" @ "+_resolutionY+" / "+effResY);
//			debug( "scale: "+scale+" / "+alpha);
*/			
			var zeroX:Number = x * _resolution.x;
			var zeroY:Number = y * _resolution.y;
			
//			debug( "zero: "+x+","+y+"  /  "+zeroX+" , "+zeroY+"   "+scale+" / "+alpha);
//			debug( "scale: "+scale+" / "+alpha);
			
			_viewlinear.left -= zeroX;
			_viewlinear.right -= zeroX;
			_viewlinear.top += zeroY;
			_viewlinear.bottom += zeroY;
			
			scaleX = scale.x;
			scaleY = scale.y;
			x = 0;
			y = 0;
			
			updateContent( _resolution, effRes, scale);
		}
		
		protected function getEffectiveRes( res:Point):Point {
			return _resolution.clone();
		}
		
		protected function updateContent( res:Point, effRes:Point, scale:Point):void {
		}
	
		public function screen2map( x:Number, y:Number):Point {
			return lighttable.projection.screen2coord( new Point( x, y), _viewlinear, _resolution);
		}

/*				
		public function getColor( x:int, y:int):int {
			var bg:BitmapData = new BitmapData( 2000, 1400);	//width, height);
			bg.draw( this);
		
			var pos:Point =  new Point( x, y);
			//pos = localToContent( pos);
			orig.x = pos.x;
			orig.y = pos.y;
				
			var col:int = bg.getPixel32( pos.x, pos.y);
			
			trace( "col: "+" / "+pos.x+","+pos.y+" : "+col+" @ "+width+" x "+height);
			 
			return col;
		}
*/		
		protected function debug( txt:String):void {
//			trace( "DBG L("+name+"): "+txt);
		}					
	}
}