//
// an object to keep all style-information for a Surface
//

package de.ms_ite.maptech.symbols.styles {
	
	public class SurfaceStyle {
		public var color:Number;
		public var alpha:Number;
		public var fill:Boolean;
		
		public function SurfaceStyle( col:Number=0xc0c0c0, al:Number=0.3, fl:Boolean=true):void {
			color = col;
			alpha = al;
			fill = fl;
		}
		
		public function clone():SurfaceStyle {
			return new SurfaceStyle( color, alpha, fill);
		}
		
		public function fromXML( xml:XMLList):void { 
			color = parseInt( xml.color);
			alpha = parseFloat( xml.alpha);
			fill = (xml.fill == 'true') ? true : false;
		}
		
		public function toXML():XML {
			var temp:XML = 
			<surface>
				<color>{color}</color>
				<alpha>{alpha}</alpha>
				<fill>{fill}</fill>
			</surface>
		
			return temp;
		}

	}
}