package de.ms_ite.events
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.geom.Point;

	public class MouseSelectionEvent extends Event
	{
		public static var MOUSE_SELECT:String = 'mSelEvent';
		
		public var origin:Point;
		public var release:Point;
		
		public function MouseSelectionEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}