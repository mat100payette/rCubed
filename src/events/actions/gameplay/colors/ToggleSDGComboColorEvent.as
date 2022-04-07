package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleSDGComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleSDGComboColorEvent";

        public function ToggleSDGComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleSDGComboColorEvent();
        }
    }
}
