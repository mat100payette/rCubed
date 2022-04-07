package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleCustomNoteskinEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleCustomNoteskinEvent";

        public function ToggleCustomNoteskinEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleCustomNoteskinEvent();
        }
    }
}
