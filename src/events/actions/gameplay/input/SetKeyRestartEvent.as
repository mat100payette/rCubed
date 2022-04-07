package events.actions.gameplay.input
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetKeyRestartEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetKeyRestartEvent";

        private var _keyCode:uint;

        public function SetKeyRestartEvent(keyCode:uint):void
        {
            super();

            _keyCode = keyCode;
        }

        public function get keyCode():uint
        {
            return _keyCode;
        }

        override public function clone():Event
        {
            return new SetKeyRestartEvent(_keyCode);
        }
    }
}
