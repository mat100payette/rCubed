package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleVisualModEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleVisualModEvent";

        private var _mod:String;

        public function ToggleVisualModEvent(mod:String):void
        {
            super();

            _mod = mod;
        }

        public function get mod():String
        {
            return _mod;
        }

        override public function clone():Event
        {
            return new ToggleVisualModEvent(_mod);
        }
    }
}
