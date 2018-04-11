package de.ms_ite.events
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.geom.Point;

	public class DisplayDetailEvent extends Event
	{
		public static var DISPLAY_DETAIL:String = 'mDisplayDetaiEvent';
		public static var CREATE_CHART:String = 'mCreateChartEvent';
		public static var UPDATE_CHART:String = 'mUpdateChartEvent';
		
		public var sensor:Object;
		
		public function DisplayDetailEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}