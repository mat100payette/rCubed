package events.navigation.popups
{
    import flash.events.Event;

    public class AddPopupEvent extends Event
    {
        private var _popupName:String;
        private var _overlay:Boolean;

        static public var EVENT_TYPE:String = "AddPopupEvent";

        public function AddPopupEvent(popupName:String, overlay:Boolean = true):void
        {
            _popupName = popupName;
            _overlay = overlay;
            super(EVENT_TYPE, true);
        }

        public function get popupName():String
        {
            return _popupName;
        }

        public function get isOverlay():Boolean
        {
            return _overlay;
        }

        override public function clone():Event
        {
            return new AddPopupEvent(_popupName);
        }
    }
}
