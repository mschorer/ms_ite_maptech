//
// an object to keep all style-information for a Icon
//

package de.ms_ite.maptech.symbols.styles {

	public class DataStyle {
		public var scaleField:String;
		public var scaleMax:Number;
		public var scaleMin:Number;
		public var scaleRowMax:Number;
		public var scaleRowMin:Number;
		public var vis_fx:String;
		public var vis_fields:String;
		public var vis_scale:Number;
		public var vis_labels:String;
		public var colorFrom:uint;
		public var colorTo:uint;
		public var labelField:String;
		
		public function DataStyle( sf:String='', smin:Number=0.8, smax:Number=2, srmin:Number=0, srmax:Number=0, vis:String='none', visf:String='', viss:Number=1, visl:String='off', cFrom:uint=0xffffffff, cTo:uint=0xffffffff, lf:String='') {
			scaleField = sf;
			scaleMax = smax;
			scaleMin = smin;
			scaleRowMax = srmax;
			scaleRowMin = srmin;
			
			vis_fx = vis;
			vis_fields = visf;
			vis_scale = viss;
			vis_labels = visl;
			
			colorFrom = cFrom;
			colorTo = cTo;
			
			labelField = lf;
		}
		
		public function clone():DataStyle {
			return new DataStyle( scaleField, scaleMin, scaleMax, scaleRowMin, scaleRowMax, vis_fx, vis_fields, vis_scale, vis_labels, colorFrom, colorTo, labelField);
		}
		
		public function fromXML( xml:XMLList):void { 
			scaleField = xml.scaleField;
			scaleMax = parseFloat( xml.scaleMax);
			scaleMin = parseFloat( xml.scaleMin);
			scaleRowMax = parseFloat( xml.scaleRowMax);
			scaleRowMin = parseFloat( xml.scaleRowMin);
			
			vis_fx = xml.vis_fx;
			vis_fields = xml.vis_fields;
			vis_scale = parseFloat( xml.vis_scale);
			vis_labels = xml.vis_labels;
			
			colorFrom = parseInt( xml.colorFrom);
			colorTo = parseInt( xml.colorTo);

			labelField = xml.labelField;
		}

		public function toXML():XML {
			var temp:XML =
				<data>
					<scaleField>{scaleField}</scaleField>
					<scaleMax>{scaleMax}</scaleMax>
					<scaleMin>{scaleMin}</scaleMin>
					<scaleRowMax>{scaleRowMax}</scaleRowMax>
					<scaleRowMin>{scaleRowMin}</scaleRowMin>
					<vis_fx>{vis_fx}</vis_fx>
					<vis_fields>{vis_fields}</vis_fields>
					<vis_scale>{vis_scale}</vis_scale>
					<vis_labels>{vis_labels}</vis_labels>
					<colorFrom>{colorFrom}</colorFrom>
					<colorTo>{colorTo}</colorTo>
					<labelField>{labelField}</labelField>
				</data>
			
			return temp;
		}
	}
}