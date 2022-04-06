package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class CloseWebsocketEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "CloseWebsocketEvent";

        public function CloseWebsocketEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new CloseWebsocketEvent();
        }
    }
}
