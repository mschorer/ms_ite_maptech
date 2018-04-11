package de.ms_ite.maptech {
	
	import flash.geom.*;
	
	public class Bounds {
		
		public var left:Number;
		public var bottom:Number;
		public var right:Number;
		public var top:Number;
		
		protected var valid:Boolean;

		public function Bounds( l:Number=0, b:Number=0, r:Number=0, t:Number=0) {
			valid = ( l != 0 && b!= 0 && r != 0 && t != 0);
			
			left = l;
			top = t;
			right = r;
			bottom = b;
		}
		
		public function isValid():Boolean {
			return valid;	//((left != 10000000) && (bottom!=10000000) && (right!=-10000000) && (top!=-10000000));
		}
		
		public function clone():Bounds {
			var temp:Bounds = new Bounds();
			temp.left = left;
			temp.right = right;
			temp.top = top;
			temp.bottom = bottom;
			
			temp.valid = true;	//valid;
			
			return temp;
		}
		
		public function isWithin( p:Point):Boolean {
			return ( left <= p.x && p.x <= right && bottom <= p.y && p.y <= top);
		}
		
		public function get width():Number {
			return Math.abs( right - left);
		}
		
		public function get height():Number {
			return Math.abs( top - bottom);
		}
		
		public function isWithinCoord( px:Number, py:Number):Boolean {
			return ( left <= px && px <= right && bottom <= py && py <= top);
		}
		
		public function mbrAddCoord( x:Number, y:Number):void {
//			trace( "add "+x+","+y);
			
			if ( x < left || ! valid || isNaN( left)) left = x;
			if ( x > right || ! valid || isNaN( right)) right = x;
			if ( y < bottom || ! valid || isNaN( bottom)) bottom = y;
			if ( y > top || ! valid || isNaN( top)) top = y;
			valid = true;
		}
		
		public function mbrAddPoint( p:Point):void {
			if ( p == null) return;
			mbrAddCoord( p.x, p.y);
		}
		
		public function mbrAddBounds( r:Bounds):void {
			if (( r == null) ? true : ( ! r.valid)) return;
			
			mbrAddCoord( r.left, r.bottom);
			mbrAddCoord( r.right, r.top);
		}
		
		public function getExpandedPx( dx:Number, dy:Number):Bounds {
			var t:Bounds = new Bounds();
			t.valid = valid;
			t.left = left - dx;
			t.right = right + dx;
			t.top = top + dy;
			t.bottom = bottom - dy;
			
			return t;
		}
		
		public function clip( clip:Bounds):void {
			left = Math.max( left, clip.left);
			right = Math.min( right, clip.right);
			bottom = Math.max( bottom, clip.bottom);
			top = Math.min( top, clip.top);
		}
		
		public function intersects( b:Bounds):Boolean {
			var r:Bounds = b.clone();
			r.clip( b);
			
			return ( r.left <= r.right && r.bottom <= r.top);
		}
		
		public function get centerx():Number {
			return (( left + right) / 2);
		}
	
		public function get centery():Number {
			return (( top + bottom) / 2);
		}
		
		public function get center():Point {
			return new Point( centerx, centery);
		}
		
		public function set centerx( x:Number):void {
			var off:Number = x - centerx;
			left += off;
			right += off;
		}
		
		public function set centery( y:Number):void {
			var off:Number = y - centery;
			top += off;
			bottom += off;
		}
		
		public function set center( p:Point):void {
			centerx = p.x;
			centery = p.y;
		}
		
		public function translate( vx:Number, vy:Number):Bounds {
			left += vx;
			right += vx;
			bottom += vy;
			top += vy;
			
			return this;
		}
		
		public function scale( sc:Number):Bounds {
			var mx:Number = centerx;
			var my:Number = centery;

			var b:Bounds = new Bounds();
			b.left = mx + ( left - mx) * sc;
			b.right = mx + ( right - mx) * sc;
			b.top = my + ( top - my) * sc;
			b.bottom = my + ( bottom - my) * sc;
			
			return b;
		}
		
		public function toString():String {
			return 'POLYGON(( '+left+' '+bottom+', '+left+' '+top+', '+right+' '+top+', '+right+' '+bottom+', '+left+' '+bottom+'))';
		}
	}
}