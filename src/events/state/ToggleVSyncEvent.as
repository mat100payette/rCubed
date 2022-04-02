package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IAirEvent;

    public class ToggleVSyncEvent extends StateEvent implements IAirEvent
    {
        public static const STATE:String = "ToggleVSync";

        public function ToggleVSyncEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new ToggleVSyncEvent();
        }
    }
}
