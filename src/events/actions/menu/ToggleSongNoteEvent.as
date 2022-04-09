package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleSongNoteEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleSongNoteEvent";

        public function ToggleSongNoteEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleSongNoteEvent();
        }
    }
}
