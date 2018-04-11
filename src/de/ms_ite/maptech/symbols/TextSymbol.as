/*
 *
 * the base class for a symbol
 * started on 20050328
 *
 */

package de.ms_ite.maptech.symbols {

//	import de.msite.ZfGis;
	import de.ms_ite.*;
	import de.ms_ite.ogc.*;

	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	
	import mx.controls.*;
	import mx.core.*;
	import mx.effects.*;
	import mx.events.*;
	import mx.managers.*;

	public class TextSymbol extends Symbol {
		
		protected var textLabel:TextField;
		
		protected var dragMode:Boolean = false;
		protected var needRedraw:Boolean = true;

		public function TextSymbol( mg:MapGlue, st:SymbolStyle=null) {
			super( mg, st);

			textLabel = new TextField();
			
			var tf:TextFormat = new TextFormat();
			tf.font = 'embVerdana';
			textLabel.defaultTextFormat = tf;
			
			textLabel.selectable = false;
			textLabel.autoSize = 'left';
			textLabel.embedFonts = true;
//			textLabel.setStyle( 'fontFamily', 'embVerdana');
			addChild( textLabel);
			textLabel.x = 10;
			textLabel.y = 10;
//			debug( "created");
		}

		override public function update():void {
			super.update();
			if ( rowData == null) return;

			if ( _symbolStyle.data.labelField.length > 0) {
//				debug( "set text("+symbolStyle.data.labelField+") : "+rowData[ symbolStyle.data.labelField]);
				textLabel.text = rowData[ _symbolStyle.data.labelField];
			} else textLabel.text = '';
		}
	}
}