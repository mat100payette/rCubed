package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IAirEvent;

    public class WebsocketStateChangedEvent extends StateEvent implements IAirEvent
    {
        public static const STATE:String = "WebsocketStateChanged";

        private var _enabled:Boolean;
        private var _failedInit:Boolean;

        public function WebsocketStateChangedEvent(enabled:Boolean, failedInit:Boolean):void
        {
            super(STATE);

            _enabled = enabled;
            _failedInit = failedInit;
        }

        public function get enabled():Boolean
        {
            return _enabled;
        }

        public function get failedInit():Boolean
        {
            return _failedInit;
        }

        override public function clone():Event
        {
            return new WebsocketStateChangedEvent(_enabled, _failedInit);
        }
    }
}
