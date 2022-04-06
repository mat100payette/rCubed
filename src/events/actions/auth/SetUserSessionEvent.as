package events.actions.auth
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAuthEvent;

    public class SetUserSessionEvent extends ActionEvent implements IAuthEvent
    {
        public static const EVENT_TYPE:String = "SetUserSessionEvent";

        private var _session:String;

        public function SetUserSessionEvent(session:String):void
        {
            super();

            _session = session;
        }

        public function get session():String
        {
            return _session;
        }

        override public function clone():Event
        {
            return new SetUserSessionEvent(_session);
        }
    }
}
