package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleGameModEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleGameModEvent";

        private var _mod:String;

        public function ToggleGameModEvent(mod:String):void
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
            return new ToggleGameModEvent(_mod);
        }
    }
}
