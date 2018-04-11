package de.ms_ite.maptech.layers {
	
	import de.ms_ite.*;
	
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	import mx.containers.Canvas;
	import mx.controls.*;						

	public class SimpleLayer extends MapLayer {
		
		public function SimpleLayer() {
			super();
		}
		
		override protected function updateContent( res:Point, effRes:Point, scale:Point):void {

			if ( scale.x > 2 || scale.x < 0.5) {
				visible = false;
				return;
			} else {
				visible = true;
				
				if ( scale.x < 0.75 || scale.x > 1.5) alpha = ( (scale.x > 1) ? (1 / scale.x) : scale.x);
				else scale.x = 1;
//				debug( "scale "+scale);
			}
			
			super.updateContent( res, effRes, scale);
		}
	}
}