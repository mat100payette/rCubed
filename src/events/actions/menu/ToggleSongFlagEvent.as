package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleSongFlagEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleSongFlagEvent";

        public function ToggleSongFlagEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleSongFlagEvent();
        }
    }
}
