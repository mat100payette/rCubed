package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleMissflagComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleMissflagComboColorEvent";

        public function ToggleMissflagComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleMissflagComboColorEvent();
        }
    }
}
