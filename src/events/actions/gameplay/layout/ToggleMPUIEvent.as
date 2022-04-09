package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleMPUIEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleMPUIEvent";

        public function ToggleMPUIEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleMPUIEvent();
        }
    }
}
