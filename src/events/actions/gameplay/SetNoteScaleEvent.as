package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetNoteScaleEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetNoteScaleEvent";

        private var _scale:Number;

        public function SetNoteScaleEvent(scale:Number):void
        {
            super();

            _scale = scale;
        }

        public function get scale():Number
        {
            return _scale;
        }

        override public function clone():Event
        {
            return new SetNoteScaleEvent(_scale);
        }
    }
}
