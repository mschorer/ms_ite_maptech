package de.ms_ite.maptech.tools {
//	import com.adobe.serialization.json.*;
	
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.*;
	
	import de.ms_ite.maptech.projections.*;

	/**
	 * @author flashdynamix
	 */
	public class BirdsEyeParameterService extends EventDispatcher {

		private const POST_URL : String = "http://dev.virtualearth.net/services/v1/ImageryMetadataService/ImageryMetadataService.asmx/GetBirdsEyeSceneByLocation?";
		private var dl:URLLoader;
		
		public var Scene:BirdsEyeParameters;

		private static var instance : BirdsEyeParameterService;
		
		private var pending:Boolean = false;

		function BirdsEyeParameterService() {
			instance = this;
			dl = new URLLoader();
			dl.addEventListener(Event.COMPLETE, onLoaded);
		}

		public static function getInstance() : BirdsEyeParameterService {
			if(instance == null) instance = new BirdsEyeParameterService();
			return instance;
		}

		public function query(coord : Point, dir:String) : void {
			
			if ( pending) return;
			
			var uv : URLVariables = new URLVariables();
			uv.latitude = coord.y;
			uv.longitude = coord.x;
			uv.level = 20;
			uv.spinDirection = '"NoSpin"';
			uv.orientation = dir;
			uv.culture = '"en-gb"';
			uv.format = 'json';
			uv.rid = 1231510106799;
			
			// http://dev.virtualearth.net/services/v1/ImageryMetadataService/ImageryMetadataService.asmx/GetBirdsEyeSceneByLocation?latitude=48.13641721574099&longitude=11.577525883913045&level=20&spinDirection=%22NoSpin%22&orientation=%22North%22&culture=%22en-gb%22&format=json&rid=1231510106799&
			
			var ur : URLRequest = new URLRequest(POST_URL);
			ur.data = uv;
			
//			cancel();
			pending = true;
			dl.load(ur);
			
			trace( "q: "+POST_URL+uv.toString());
		}

		public function cancel() : void {
			dl.close();
		}

		private function onLoaded( e:Event) : void {
			var di:String = dl.data;
			
			pending = false;
			
			var ex:String = di.slice( di.indexOf( 'return ')+7, di.lastIndexOf( ';} if(typeof '));
			
			var o:Object = JSON.parse( ex);
			
			if ( o.StatusCode == 0) {
				Scene = null;
				trace( "no view");
			} else {
				Scene = new BirdsEyeParameters( o.Scene);
				trace( "patch ("+Scene.id+"-"+Scene.patch_id+"/"+Scene.l+")");
			}
						
			dispatchEvent( new Event( Event.COMPLETE));
//			dispatchEvent(new MapEvent(MapEvent.LOAD_COMPLETE, data));
		}
	}
}
