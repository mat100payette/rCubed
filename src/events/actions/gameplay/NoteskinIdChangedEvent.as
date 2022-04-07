package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class NoteskinIdChangedEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "NoteskinIdChangedEvent";

        public function NoteskinIdChangedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new NoteskinIdChangedEvent();
        }
    }
}
