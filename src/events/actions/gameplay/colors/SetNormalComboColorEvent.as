package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetNormalComboColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetNormalComboColorEvent";

        private var _color:int;

        public function SetNormalComboColorEvent(color:int):void
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
            return new SetNormalComboColorEvent(_color);
        }
    }
}
