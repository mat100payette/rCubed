package events.state
{

    import flash.events.Event;

    public class StateEvent extends Event
    {
        public static const EVENT_TYPE:String = "StateEvent";

        private var _stateName:String;

        public function StateEvent(stateName:String):void
        {
            _stateName = stateName;
            super(EVENT_TYPE, true);
        }

        public function get stateName():String
        {
            return _stateName;
        }
    }
}
