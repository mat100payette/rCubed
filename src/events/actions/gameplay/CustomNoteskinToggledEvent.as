package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class CustomNoteskinToggledEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "CustomNoteskinToggledEvent";

        public function CustomNoteskinToggledEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new CustomNoteskinToggledEvent();
        }
    }
}
