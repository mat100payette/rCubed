package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleAAAComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleAAAComboColorEvent";

        public function ToggleAAAComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleAAAComboColorEvent();
        }
    }
}
