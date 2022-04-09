package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class TogglePACountEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "TogglePACountEvent";

        public function TogglePACountEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new TogglePACountEvent();
        }
    }
}
