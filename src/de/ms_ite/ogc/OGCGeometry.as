/*
 *
 * ogc datatypes
 *
 * parse, represent and draw all instantiable ogc datatypes
 * MULTI-types represented as COLLECTION
 *
 * (c) 2006 ms@ms-ite.de
 *
 * v0.1	 																20061207
 * started 																20061128
 *
 */

package de.ms_ite.ogc {

	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.projections.Projection;
	import de.ms_ite.maptech.symbols.styles.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class OGCGeometry {
		public static var UNDEFINED:int		= 0;
		public static var POINT:int			= 1;
		public static var LINESTRING:int	= 2;
		public static var POLYGON:int		= 4;
		
		protected var collection:Array;
		protected var type:int = UNDEFINED;
		
		public var bounds:Bounds;
		
		public function OGCGeometry( wkt:String='', from:Number=0) {
			collection = new Array();
			bounds = new Bounds();
			
			parse( wkt, from);
		}
		
		public function get geomType():int {
			return type;
		}
		
		public function toString( prependType:Boolean=false):String {
			var temp:String = '';
			var clen:Number = collection.length;
			var useSubtype:Boolean = false;
			switch( type & 0x07) {
				case 0: temp = "undefined"; break;
				case 1: if ( clen > 1) temp += 'MULTI'; temp += 'POINT'; break;
				case 2: if ( clen > 1) temp += 'MULTI'; temp += 'LINESTRING'; break;
				case 4: if ( clen > 1) temp += 'MULTI'; temp += 'POLYGON'; break;
	
				case 3:
				case 5:
				case 6:
				case 7: temp = 'GEOMETRYCOLLECTION'; useSubtype = true; break;
			}
			
			for( var i:Number = 0; i < clen; i++) {
				temp += collection[i].toString( useSubtype);
			}
			
			return temp;
		}
		
		public function draw( graphics:Graphics, origin:Point, proj:Projection, res:Point, lineWidth:Number, style:GeometryStyle):void {
			if ( origin == null) return;
			
			graphics.clear();			
			var clen:Number = collection.length;
			for( var i:Number = 0; i < clen; i++) {
				debug( "draw: "+collection[i].type);
				OGCGeometry( collection[i]).drawGraphics( graphics, origin, proj, res, lineWidth, style);
			}
		}
		
		public function getOrigin():Point {
			return (collection.length > 0) ? OGCGeometry( collection[0]).getOrigin() : null;
		}
	
		public function getMBR():Bounds {
			return bounds;
		}
	
		public function drawGraphics( graphics:Graphics, origin:Point, proj:Projection, res:Point, lineWidth:Number, style:GeometryStyle):void {
		}
	
		public function drawLinestring( graphics:Graphics, origin:Point, proj:Projection, res:Point, style:GeometryStyle, points:Array):void {
			debug( "drawLinestring: "+proj+"/"+proj.aspect+" / "+origin+"/"+res+" #"+points.length+" : "+style.line.alpha);
			
			var linOrigin:Point = proj.linearizeDeg( origin);
			var linPoint:Point = proj.linearizeDeg( points[ 0]);
			
			var x:Number = ( linPoint.x - linOrigin.x) / res.x;
			var y:Number = ( linOrigin.y - linPoint.y) / res.y;
			graphics.moveTo( x, y);
			
			debug( "  p: "+origin+"/"+points[0]+" : "+linOrigin+"/"+linPoint);
			
			var pcnt:Number = points.length;
			
			if ( pcnt > 1) {
				for( var i:int=1; i < pcnt; i++) {
					linPoint = proj.linearizeDeg( points[ i]);
					
					x = ( linPoint.x - linOrigin.x) / res.x;
					y = ( linOrigin.y - linPoint.y) / res.y;
					graphics.lineTo( x, y);
	//				debug( "lineTo: "+x+","+y);
				}
			} else {
					graphics.lineTo( x+1, y);
					graphics.lineTo( x-1, y);
					graphics.lineTo( x, y+1);
					graphics.lineTo( x, y-1);
			}
		}	
		
		public function parse( wkt:String='', from:int=0):int {
			var rc:Number = 0;
			
			if ( wkt == null) return rc;
			
			wkt = wkt.toUpperCase();
			if ( wkt.indexOf( "GEOMETRYCOLLECTION") == 0) rc = parseCollection( wkt, from);
			else {
				if ( wkt.indexOf( "MULTI") == 0) {
					rc = parseMulti( wkt, from);
				} else rc = parseSimple( wkt, from);
			}
			
			return rc;
		}
		
		// get simple container
		// return index of last read
		public function parseSimple( wkt:String, from:int):int {
			
			debug( "parseSimple "+wkt);
			var t:OGCGeometry = null;
			var len:int = getContainerSize( wkt, from);
			var geom:String = getContainer( wkt, from);
			var wtemp:String = wkt.substring( from);
			
			if ( wtemp.indexOf( "POINT") == 0) {
				t = new OGCPoint( geom, 0);
				type |= POINT;
			}
			if ( wtemp.indexOf( "LINESTRING") == 0) {
				t = new OGCLinestring( geom, 0);
				type |= LINESTRING;
			}
			if ( wtemp.indexOf( "POLYGON") == 0) {
				t = new OGCPolygon( geom, 0);
				type |= POLYGON;
			}
			
			if ( t != null) {
				var r:Bounds = t.bounds;
				bounds.mbrAddCoord( r.left, r.bottom);
				bounds.mbrAddCoord( r.right, r.top);
	
				collection.push( t);
			}
			
			return (len+1);
		}
		
		// get multi container
		// return index of last read
		public function parseMulti( wkt:String, from:int):int {
			debug( "parseMulti");
	
			var t:OGCGeometry;
			
			var mtype:int = UNDEFINED;
			if ( wkt.indexOf( "POINT") == 5) {
				mtype = POINT;
				type |= POINT;
			}
			if ( wkt.indexOf( "LINESTRING") == 5) {
				mtype = LINESTRING;
				type |= LINESTRING;
			}
			if ( wkt.indexOf( "POLYGON") == 5) {
				mtype = POLYGON;
				type |= POLYGON;
			}
	
			wkt = getContainer( wkt, from);
			from = 0;
	
			var cnt:int = 0;
			while( cnt < wkt.length) {
				t = null;
				var len:int = getContainerSize( wkt, cnt);
				var geom:String = getContainer( wkt, cnt);
				
				debug( "  multi: "+mtype+" : "+geom);
				switch( mtype) {
					case POINT: 
							var pts:Array = geom.split( ",");
			
							for( var i:int=0; i < pts.length; i++) {
								t = new OGCPoint( pts[i], 0);
								if ( t != null) {
									var r:Bounds = t.bounds;
									bounds.mbrAddCoord( r.left, r.bottom);
									bounds.mbrAddCoord( r.right, r.top);
									
									collection.push( t);
								}
							}				
					break;
					case LINESTRING: t = new OGCLinestring( geom, 0);
					break;
					case POLYGON: t = new OGCPolygon( geom, 0);
					break;
					default:
				}
				
				if ( t != null) {
					var r1:Bounds = t.bounds;
					bounds.mbrAddCoord( r1.left, r1.bottom);
					bounds.mbrAddCoord( r1.right, r1.top);
	
					collection.push( t);
				}
				
				cnt = len+1;
			}
			
			return cnt;
		}
		
		// get collection
		// separate and recursively parse
		// return index of last read
		public function parseCollection( wkt:String, from:int):int {
			debug( "parseCollection");
	
			wkt = getContainer( wkt, from);
	//		debug( "  coll: "+wkt);
			
			var i:int = 0;
			var cnt:int = 0;
			while( cnt < wkt.length && i < 10) {
				var len:int = getContainerSize( wkt, cnt)+1;
				var geom:String = wkt.substring( cnt, len);
				
	//			debug( "  collection: "+geom);
				parse( geom, 0);
				
				var skip:Boolean = true;
				while( skip) {
					switch( wkt.charAt( len)) {
						case ' ':
						case ',':
							len++;
						break;
						
						default:
							skip = false;
					}
				}
				cnt = len;
				i++;
			}
			
			return cnt;
		}
	
		// (-sensitive version
		protected function getContainer( str:String, from:int):String {
	//		debug( "getContainer["+str+"]");
			var to:int = str.length;
			var idx:int = str.indexOf( "(", from);
			if ( idx >= 0) from = idx+1;
	
			var cstart:int = from;
	
			idx = str.indexOf( ")", cstart);
			if ( idx >= 0) to=idx;
	
			var nend:int = to;
			while( true) {
				var t:int = str.indexOf( "(", cstart);
											  
				if ( t < 0 || t > nend) break;
				cstart = t+1;
				
				var t2:int = str.indexOf( ')', nend+1);
	//			debug( "  extending: "+t+" / "+nend);
				if ( nend < 0) break;
				nend = t2;
			}
			
			var temp:String = str.substring( from, nend);
	//		debug( "  ==: "+temp);
	
			return temp;
		}
	
		// (-sensitive version
		protected function getContainerSize( str:String, from:int):int {
	//		debug( "getContainer["+str+"]");
			var to:int = str.length;
			var idx:int = str.indexOf( "(", from);
	
			var cstart:int = idx+1;
	
			idx = str.indexOf( ")", cstart);
			if ( idx >= 0) to=idx;
	
			var nend:int = to;
			while( true) {
				var t:int = str.indexOf( "(", cstart);
											  
				if ( t < 0 || t > nend) break;
				cstart = t+1;
				
				var t2:int = str.indexOf( ')', nend+1);
	//			debug( "  extending: "+t+" / "+nend);
				if ( nend < 0) break;
				nend = t2;
			}
			
	//		debug( "  ==: "+nend+1);
	
			return nend;
		}
	
		// read a float
		protected function parseNumber( str:String, from:int, list:Array):int {
			var to:int = str.length;
			var idx:int = str.lastIndexOf( " ", from);
			if ( idx >= 0) from = idx+1;
			idx = str.indexOf( " ", from);
			if ( idx >= 0) to=idx;
			
			var num:Number = parseFloat( str.substring( from, to));
			debug( "parse Number("+str+"/"+str.substring( from, to)+"): "+num);
			list.push( num);
			
			return to;
		}
	
		// read 2 coordinates in a point
		protected function parsePoint( str:String, from:int, p:Point):int {
//			debug( "parse point("+str+")");
			var coords:Array = new Array();
			from = parseNumber( str, from, coords);
			var to:int = parseNumber( str, from, coords);

			if ( false && ( coords[0] > 180 || coords[1] > 180)) {
				var latlon:Array = DatumConv.gk2ll( coords[0], coords[1]);
				coords[0] = latlon[1];
				coords[1] = latlon[0];
			} else {
				
			}

			p.x = coords[0];
			p.y = coords[1];
	
			bounds.mbrAddPoint( p);
			
			return to;
		}
			
		// read a point to a list
		protected function parsePointList( str:String, from:int, list:Array):int {
	//		debug( "parse point("+str+")");
			var p:Point = new Point();
			var to:int = parsePoint( str, from, p);
			
			list.push( p);
			
			return to;
		}
			
		// read a point list
		protected function parsePList( str:String, from:int, list:Array):int {
	//		debug( "parse plist("+str+")");
			
			var pts:Array = str.split( ",");
			
			for( var i:int = 0; i < pts.length; i++) {
				parsePointList( pts[i], 0, list);
			}
	
			return str.length;
		}
			
		protected function debug( txt:String):void {
//			trace( "DBG OGCGeom: "+txt);
		}
	}
}
//------------------------------------------------------------------------------