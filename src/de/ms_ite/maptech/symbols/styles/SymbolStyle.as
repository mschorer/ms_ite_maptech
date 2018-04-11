//
// an object to keep all style-information for a symbol
//

package de.ms_ite.maptech.symbols.styles {

	import flash.xml.*;
	import flash.geom.*;
	
	import mx.utils.*;
	
	public class SymbolStyle {
		public var icon:IconStyle;
		
		public var normal:GeometryStyle;
//		public var highlight:GeometryStyle;
		public var selected:GeometryStyle;
		
		public var data:DataStyle;
		
		public var flex:Object;

		public static var SCALE_SCREEN:Number = 0;
		public static var SCALE_UNIT:Number = 1;
		
		public var scaleMode:Number;
		
	//	public var geomSensitive:Boolean;
		
	//	public var icon:IconStyle;

		public function SymbolStyle( xml:XMLList=null) {
	
			debug( "creating style");
			
			icon = new IconStyle();
			data = new DataStyle();
			
			normal = new GeometryStyle();
			selected = new GeometryStyle();
			selected.line.color = 0xff0000;
			
			scaleMode = SCALE_SCREEN;
		}
		
		public function toXML():XML {
			var temp:XML = <style><scaleMode>{scaleMode}</scaleMode></style>
			temp.appendChild( icon.toXML());
			temp.appendChild( data.toXML());
			temp.appendChild( normal.toXML( 'normal'));
			temp.appendChild( selected.toXML( 'selected'));
			
			return temp;
		}

		public function fromXML( xml:XMLList):void { 
			icon.fromXML( xml.icon);
			data.fromXML( xml.data);
			normal.fromXML( xml.normal);
			selected.fromXML( xml.selected);
		}
	
		public function scale( p:Number, screen:Number, unit:Point):Number {
	
			var tscale:Number = 1;
			var comp:Number = 1/screen;
			if ( comp < 4) {
	//			debug( "scale < 4 : "+comp);
				tscale = comp;
			} else {
				if ( comp > 10) {
	//				debug( "res > 10 : "+comp);
					tscale = comp * 0.4;
				} else {
	//				debug( "4 < res <= 10 : "+comp);
					tscale = comp * ( 4 / comp);
				}
			}
			
	//		debug( "scale corr: "+tscale);
	
			switch( scaleMode) {
				case SCALE_SCREEN: return p * tscale;	//( p / screen);
				case SCALE_UNIT: 
				default: return ( p / Math.max( unit.x, unit.y));
			}
		}
		
		public function clone( xml:XMLList=null):SymbolStyle {
			var temp:SymbolStyle = new SymbolStyle( xml);
			
			temp.icon = icon.clone();
			temp.data = data.clone();
			
			temp.normal = normal.clone();
//			temp.highlight = highlight.clone();
			temp.selected = selected.clone();
			
			temp.scaleMode = scaleMode;
			
			return temp;
		}
		
		private function debug( txt:String):void {
//			trace( "### DBG Style: "+txt);
		}
		private function error( txt:String):void {
			trace( "ERR "+icon.icon+": "+txt);
		}
	}
}