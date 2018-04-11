package de.ms_ite.maptech.mapinfo {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;

	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	public class MapInfoList extends EventDispatcher {

		public var bounds:Bounds;
		public var initialized:Boolean;
		
		protected var _path:String;
		protected var _relPath:String;
		protected var propsLoader:URLLoader;
		
		public var datum:String;
		public var _mapList:Array;
		
		public function MapInfoList( p:String=null):void {
			initialized = false;
			
			datum = '';
			
			_mapList = new Array();
			
			propsLoader = new URLLoader();
			propsLoader.addEventListener( Event.COMPLETE, xmlLoaded);

			if ( p != null) path = p;
		}
		
		public function set path( p:String):void {
			if ( p == null) return;
			
			_path = p + (( p.lastIndexOf('/') == (p.length-1) || p.lastIndexOf('.php') == (p.length-4) || p.lastIndexOf('.xml') == (p.length-4)) ? '' : '/');
			_relPath = p.substring( 0, p.lastIndexOf( "/"));
			
			debug( "path: "+_path+" / "+_relPath);
			
			propsLoader.load( new URLRequest( _path));
		}
		
		public function get path():String {
			return _path;
		}

		public function getMapInfo( name:String):MapInfo {

			var temp:MapInfo = _mapList[ name];
			debug( "get mi: "+temp);
			return temp;
		}

		public function load( p:String):void {
			path = p;
		}

		protected function xmlLoaded( event:Event):void {
		    var imageProps:XMLList = XMLList( propsLoader.data /*.toLowerCase()*/);
			for each( var item:XML in imageProps) {
				lcNodes( item);
			}
		    
		    parsePropertiesList( imageProps);
		}

		public function lcNodes( node:XML):void {
			
			node.setName( node.name().localName.toLowerCase());

			for each( var attrib:XML in node.attributes()) {
				attrib.setName( attrib.name().localName.toLowerCase());
			}
			
			for each( var item:XML in node.children()) {
				lcNodes( item);
			}
		}
				
		protected function parsePropertiesList( xml:XMLList):void {
			
			debug( "reading map list:");
			for each( var mi:XML in xml.map) {
				var path:String = mi.@path;
				
				if ( datum != '' && mi.image_properties.datum != null) {
					debug( "datum: "+mi.image_properties.datum.@value);
					if ( datum != mi.image_properties.datum.@value) continue;
				}
				var temp:MapInfo = new MapInfo();
				temp.path = _relPath+(( _relPath.indexOf( "/") == (_relPath.length-1)) ? '' : '/')+path;
				temp.name = path;
				if ( temp.parseMapProperties( mi.image_properties)) {
					_mapList[ temp.name] = temp;
					
//					debug( "  found: "+temp.toString());
				}
			}
			
			debug( "done.");
			initialized = true;
			
			dispatchEvent( new Event( Event.COMPLETE));
		}
		
		protected function debug( txt:String):void {
			trace( "DBG MIList: "+txt);
		}
	}
}