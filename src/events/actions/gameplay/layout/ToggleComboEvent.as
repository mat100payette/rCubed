package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleComboEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleComboEvent";

        public function ToggleComboEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleComboEvent();
        }
    }
}
