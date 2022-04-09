package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleScreencutEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleScreencutEvent";

        public function ToggleScreencutEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleScreencutEvent();
        }
    }
}
