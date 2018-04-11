package de.ms_ite.maptech.adapters {
	import flash.net.URLRequest;

	public class GeoFeedAdapter {

		import com.adobe.crypto.MD5;
		import com.adobe.serialization.json.*;
		import com.adobe.utils.XMLUtil;
		import com.adobe.xml.syndication.*;
		import com.adobe.xml.syndication.atom.*;
		import com.adobe.xml.syndication.rss.*;
		
		import flash.geom.Point;
		import flash.net.*;
		
		import mx.collections.ArrayCollection;

		public var meta:XML;
//		public var title:String;
//		public var type:String;
		public var xml:XML;
		public var geoItems:ArrayCollection;
		
		public var status:String;
		
		public var refresh:int = -1;
		public var refreshFeed:int = 300;
		public var lastUpdated:Date = null;
		
		private var georss:Namespace, geo:Namespace, gml:Namespace, tmc:Namespace, dc:Namespace;

//		protected var dbc:DebugConnection;

		public function GeoFeedAdapter( inf:XML=null, ref:int=-1) {
//			dbc = new DebugConnection( this, true);

			if ( inf != null) {
				meta = inf;	
			}
			
			this.refresh = ref;
			
			geoItems = new ArrayCollection();
			
			geo = new Namespace( 'http://www.w3.org/2003/01/geo/wgs84_pos#');
			georss = new Namespace( 'http://www.georss.org/georss');
			gml = new Namespace( 'http://www.opengis.net/gml');
			dc = new Namespace( 'http://purl.org/dc/elements/1.1/');
			tmc = new Namespace( 'http://www.alrightythen.de/');
		}

		public function set uptodate( u:Boolean):void {
			if ( u) lastUpdated = new Date();
		}
		
		public function get uptodate():Boolean {
			
			if ( lastUpdated == null) return false;
			
			var now:Number = new Date().time / 1000;
			var last:Number = lastUpdated.time / 1000;
			
			var rf:int = ( refresh >= 0) ? refresh : refreshFeed;
			var rc:Boolean = ( now < ( last + rf));
			
//			debug( "is current ["+rc+"][ "+( now - last)+" / "+rf+" ]", 1);
			
			return rc;
		}
		
		public function getUrlRequest():URLRequest {
			var request:URLRequest = new URLRequest( meta.@data);
			request.method = URLRequestMethod.GET;

			return request;
		}
		
		//parses RSS 2.0 feed 
		public function parseFeed(xmlData:String):Boolean {
			
			var rc:Boolean = true;

			lastUpdated = new Date();
			
			//validate for xml
			if( ! com.adobe.utils.XMLUtil.isValidXML(xmlData)) {
				//uiAddFeed.displayError( attrib2url( selectedFeed.@data), 'Format Error: '+"Feed does not contain valid XML.");
				
				status = "Feed ["+meta.@data+"] does not contain valid XML.";
				return false;
			}
			
			status = 'ok';
			
			if ( xml == xmlData) return true;
			
			xml = new XML( xmlData);
//			debug( "### feed: "+xml.localName(), 1);
			for each( var att:XML in xml.attributes()) {
				debug( "  "+att.name()+" = "+att.valueOf().toString());
			}
			
			var feedType:String = xml.localName().toString().toLowerCase();
			switch( feedType) {
				
				case 'rdf':
				case 'rss':
					geoItems.removeAll();
					
					if ( feedType == 'rdf' || xml.@version.toString() != '2.0') { 
						debug( 'rss1 '+xml.@version);
						var rss10:RSS10 = new RSS10();
						NewsParser( rss10).parse( xmlData);
						parseRSS10( rss10, xml);
						meta.@type = 'rss10';
					} else {
						debug( 'rss2 '+xml.@version);
						var rss20:RSS20 = new RSS20();
						NewsParser( rss20).parse( xmlData);
						parseRSS20( rss20, xml);
						meta.@type = 'rss20';
					}
					break;
				
				case 'feed':
					geoItems.removeAll();
					
					var atom:IAtom;
					debug( 'atom');
					atom = new Atom10();
					NewsParser( atom).parse( xmlData);
					parseAtom10( atom, xml);
					meta.@type = 'atom10';
					break;
				
				default:
					rc = false;
			}
			
			return rc;
		}
		
		protected function setFeedTitle( title:String):void {
			meta.@label = title;
			debug( "rename channel: "+meta.@label+" to "+title);				
		}	
		
		private function parseAtom10( atom:IAtom, xml:XML):void {
			debug( "parse atom.");
			//get all of the items within the feed
			var items:Array = atom.entries;
			
			setFeedTitle( atom.feedData.title.value);
			
			var ttl:String = xml.@refresh;
			if ( ttl != null && ttl != '') {
				refreshFeed = 60 * Math.max( 1, parseFloat( ttl));
			} else {
				refreshFeed = ( 60 * 60);
			}
			
			var row:int = 0;		
			//loop through each item in the feed
			for each(var item:Entry10 in items) {
				var o:Object = new Object();
				
				o['id'] = item.id;
				o['row'] = row++;
				o['timestamp'] = ( item.updated != null) ? item.updated.getTime() : (( item.published != null) ? item.published.getTime() : '');
				o['title'] = item.title;
				o['link'] = ( item.links.length > 0) ? item.links[0].href : '';
				o['pubDate'] = ( item.updated != null) ? item.updated : item.published;
				
				var ac:String = ( item.summary != null) ? item.summary.value : '';
				ac += ( item.content != null) ? (((ac != '') ? '<p />' : '')+item.content.value) : '';
				o['description'] = ac;
				
				var cats:Array = new Array();
				for each( var cat:com.adobe.xml.syndication.atom.Category in item.categories) {
					cats.push(((cat.label != null) ? (cat.label+"/") : '')+cat.term);
				}					
				o['categories'] = cats.join( ", ");
				
				o[ 'location'] = parseGeo( item.xml[0]);
				o[ 'geometry'] = parseGeo( item.xml[0]);
				
				//				debug( "---: "+o.geometry);
				
				if ( o['location'] != null || o['geometry'] != null) geoItems.addItem( o);
			}
		}
		
		private function parseRSS10( feed:RSS10, xml:XML):void {
			//get all of the items within the feed
			var items:Array = feed.items;
			
			setFeedTitle( feed.channel.title);
			refreshFeed = 3600;
			
			var row:int = 0;		
			//loop through each item in the feed
			for each(var item:Item10 in items) {
				var o:Object = new Object();
				
				o['id'] = MD5.hash( item.xml);
				o['row'] = row++;
				//					debug( "hash: "+o['id']);
				o['title'] = item.title;
				o['link'] = item.link;
				try {
					o['pubDate'] = item.date;
					o['timestamp'] = item.date.getTime();
				} catch ( e:Error) {
					//						debug( "error.parsing rss10-date: ["+item.xml.dc::date.toString()+"]");
					o['pubDate'] = item.xml.dc::date.toString();
					o['timestamp'] = ( item.xml.dc::date == null) ? 0 : item.xml.dc::date.getTime();
				}
				o['description'] = item.description;
				
				var cats:Array = new Array();
				for each( var cat:String in item.subjects) {
					cats.push( cat);
				}					
				o['categories'] = cats.join( ", ");
				
				o[ 'location'] = parseGeo( item.xml[0]);
				o[ 'geometry'] = parseGeo( item.xml[0]);
				
				//				debug( "---: "+o.geometry);
				
				if ( o['location'] != null || o['geometry'] != null) geoItems.addItem( o);
			}
		}
		
		private function parseRSS20( feed:RSS20, xml:XML):void {
			//get all of the items within the feed
			var items:Array = feed.items;
			
			setFeedTitle( feed.channel.title);
			
			var ttl:String = xml.channel.ttl;
			if ( ttl != null && ttl != '') {
				refreshFeed = 60 * Math.max( 1, parseFloat( ttl));
			} else {
				refreshFeed = 3600;
			}
			
			var row:int = 0;		
			//loop through each item in the feed
			for each(var item:Item20 in items) {
				var o:Object = new Object();
				
				o['id'] = item.guid;
				o['row'] = row++;
				o['title'] = item.title;
				o['link'] = item.link;
				try {
					o['pubDate'] = item.pubDate;
					o['timestamp'] = item.pubDate.getTime();
				} catch ( e:Error) {
					//						debug( "error.parsing rss10-date: ["+item.xml.dc::date.toString()+"]");
					o['pubDate'] = item.xml.pubDate.toString();
					o['timestamp'] = 0;
				}
				o['description'] = item.description;
				
				var cats:Array = new Array();
				for each( var cat:com.adobe.xml.syndication.rss.Category in item.categories) {
					cats.push( cat.path.join( "/"));
				}					
				o['categories'] = cats.join( ", ");
				
				o[ 'location'] = parseGeo( item.xml[0]);
				o[ 'geometry'] = parseGeo( item.xml[0]);
				
				//					debug( "---: "+o.geometry);
				
				if ( o['location'] != null || o['geometry'] != null) geoItems.addItem( o);
			}
		}
		
		protected function parseGeo( src:XML):String {
			var geom:String, loc:String;
			var p:Point;
			var location:String;
			var lon:String, lat:String;
			var item:XML;
			var parts:Array;
			var partString:Array;
			var part:String;
			var pgml:XML;
			var pNodes:XMLList;
			
			var geocoll:Array = new Array();
			
			for each( var node:XML in src.*) {
				
				if ( node.namespace() == null) continue;
				
				var nname:String = (( node.namespace().prefix.length > 0) ? (node.namespace().prefix+':') : '')+node.localName();
				var value:String = node.valueOf().toString();
				
				if ( nname.indexOf( 'geo') != 0) continue;
				
				//					debug( "  geodata: "+nname+" / "+value);
				switch( nname) {
					
					// w3c format
					case 'geo:Point':
					case 'geo:point':
						var pt:XMLList = src.geo::point.*;
						
						lon = (pt.geo::long != undefined ) ? pt.geo::long : pt.geo::lon;
						lat = (pt.geo::lat != undefined ) ? pt.geo::lat : null;
						if ( lat != null && lon != null) {
							location = 'POINT('+lon+' '+lat+')';
							geocoll.push( location);
							//								debug( "geoP @ "+location);
						}
						break;
					
					case 'geo:long': break;
					case 'geo:lat':
						lon = (src.geo::long != undefined ) ? src.geo::long : src.geo::lon;
						lat = (src.geo::lat != undefined ) ? src.geo::lat : null;
						if ( lat != null && lon != null) {
							location = 'POINT('+lon+' '+lat+')';
							geocoll.push( location);
							//								debug( "geoS @ "+location);
						}
						break;
					
					// simple format
					case 'georss:collection':
						var coll:XMLList = src.georss::collection.*;
						for each( item in coll) {
						
						var pl:Array = parsePointList( item);
						geom = listCoords( pl);
						//								debug( "## parsed #"+pl.length+" : "+pl.join( ' . '));
						
						//					debug( "  geo:"+item.localName()+" = "+geom);
						
						switch( item.localName()) {
							case 'point': 
								p = Point( pl.shift());					 
								loc = 'POINT('+p.x+' '+p.y+')';
								geocoll.push( loc);
								if ( location == null) location = loc;
								break;
							
							case 'line': geocoll.push( 'LINESTRING('+geom+')');
								break;
							
							case 'polygon': geocoll.push( 'POLYGON('+geom+')');
								break;
							
							case 'box': geocoll.push( 'POLYGON('+geom+')');
								break;
							
							default:
						}
					}
						//							debug( "georss coll @ #"+geocoll.length);
						break;
					
					case 'georss:point':
						p = Point( parsePointList( value).shift());					 
						loc = 'POINT('+p.x+' '+p.y+')';
						geocoll.push( loc);
						if ( location == null) location = loc;
						//							debug( "georss @ point:"+loc);
						
						//							var radius:XMLList = src.georss::radius;
						//							debug( "  rad  @ "+parseFloat( radius.valueOf().toString()));
						break;
					
					case 'georss:multipoint':
						parts = value.split( ',');
						partString = new Array();
						
						var asOrig:Boolean = true;							
						for each( part in parts) { 
						partString.push( listCoords( parsePointList( part)));
						if ( asOrig) {
							p = Point( parsePointList( part).shift());					 
							loc = 'POINT('+p.x+' '+p.y+')';
							
							asOrig = false;
						}
					}
						geom = 'MULTIPOINT(('+partString.join('),(')+'))';
						geocoll.push( geom);
						
						if ( location == null) location = loc;
						debug( "georss @ multipoint:"+geom);
						
						//							var radius:XMLList = src.georss::radius;
						//							debug( "  rad  @ "+parseFloat( radius.valueOf().toString()));
						break;
					
					case 'georss:line':
						geom = listCoords( parsePointList( value));
						geocoll.push( 'LINESTRING('+geom+')');
						//							debug( "georss @ line:"+geom);
						break;
					
					case 'georss:multiline':
						parts = value.split( ',');
						partString = new Array();
						
						for each( part in parts) { 
						partString.push( listCoords( parsePointList( part)));
					}
						geom = 'MULTILINESTRING(('+partString.join('),(')+'))';
						geocoll.push( geom);
						debug( "georss @ multiline:"+geom);
						break;
					
					case 'georss:polygon':
						geom = listCoords( parsePointList( value));
						geocoll.push( 'POLYGON('+geom+')');
						//							debug( "georss @ poly:"+geom);
						break;
					
					case 'georss:multipolygon':
						parts = value.split( ',');
						partString = new Array();
						
						for each( part in parts) { 
						partString.push( listCoords( parsePointList( part)));
					}
						geom = 'MULTIPOLYGON(('+partString.join('),(')+'))';
						geocoll.push( geom);
						debug( "georss @ multipoly:"+geom);
						break;
					
					case 'georss:box':
						geom = listCoords( parsePointList( value));
						geocoll.push( 'POLYGON('+geom+')');
						//							debug( "georss @ box:"+geom);
						break;
					
					// gml format
					case 'georss:where':
						var gmlNodes:XMLList = src.georss::where.*;
						for each( item in gmlNodes) {
						debug( "  parse gml:"+item.localName());
						
						switch( item.localName()) {
							case 'Point':
								p = parsePoint( item.gml::pos);
								loc = 'POINT('+p.x+' '+p.y+')';
								geocoll.push( loc);
								debug( "  gml P :"+loc);
								if ( location == null) location = loc;
								break;
							
							case 'MultiPoint':
								var wNodes:XMLList = item.gml::pointMembers.*;
								var pts:Array = new Array();
								var first:Point = null;
								for each( pgml in wNodes) {
									p = parsePoint( pgml.gml::pos);
									if ( first == null) first = p;
									pts.push( p.x+' '+p.y);
								}
								loc = 'MULTIPOINT('+pts.join(',')+')';
								geocoll.push( loc);
								debug( "  gml MP :"+loc);
								if ( location == null) location = 'POINT('+first.x+' '+first.y+')';;
								break;
							
							case 'LineString':
								geom = 'LINESTRING('+listCoords( parsePointList( item.gml::posList))+')';
								geocoll.push( geom);
								debug( "  gml L :"+geom);
								break;
							
							case 'MultiLineString':
								pNodes = item.gml::lineMembers.*;
								var lns:Array = new Array();
								for each( pgml in pNodes) {
								lns.push( listCoords( parsePointList( pgml.gml::posList)));
							}
								geom = 'MULTILINESTRING(('+lns.join('),(')+'))';
								geocoll.push( geom);
								debug( "  gml ML :"+geom);
								break;
							
							case 'Polygon':
								var gml_poly:String;
								var ext_node:XMLList = item.gml::exterior;
								if ( ext_node.length() > 0) {
									gml_poly = ext_node[0].gml::LinearRing.gml::posList;
									debug( "  gml: using exterior ring.");
								} else {
									gml_poly =item.gml::LinearRing.gml::posList; 
									debug( "  gml: debug / skipping exterior ring.");
								}
								geom = 'POLYGON('+listCoords( parsePointList( gml_poly))+')';
								geocoll.push( geom);
								
								debug( "    gml PLY: "+geom);
								break;
							
							case 'MultiPolygon':
								
								pNodes = item.gml::polygonMembers.*;
								var pns:Array = new Array();
								for each( pgml in pNodes) {
								pns.push( listCoords( parsePointList( pgml.gml::exterior.gml::LinearRing.gml::posList)));
							}
								geom = 'MULTIPOLYGON((('+pns.join(')),((')+')))';
								geocoll.push( geom);
								
								debug( "    gml PLY: "+geom);
								break;
							
							case 'Envelope':
								var ll:Point = Point( parsePointList( item.gml::lowerCorner).shift());
								var tr:Point = Point( parsePointList( item.gml::upperCorner).shift());
								
								geocoll.push( 'POLYGON('+ll.x+' '+ll.y+','+ll.x+' '+tr.y+','+tr.x+' '+tr.y+','+tr.x+' '+ll.y+','+ll.x+' '+ll.y+')');
								debug( "    gml ENV: "+ll+" / "+tr);
								break;
							
							default:
						}
					}
						debug( "gml @ #"+geocoll.length);
						break;
				}
			}
			
			var geometry:String = '';
			
			switch( geocoll.length) {
				case 0:
					geometry = null;
					break;
				
				case 1:
					geometry = String( geocoll.shift());
					break;
				
				default:
					geometry = 'GEOMETRYCOLLECTION('+geocoll.join( ' ')+')';
			}	
			
			//				debug( "geo: "+geometry);
			
			return geometry;
		}
		
		protected function parsePoint( geo:String):Point {
			return Point( parsePointList( geo).shift());					 
		}
		
		protected function parsePointList( geo:String):Array {
			
			//				debug( "parse: "+geo);
			geo = geo.replace( /\n/g, "");
			
			var coords:Array = geo.split( ' ');				
			var res:Array = new Array();
			
			var out:String = '';
			var x:Number, y:Number;
			
			for( var i:int = 0; i < coords.length; i++) {
				y = coords[ i++];
				x = coords[ i];
				res.push( new Point( x, y));
				//					debug( "  "+i+" : "+res[ res.length-1]);
			}
			
			return res;
		}

		protected function listCoords( geo:Array):String {
			var res:String = '';
			for( var i:int = 0; i < geo.length; i++) {
				if ( i > 0) res += ',';
				res += geo[ i].x+' '+geo[i].y;
			}
			
			return res;
		}
		
		protected function debug( txt:String, lvl:int=0):void {
			if ( lvl > 0) trace( "FeedAd: "+txt);
//			if ( dbc != null) dbc.debug( txt, lvl);
		}
	}
}