package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class LoadLocalAirConfigEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "LoadLocalAirConfigEvent";

        public function LoadLocalAirConfigEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new LoadLocalAirConfigEvent();
        }
    }
}
