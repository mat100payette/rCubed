package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class ToggleFullScreenEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "ToggleFullScreenEvent";

        public function ToggleFullScreenEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleFullScreenEvent();
        }
    }
}
