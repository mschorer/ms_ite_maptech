package de.ms_ite.events
{
	import flash.events.Event;

	public class RenderEvent extends Event
	{
		public static var RENDER_COMPLETE:String	= 'renderComplete';
		public static var RENDER_CHANGING:String	= 'renderChanging';
		
		public var item:Object;
		 
		public function RenderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}