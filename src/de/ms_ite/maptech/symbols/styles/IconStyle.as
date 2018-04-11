//
// an object to keep all style-information for a Icon
//

package de.ms_ite.maptech.symbols.styles {

	public class IconStyle {
		public static var ICON_OFF:int = 0;
		public static var ICON_MAP:int = 1;
		public static var ICON_NAME:int = 2;
		
		public var icon:String;
		public var iconSmall:String;
		public var mode:int;
		public var scale:Number;
		public var alpha:Number;
		public var color:uint;
		
		public function IconStyle( nrm:String='Default', sm:String='Default', md:int=1, cl:uint=0xffffffff, sc:Number=1, alp:Number=1) {
			icon = nrm;
			iconSmall = sm;
			mode = md;
			color = cl;
			scale = sc;
			alpha = alp;
		}
		
		public function clone():IconStyle {
			return new IconStyle( icon, iconSmall, mode, color, scale, alpha);
		}

		public function fromXML( xml:XMLList):void { 
			icon = xml.icon;
			iconSmall = xml.iconSmall;
			mode = parseInt( xml.mode);
			scale = parseFloat( xml.scale);
			alpha = parseFloat( xml.alpha);
			color = parseInt( xml.color);
		}

		public function toXML():XML {
			var temp:XML = 
			<icon>
				<icon>{icon}</icon>
				<iconSmall>{iconSmall}</iconSmall>
				<mode>{mode}</mode>
				<color>{color}</color>
				<scale>{scale}</scale>
				<alpha>{alpha}</alpha>
			</icon>
			
			return temp;
		}

	}
}