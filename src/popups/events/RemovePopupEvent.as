package popups.events
{

    import flash.events.Event;

    public class RemovePopupEvent extends Event
    {
        static public var EVENT_TYPE:String = "remove_popup_event";

        public function RemovePopupEvent():void
        {
            super(EVENT_TYPE, true);
        }

        override public function clone():Event
        {
            return new RemovePopupEvent();
        }
    }
}
