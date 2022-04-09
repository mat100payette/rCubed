package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleGenreFlagEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleGenreFlagEvent";

        public function ToggleGenreFlagEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleGenreFlagEvent();
        }
    }
}
