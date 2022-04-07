package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetNoteColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetNoteColorEvent";

        private var _colorIndex:int;
        private var _color:String;

        public function SetNoteColorEvent(colorIndex:int, color:String):void
        {
            super();

            _colorIndex = colorIndex;
            _color = color;
        }

        public function get colorIndex():int
        {
            return _colorIndex;
        }

        public function get color():String
        {
            return _color;
        }

        override public function clone():Event
        {
            return new SetNoteColorEvent(_colorIndex, _color);
        }
    }
}
