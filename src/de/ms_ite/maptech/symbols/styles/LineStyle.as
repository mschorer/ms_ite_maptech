//
// an object to keep all style-information for a Line
//

package de.ms_ite.maptech.symbols.styles {

	public class LineStyle {	
		public var color:Number;
		public var alpha:Number;
		public var width:Number;
		
		public function LineStyle( col:Number=0x808080, al:Number=0.8, w:int=1) {
			color = col;
			alpha = al;
			width = w;
		}
		
		public function clone():LineStyle {
			return new LineStyle( color, alpha, width);
		}

		public function fromXML( xml:XMLList):void { 
			color = parseInt( xml.color);
			alpha = parseFloat( xml.alpha);
			width = parseInt( xml.width);
		}
		
		public function toXML():XML {
			var temp:XML = 
			<line>
				<color>{color}</color>
				<alpha>{alpha}</alpha>
				<width>{width}</width>
			</line>
		
			return temp;
		}
	}
}