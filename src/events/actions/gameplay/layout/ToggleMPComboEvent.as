package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleMPComboEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleMPComboEvent";

        public function ToggleMPComboEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleMPComboEvent();
        }
    }
}
