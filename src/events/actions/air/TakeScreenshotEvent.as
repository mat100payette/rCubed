package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class TakeScreenshotEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "TakeScreenshotEvent";

        private var _path:String;

        public function TakeScreenshotEvent(path:String = null):void
        {
            super();

            _path = path;
        }

        public function get path():String
        {
            return _path;
        }

        override public function clone():Event
        {
            return new TakeScreenshotEvent(_path);
        }
    }
}
