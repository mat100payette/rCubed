package events.actions.gameplay.input
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetKeyOptionsEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetKeyOptionsEvent";

        private var _keyCode:uint;

        public function SetKeyOptionsEvent(keyCode:uint):void
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
            return new SetKeyOptionsEvent(_keyCode);
        }
    }
}
