package events
{

    import flash.events.Event;
    import events.state.interfaces.IAirEvent;
    import events.state.StateEvent;

    public class SendWebsocketMessageEvent extends StateEvent implements IAirEvent
    {
        public static const STATE:String = "SendWebsocketMessage";

        private var _title:String;
        private var _message:Object;

        public function SendWebsocketMessageEvent(title:String, message:Object):void
        {
            super(STATE);

            _title = title;
            _message = message;
        }

        public function get message():Object
        {
            return _message;
        }

        public function get title():String
        {
            return _title;
        }

        override public function clone():Event
        {
            return new SendWebsocketMessageEvent(_title, _message);
        }
    }
}
