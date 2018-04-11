package de.ms_ite.maptech.projections {
	import flash.geom.Matrix;
	
	
	public class BirdsEyeParameters {
		
		public var mtxToPixel:Array;
		public var mtxToCoord:Array;
		
		public var id:String;
		public var patch_id:int;
		
		public var hTiles:int, vTiles:int;
		
		public var l:Number, o:Number, s:Number;
		
		public function BirdsEyeParameters( data:Object) {
			id = data.Q;
			patch_id = data.RI;
			
			l = data.L;
			o = data.O;
			s = data.S;
			
			hTiles = data.Fcx;
			vTiles = data.Fcy;
			
			mtxToCoord = new Array( new Array( data.QA, data.QB, data.QC), new Array( data.QD, data.QE, data.QF), new Array( data.QG, data.QH, data.QI));
			mtxToPixel = new Array( new Array( data.XA, data.XB, data.XC), new Array( data.XD, data.XE, data.XF), new Array( data.XG, data.XH, data.XI));
		}

	}
}