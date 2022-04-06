package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class WebsocketStateChangedEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "WebsocketStateChangedEvent";

        private var _enabled:Boolean;
        private var _failedInit:Boolean;

        public function WebsocketStateChangedEvent(enabled:Boolean, failedInit:Boolean):void
        {
            super();

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
