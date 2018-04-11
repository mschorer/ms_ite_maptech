package de.ms_ite.events
{
	import flash.events.Event;
	import flash.geom.Point;

	public class ClipEvent extends Event
	{
		public static var CLIP_MAXRES:String	= 'clipMaxRes';
		public static var CLIP_MINRES:String	= 'clipMinRes';
		public static var CLIP_BORDER:String	= 'clipBorder';

		public static var CLIP_BORDER_LEFT:int		= 1;
		public static var CLIP_BORDER_BOTTOM:int	= 2;
		public static var CLIP_BORDER_RIGHT:int		= 4;
		public static var CLIP_BORDER_TOP:int		= 8;
		
		public var item:Object;
		public var resolution:Point;
		public var borderFlags:int;
		 
		public function ClipEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}