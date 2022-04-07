package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleAvflagComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleAvflagComboColorEvent";

        public function ToggleAvflagComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleAvflagComboColorEvent();
        }
    }
}
