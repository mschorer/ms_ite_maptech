package de.ms_ite.maptech.projections {
	import flash.geom.Point;	
	import de.ms_ite.maptech.*;

	/**
	 * @author flashdynamix
	 */
	public class ProjectionVEBirdsEye extends Projection {

		protected static var SIZE:int = 256;
		
		public var patchParameters:BirdsEyeParameters;
		
		private var _depth : int = 1;
		
		function ProjectionVEBirdsEye(depth:Number = 1){
			this.depth = depth;
		}

		public function get maxRows() : Number {
			return patchParameters.vTiles / (3 - depth);
		}

		public function get maxCols() : Number {
			return patchParameters.hTiles / (3 - depth);
		}
/*		
		public function get rotation():Number{
			var center:Point = pixelToLatLong(new Point(0, 0));
			var offset:Point = pixelToLatLong(new Point(0, 1));
				
			return angleBetween( center, offset);
		}

		protected function angleBetween(p1:Point, p2:Point):Number {
			var x:Number = p2.x-p1.x;
			var y:Number = p2.y-p1.y;
			return Math.atan2(y, x);
		}
*/
		public function set depth(num : int) : void {
			_depth = num;
		}

		public function get depth() : int {
			return _depth;
		}

		override public function screen2coord( pt:Point, _viewlinear:Bounds, res:Point):Point {
			var x : Number = (( SIZE / 2) - pt.x) * maxCols;
			var y : Number = (( SIZE / 2) - pt.y) * maxRows;
			
			var T : Number = Math.pow(2, depth - 2);
			var je : Array = [[x / T], [y / T], [1]];
			var aU : Array = ma( patchParameters.mtxToCoord, je);
			
			var longitude : Number = aU[0][0] / aU[2][0];
			var latitude : Number = aU[1][0] / aU[2][0];
		
			return new Point( longitude, latitude);
		}

		override public function coord2pixel( coord:Point, bounds:Bounds, res:Point):Point {
			var T : Number = Math.pow(2, depth - 2);
			
			var je : Array = [[coord.x], [coord.y], [1]];
			var aU : Array = ma( patchParameters.mtxToPixel, je);
		
			var x : Number = (aU[0][0] / aU[2][0]) * T;
			var y : Number = (aU[1][0] / aU[2][0]) * T;
			
			x = ( SIZE / 2) - (x / maxCols);
			y = ( SIZE / 2) - (y / maxRows);
			
			return new Point(x, y);
		}
/*
		private function ma(af : XMLList, W : Array) : Array {
			var p : int = af.length();
			var q : int = W[0].length;
			var aU : Array = new Array(p);
			var bn : int = W.length;
		
			for (var a : int = 0;a < p; a++) {
				aU[a] = new Array(q);
				for (var Y : int = 0;Y < q; Y++) {
					aU[a][Y] = 0;
					for (var gU : int = 0;gU < bn; gU++) {
						var item:XML = af[a];
						aU[a][Y] += item.child(gU)* W[gU][Y];
					}
				}
			}
		
			return aU;
		}
*/
		private function ma( af:Array, W:Array):Array {
			var p : int = af.length;
			var q : int = W[0].length;
			var aU : Array = new Array(p);
			var bn : int = W.length;
		
			for (var a:int = 0; a < p; a++) {
				aU[a] = new Array(q);
				for ( var Y:int = 0; Y < q; Y++) {
					aU[a][Y] = 0;
					for ( var gU:int = 0; gU < bn; gU++) {
						aU[a][Y] += af[a][gU] * W[gU][Y];
					}
				}
			}
		
			return aU;
		}
	}
}
