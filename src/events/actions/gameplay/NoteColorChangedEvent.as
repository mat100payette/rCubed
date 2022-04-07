package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class NoteColorChangedEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "NoteColorChangedEvent";

        public function NoteColorChangedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new NoteColorChangedEvent();
        }
    }
}
