package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IAirEvent;

    public class ToggleWebsocketEvent extends StateEvent implements IAirEvent
    {
        public static const STATE:String = "ToggleWebsocket";

        public function ToggleWebsocketEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new ToggleWebsocketEvent();
        }
    }
}
