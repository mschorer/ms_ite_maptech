package de.ms_ite.maptech.tools
{
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class ZoomFrameCircle extends ZoomFrame
	{
		public function ZoomFrameCircle()
		{
			super();
		}

		override protected function drawMarker( from:Point, w:Number, h:Number):void {
			debug( "move.");
			graphics.clear();
			graphics.lineStyle( 2, 0);
			graphics.beginFill( 0xff0000, 0.2);
			graphics.drawCircle( from.x, from.y, Math.sqrt( Math.pow( w, 2) + Math.pow( h, 2)));
			graphics.endFill(); 
		}		
	}
}