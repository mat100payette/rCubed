package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleGameTopBarEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleGameTopBarEvent";

        public function ToggleGameTopBarEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleGameTopBarEvent();
        }
    }
}
