package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleBlackflagComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleBlackflagComboColorEvent";

        public function ToggleBlackflagComboColorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleBlackflagComboColorEvent();
        }
    }
}
