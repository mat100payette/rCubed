package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleSongTimeEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleSongTimeEvent";

        public function ToggleSongTimeEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleSongTimeEvent();
        }
    }
}
