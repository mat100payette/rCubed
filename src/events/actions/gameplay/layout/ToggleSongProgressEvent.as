package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleSongProgressEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleSongProgressEvent";

        public function ToggleSongProgressEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleSongProgressEvent();
        }
    }
}
