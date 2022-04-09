package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleTotalEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleTotalEvent";

        public function ToggleTotalEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleTotalEvent();
        }
    }
}
