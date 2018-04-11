package de.ms_ite.maptech.symbols {

	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.projections.*;
	import de.ms_ite.maptech.symbols.styles.*;
	import de.ms_ite.maptech.tools.*;
	
	import flash.geom.*;
	
	public interface ISymbol {
		
		function set rowData( o:Object):void;
		function get rowData():Object;
		
		function set mapGlue( mg:MapGlue):void;
		function get mapGlue():MapGlue;
		
		function set style( st:SymbolStyle):void;
		function get style():SymbolStyle;
		
		function set resolution( r:Point):void;
		function get resolution():Point;
		
		function set projection( p:Projection):void;
		function get projection():Projection;
		
		function init( row:Object):void;		
		function destroy():void;
		function update():void;
				
		function get position():Point;
		
		function getOrigin():Point;
		function intersects( area:Bounds):Boolean;
			
		function getMBR():Bounds;
				
		function select( state:Boolean):void;		
		function highlight( state:Boolean):void;
	}
}