//
// an object to keep all style-information for a symbol
//

package de.ms_ite.maptech.symbols.styles {
//	import de.msite.symbols.*;
	
	public class GeometryStyle {
		public var line:LineStyle;
		public var surface:SurfaceStyle;
		
		public function GeometryStyle( ls:LineStyle=null, sf:SurfaceStyle=null):void {
			line = ( ls == null) ? new LineStyle() : ls;
			surface = ( sf == null) ? new SurfaceStyle() : sf;
		}
		
		public function clone():GeometryStyle {
			return new GeometryStyle( line.clone(), surface.clone());
		}
		
		public function fromXML( xml:XMLList):void { 
			line.fromXML( xml.line);
			surface.fromXML( xml.surface);
		}

		public function toXML( tag:String):XML {
			var temp:XML = <{tag}></{tag}>;
			temp.appendChild( line.toXML());
			temp.appendChild( surface.toXML());
			
			return temp;
		}

	}
}