package events.actions.gameplay.input
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetKeyDownEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetKeyDownEvent";

        private var _keyCode:uint;

        public function SetKeyDownEvent(keyCode:uint):void
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
            return new SetKeyDownEvent(_keyCode);
        }
    }
}
