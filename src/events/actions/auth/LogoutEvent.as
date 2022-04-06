package events.actions.auth
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAuthEvent;

    public class LogoutEvent extends ActionEvent implements IAuthEvent
    {
        public static const EVENT_TYPE:String = "LogoutEvent";

        public function LogoutEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new LogoutEvent();
        }
    }
}
