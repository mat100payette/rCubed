package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetBlackflagComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetBlackflagComboColorEvent";

        private var _color:int;

        public function SetBlackflagComboColorEvent(color:int):void
        {
            super();

            _color = color;
        }

        public function get color():Number
        {
            return _color;
        }

        override public function clone():Event
        {
            return new SetBlackflagComboColorEvent(_color);
        }
    }
}
