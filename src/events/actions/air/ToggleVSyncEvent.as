package events.actions.air
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IAirEvent;

    public class ToggleVSyncEvent extends ActionEvent implements IAirEvent
    {
        public static const EVENT_TYPE:String = "ToggleVSyncEvent";

        public function ToggleVSyncEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleVSyncEvent();
        }
    }
}
