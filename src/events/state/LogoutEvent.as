package events.state
{

    import flash.events.Event;

    public class LogoutEvent extends StateEvent
    {
        public static const STATE:String = "Logout";

        public function LogoutEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new LogoutEvent();
        }
    }
}
