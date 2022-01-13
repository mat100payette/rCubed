package events
{
    import flash.events.Event;

    public class ChangePanelEvent extends Event
    {
        private var _panelName:String;

        static public var EVENT_TYPE:String = "change_panel_event";

        public function ChangePanelEvent(panelName:String):void
        {
            _panelName = panelName;
            super(EVENT_TYPE, true);
        }

        public function get panelName():String
        {
            return _panelName;
        }

        override public function clone():Event
        {
            return new ChangePanelEvent(_panelName);
        }
    }
}
