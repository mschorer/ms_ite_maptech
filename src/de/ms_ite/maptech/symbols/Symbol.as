/*
 *
 * the base class for a symbol
 * started on 20050328
 *
 */

package de.ms_ite.maptech.symbols {

//	import de.msite.ZfGis;
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.projections.Projection;
	import de.ms_ite.maptech.symbols.styles.*;
	import de.ms_ite.ogc.*;
	
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
//	import mx.events.*;
	import spark.events.IndexChangeEvent;
	import mx.managers.*;

	public class Symbol extends Sprite implements ISymbol {
		
		protected var geometry:OGCGeometry;
		protected var _rowData:Object;
		protected var _resolution:Point;
		protected var _projection:Projection;
		
		protected var _mapGlue:MapGlue;				
		
		protected var _symbolStyle:SymbolStyle = null;
		
		protected var _selected:Boolean;
		protected var _highlight:Boolean;
		protected var _inView:Boolean;
		protected var _visible:Boolean;
		
		protected var tooltipField:String;
		protected var toolTip:String;
		protected var tt:IToolTip;		

		function Symbol( mg:MapGlue, st:SymbolStyle=null) {
			super();
			
			mapGlue = mg;
			tooltipField = 'title';
			
			_selected = false;
			_highlight = false;
			_inView = true;
			_visible = true;

			_symbolStyle = st;

			addEventListener( MouseEvent.MOUSE_OVER, rollOver);
			addEventListener( MouseEvent.MOUSE_OUT, rollOut);

			addEventListener( MouseEvent.CLICK, click);
			debug( "creat sym");
		}
		
		override public function set visible( b:Boolean):void {
			_visible = b;
			super.visible = _visible && _inView;
		}
		
		override public function get visible():Boolean {
			return _visible;
		}

		public function set inView( b:Boolean):void {
			_inView = b;	
			super.visible = _visible && _inView;
		}
		
		public function get inView():Boolean {
			return _inView;
		}
		
		public function set rowData( o:Object):void {
			_rowData = o;
		}
		
		public function get rowData():Object {
			return _rowData;
		}
		
		public function set mapGlue( mg:MapGlue):void {
			_mapGlue = mg;
		}
		
		public function get mapGlue():MapGlue {
			return _mapGlue;
		}
		
		public function set style( st:SymbolStyle):void {
			if ( _symbolStyle == st) return;
			
			_symbolStyle = st;
			if ( _rowData != null) update();
		}
		
		public function get style():SymbolStyle {
			return _symbolStyle;
		}
		
		public function set resolution( r:Point):void {
			_resolution = r;
		}
		
		public function get resolution():Point {
			return _resolution;
		}
		
		public function set projection( p:Projection):void {
			_projection = p;
		}
		
		public function get projection():Projection {
			return _projection;
		}
		
		public function init( row:Object):void {
			debug( "init "+this);

			_rowData = row;
			toolTip = mapGlue.getToolTip( row, tooltipField);
/*
			if ( style == null) style = new SymbolStyle();
			else style = symbolStyle;
*/
			update();
		}
		
		public function destroy():void {
			debug( "destroy");
			removeEventListener( MouseEvent.MOUSE_OVER, rollOver);
			removeEventListener( MouseEvent.MOUSE_OUT, rollOut);

			removeEventListener( MouseEvent.CLICK, click);
		}

		public function update():void {
			debug( "commit props!");
			if ( _rowData == null) return;

			geometry = new OGCGeometry();
			var loc:String = mapGlue.getPoint( _rowData);
			geometry.parse( loc);

//			toolTip = 'SHIFT and drag to move. Click (+CTRL) to select.';
		}		
		
		public function get position():Point {
			return localToGlobal( new Point(0,0));
		}
		
		public function getOrigin():Point {
			return geometry.getOrigin();
		}
		
		public function intersects( area:Bounds):Boolean {
			return area.intersects( getMBR());
		}
			
		public function getMBR():Bounds {
			var r:Bounds = geometry.getMBR();
			var o:Point = getOrigin();
			if ( o != null) {
				r.mbrAddPoint( o);
//				debug( "  update: "+r);
			}
//			debug( "  update: "+r+" / "+o);
			
			return r;
		}

		protected function click( evt:MouseEvent):void {
//			layer.toFront( this);
			error( "click! ["+evt.ctrlKey+"/"+_selected+"]");
			highlight( true);
			SymbolLayer( parent).select( this, evt.ctrlKey, true);

//			var le:ListEvent = new ListEvent( ListEvent.ITEM_CLICK);
			var le:IndexChangeEvent = new IndexChangeEvent( IndexChangeEvent.CHANGE);
			dispatchEvent( le);			
		}
		
		protected function rollOver( evt:MouseEvent):void {
			debug( "over");
			highlight( true);
			if ( tt == null && ((toolTip != null) ? (toolTip.length > 0) : false)) tt = ToolTipManager.createToolTip( toolTip, evt.stageX, evt.stageY);
		}
		
		protected function rollOut( evt:MouseEvent):void {
			debug( "out");
			highlight( false);
			if ( tt != null) {
				ToolTipManager.destroyToolTip( tt);
				tt = null;
			}
		}
		
		public function select( state:Boolean):void {
			debug( "###select: "+state);	
			_selected = state;
			highlight( state);
		}
		
		public function highlight( state:Boolean):void {	
//			debug( "highlight: "+_highlight+" > "+state);
			_highlight = state;
			if ( state) SymbolLayer( parent).toFront( this);
			update();
		}

		protected function debug( txt:String):void {
//			trace( "DBG Symbol("+this.name+"): "+txt);
		}
		protected function error( txt:String):void {
			trace( "ERR("+this.name+"): "+txt);
		}
	}
}