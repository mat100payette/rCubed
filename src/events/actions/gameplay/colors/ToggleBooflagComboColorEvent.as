package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleBooflagComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleBooflagComboColorEvent";

        public function ToggleBooflagComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleBooflagComboColorEvent();
        }
    }
}
