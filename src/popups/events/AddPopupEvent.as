package popups.events
{
    import flash.events.Event;

    public class AddPopupEvent extends Event
    {
        private var _popupName:String;

        static public var EVENT_TYPE:String = "add_popup_event";

        public function AddPopupEvent(popupName:String):void
        {
            _popupName = popupName;
            super(EVENT_TYPE, true);
        }

        public function get popupName():String
        {
            return _popupName;
        }

        override public function clone():Event
        {
            return new AddPopupEvent(_popupName);
        }
    }
}
