package de.ms_ite.maptech.tools {
	import flash.display.Bitmap;
	import flash.display.Graphics;
	
	import mx.controls.Image;

	public class SmoothTile extends Image {
		
		public function SmoothTile() {
			super();
		}
		
		override protected function updateDisplayList (unscaledWidth : Number, unscaledHeight : Number) : void {
			super.updateDisplayList (unscaledWidth, unscaledHeight);
			
			var g:Graphics = this.graphics;
			g.lineStyle( 2, 0xff0000);
			g.drawRect( 0, 0, unscaledWidth-1, unscaledHeight-1);

			// checks if the image is a bitmap
			if (content is Bitmap) {
				var bitmap : Bitmap = content as Bitmap;

				if (bitmap != null && bitmap.smoothing == false) {
					bitmap.smoothing = true;
				}
			}
		}
    }
}