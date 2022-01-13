package events.navigation.popups
{

    import flash.events.Event;

    public class RemovePopupEvent extends Event
    {
        static public var EVENT_TYPE:String = "RemovePopupEvent";

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
