package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleFCComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleFCComboColorEvent";

        public function ToggleFCComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleFCComboColorEvent();
        }
    }
}
