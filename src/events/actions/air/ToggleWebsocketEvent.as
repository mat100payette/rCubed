package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class ToggleWebsocketEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "ToggleWebsocketEvent";

        public function ToggleWebsocketEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleWebsocketEvent();
        }
    }
}
