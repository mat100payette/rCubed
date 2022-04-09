package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleHealthEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleHealthEvent";

        public function ToggleHealthEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleHealthEvent();
        }
    }
}
