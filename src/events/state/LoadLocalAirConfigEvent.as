package events.state
{

    import events.state.interfaces.IAirEvent;
    import flash.events.Event;

    public class LoadLocalAirConfigEvent extends StateEvent implements IAirEvent
    {
        public static const STATE:String = "LoadLocalAirConfig";

        public function LoadLocalAirConfigEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new LoadLocalAirConfigEvent();
        }
    }
}
