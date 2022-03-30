package events.state
{

    import events.state.interfaces.IAirStateEvent;
    import flash.events.Event;

    public class SetAirConfigEvent extends StateEvent implements IAirStateEvent
    {
        public static const STATE:String = "SetAirConfig";

        public function SetAirConfigEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new SetAirConfigEvent();
        }
    }
}
