package events.actions.gameplay.input
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetKeyRightEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetKeyRightEvent";

        private var _keyCode:uint;

        public function SetKeyRightEvent(keyCode:uint):void
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
            return new SetKeyRightEvent(_keyCode);
        }
    }
}
