package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class SendWebsocketMessageEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "SendWebsocketMessageEvent";

        private var _command:String;
        private var _data:Object;

        public function SendWebsocketMessageEvent(command:String, data:Object):void
        {
            super();

            _command = command;
            _data = data;
        }

        public function get data():Object
        {
            return _data;
        }

        public function get command():String
        {
            return _command;
        }

        override public function clone():Event
        {
            return new SendWebsocketMessageEvent(_command, _data);
        }
    }
}
