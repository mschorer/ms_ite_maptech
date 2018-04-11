package de.ms_ite.maptech.mapinfo {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.projections.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.xml.*;
	
	[Event(name=IOErrorEvent.IO_ERROR, type="flash.events.IOErrorEvent")]
	[Event(name=SecurityErrorEvent.IO_ERROR, type="flash.events.SecurityErrorEvent")]
	
	public class MapInfo extends EventDispatcher {
		
		public static var MODE_UNSET:int = 0;
		public static var MODE_MAP:int = 10;
		public static var MODE_AERIAL:int = 20;
		public static var MODE_HYBRID:int = 30;
		public static var MODE_OVERLAY:int = 40;
		public static var MODE_OVERLAY1:int = 41;
		public static var MODE_TERRAIN:int = 50;

		public static var MODE_BIRDSVIEW:int = 90;

		public static var MODE_EXT_MOON:int = 100;

		public static var MODE_EXT_MARS_VIS:int = 110;
		public static var MODE_EXT_MARS_IR:int = 112;
		public static var MODE_EXT_MARS_ELEV:int = 114;
		
		protected var mapMode:int;
		
		public var width:Number;
		public var height:Number;
		
		public var resolution:Point;
		
		public var layers:int;
		
		public var tileSize:int;

		public var tileOffsetX:int = 0;
		public var tileOffsetY:int = 0;
		
//		public var tileAspect:Number = 1;

		public var version:String;
		public var tileExt:String;
		
		public var mapWraps:Boolean;
		
		public var bounds:Bounds;
		public var initView:Bounds;
		
		public var name:String;
		public var type:String;
		
		public var alpha:Number;
		public var area:Number;
		
//		protected var tMatrix:Matrix;

		public var tilesPerLevel:Array;
		public var resolutionPerLevel:Array;
		
		public var initialized:Boolean;
		
		protected var _path:String;
		protected var propsLoader:URLLoader;
		
		protected var _projection:Projection;
		
		public var modes:Array;
		public var hasTransparency:Boolean = false;
		
		public function MapInfo( p:String=null, mode:int = 0):void {
			initialized = false;
			
			mapWraps = false;
			
			mapMode = mode;
						
			switch( mapMode) {
				case MODE_OVERLAY:
				case MODE_OVERLAY1: hasTransparency = true;
				break;
			}			
			

//			tMatrix = new Matrix( 1 / ( 2 * Math.PI), 0, 0, -1 / (2 * Math.PI), 1, 1);		

			resolution = new Point();
			tilesPerLevel = new Array();
			resolutionPerLevel = new Array();
			
			propsLoader = new URLLoader();
			propsLoader.addEventListener( Event.COMPLETE, xmlLoaded);
			propsLoader.addEventListener( IOErrorEvent.IO_ERROR, handleError);
			propsLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleError);

			path = p;
			
			alpha = 1.0;
			
			modes = new Array();
		}
		
		protected function handleError( e:ErrorEvent):void {
//			trace( "ERROR: "+e.toString());
			dispatchEvent( e);
		}
		
		public function set projection( p:Projection):void {
			_projection = p;
		}
		
		public function get projection():Projection {
			return _projection;
		}
		
		public function set path( p:String):void {
			if ( p == null) return;
			
			_path = p + (( p.lastIndexOf('/') == (p.length-1)) ? '' : '/');
		}
		
		public function get path():String {
			return _path;
		}

		public function load( p:String=null):void {
			path = p;
			if ( _path != null) propsLoader.load( new URLRequest(_path+"ImageProperties.xml"));
		}

		protected function xmlLoaded( event:Event):void {
		    var imageProps:XMLList = XMLList( propsLoader.data.toLowerCase());
			for each( var item:XML in imageProps) {
				lcNodes( item);
			}
		    
		    parseMapProperties( imageProps);
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
					
		public function parseMapProperties( xml:XMLList):Boolean {
			var rc:Boolean = false;
			
			_projection = new Projection();
//			debug( "load: "+xml);
			
			width = parseInt( xml.@width);
			height = parseInt( xml.@height);
			tileSize = parseInt( xml.@tilesize);
			version = xml.@version;
			tileExt = xml.@extension;
			
			if ( xml.alpha.@value != undefined) alpha = parseFloat( xml.alpha.@value);
			
			try {
				name = xml.name.@value;
				if ( name == '') name = _path;
			} catch( e:Error) {
			}
			try {
				type = xml.type.@value;
			} catch( e:Error) {
			}
			
			if ( tileExt.length <= 0) tileExt = 'jpg';

			debug("map loaded: " + width + "," + height + "pix ts" + tileSize + " v" + version + " / "+tileExt+".");
			if ( isNaN( width) || isNaN( height) || isNaN( tileSize)) {
				debug("cannot load props file.");
				return rc;
			}
			var georef:XMLList = xml.georef;
			var initview:XMLList = xml.initview;
			
			if ( georef.length() > 0) {
				bounds = new Bounds();
				bounds.left =  parseFloat( georef.@xmin);
				bounds.bottom = parseFloat( georef.@ymin);
				bounds.right = parseFloat( georef.@xmax);
				bounds.top = parseFloat( georef.@ymax);
			} else {
				bounds = new Bounds();
				bounds.left =  0;
				bounds.bottom = 0;
				bounds.right = width;
				bounds.top = height;				
			}
			
			area = bounds.width * bounds.height;			

			debug( "gref: "+area+"sq | "+bounds.left+","+bounds.bottom+"/"+bounds.right+","+bounds.top);

			if ( initview.attributes().length() > 0 ) {
				initView = new Bounds();
				initView.left = parseFloat( initview.@xmin);
				initView.bottom = parseFloat( initview.@ymin);
				initView.right = parseFloat( initview.@xmax);
				initView.top = parseFloat( initview.@ymax);
//				debug( "initView: "+initView.toString());
			}

			resolution.x = bounds.width / width;
			resolution.y = bounds.height / height;
			debug( "resolution: "+resolution+" u/px");
			
			debug( "loaded: "+toString());
						
			return buildMetaInfo( width, height, resolution);
		}
		
		protected function buildMetaInfo( width:Number, height:Number, resolution:Point):Boolean {
			var tw:Number;
			var th:Number;
			
			var w:Number = width;
			var h:Number = height;
			var res:Point = resolution;
			while( w > tileSize || h > tileSize) {
				tw = Math.ceil( w / tileSize);
				th = Math.ceil( h / tileSize);
				
//				debug( "size: "+w+"x"+h);
//				debug( "layer: "+tw+"x"+th	/*+" / "+res*/);
				
				tilesPerLevel.push( new Point( tw, th));
				resolutionPerLevel.push( new Point( res.x, res.y));
				
				w = Math.floor( w / 2);
				h = Math.floor( h / 2);
				res.x *= 2;
				res.y *= 2;
			}
			tw = Math.ceil( w / tileSize);
			th = Math.ceil( h / tileSize);
//			debug( "layer: "+tw+"x"+th /*+" / "+res*/);

			tilesPerLevel.push( new Point( 1, 1));
			tilesPerLevel.reverse();
			
			resolutionPerLevel.push( res);
			resolutionPerLevel.reverse();
			
			layers = tilesPerLevel.length;
					
			initialized = true;
			
			dispatchEvent( new Event( Event.COMPLETE));
			
			return true;
		}
		
		public function getTileIndices( layer:int, sx:Number, sy:Number, wx:Number, wy:Number):Rectangle {
			var dim:Point = Point( tilesPerLevel[ layer]);
//			debug( "dim: "+dim+" / "+sx+" : "+sy+" / "+wx+" x "+wy);
			
			if ( sx + wx < 0 || sx > dim.x || sy + wy < 0 || sy > dim.y) return null;
			
			var fromX:int = Math.max( -sx, 0);
			var w_x:int = Math.min( fromX + wx, dim.x);
			
			var fromY:int = Math.max( -sy, 0);
			var w_y:int = Math.min( fromY + wy, dim.y);
			
//			debug( "   : "+fromX+" , "+fromY+" / "+w_x+" x "+w_y);

			return new Rectangle( fromX, fromY, w_x, w_y);
		}
		
		public function getTileURL( tier:int, x:int, y:int):String {
			
			if ( tier >= tilesPerLevel.length) return null;
			
			var layDim:Point;
			if ( mapWraps) {
				layDim = tilesPerLevel[ tier];

//				trace( "wrpa: "+x);
				x = x % layDim.x;				
//				trace( "  "+layDim.x+" --> "+x);
				x = ( x < 0) ? (layDim.x + x) : x;
//				trace( "    --> "+x);

				if ( y < 0 || y >= layDim.y) return null;
			} else {
				if ( x < 0 || y < 0) return null;
				
				layDim = tilesPerLevel[ tier];
				if ( x >= layDim.x || y >= layDim.y) return null;
			}
			
			var tiles:int = 0;
			var dim:Point;
			for( var i:int = 0; i < tier; i++) {
				dim = Point( tilesPerLevel[ i]); 
				tiles += dim.x * dim.y;
//					debug( "level "+i+" : "+tiles);
			}
			var tileGroup:int = Math.floor(( tiles + y * layDim.x + x) / 256);
			var tilePath:String = _path + "TileGroup" + tileGroup + "/" + tier + "-" + x + "-" + y + '.'+ tileExt;
			
//			debug( "tileURL: "+tilePath);
			
			return tilePath;
		}
/*	
		public function screen2coord( x:Number, y:Number, _viewport:Rectangle, res:Number):Point {

			var temp:Point = new Point();
			
			temp.x = x * res + _viewport.left;
			temp.y = _viewport.top - y * res;

			return temp;
		}
		
		public function pixel2coord( x:Number, y:Number, res:Number):Point {
			var temp:Point = new Point();
			
			temp.x = x * res + bounds.left;
			temp.y = bounds.top - y * res;

			return temp;
		}

		public function coord2pixel( x:Number, y:Number, layer:int, res:Point):Point {
			var temp:Point = new Point();
			
			temp.x = ( x - bounds.left) / res.x;
			temp.y = ( bounds.top - y) / res.y;
			
			return temp;
		}
*/
		public function findNearestLayer( x:Number, y:Number, res:Point, offset:int=1):int {
			var dist:Number = -1;
			var bestMatchLevel:int = 0;
			//			_layer = 0;
			
			var tempRes:Point;
			var resVal:Number = res.y;	// .length;
			debug( "find best layer: "+resVal+" / "+res.y);
			
			// don't go beyond deepeest layer
			for( var j:int = 0; j < resolutionPerLevel.length; j++) {
				
				tempRes = getResolution( x, y, j);
				//				effRes = _mapInfo.resolutionPerLevel[j];
				
				//				debug( "  res("+j+"): "+res+" / "+higherRes+" / "+lowerRes);
				
				//				if ( res > _mapInfo.resolutionPerLevel[ j]) break;

				var tempResVal:Number = ( resVal - tempRes.y);

				if (  Math.abs( tempResVal) < Math.abs( dist) || dist == -1) {
					dist = tempResVal;
					bestMatchLevel = Math.min( layers-1, ( dist > 0) ? j : ( j + 0));

//					debug( "  res[ "+j+"/"+offset+" / "+dist+" ] "+resVal+" / "+tempRes.y+" : "+tempResVal+" : "+bestMatchLevel);
				} else {
					break;
				}
			}
			
			debug( "best match: "+bestMatchLevel);
						
			return bestMatchLevel;
		}
		
		public function getResolution( x:Number, y:Number, level:int):Point {
			var temp:Point = resolutionPerLevel[ level];
			return temp;
		}
		
		public function toRad( x:Number):Number {
			return ( x * Math.PI / 180);
		}
		
		override public function toString():String {
			 return "map ("+name+") " +Math.round( area) + "sq "+width + "," + height + "pix ts" + tileSize + " v" + version + " / "+tileExt+" @ "+_path;
		}

		protected function debug( txt:String, lvl:int=0):void {
//			if ( lvl >= 0) trace( "DBG mi("+name+"): "+txt);
		}
	}
}