package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetGlobalOffsetEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetGlobalOffsetEvent";

        private var _offset:Number;

        public function SetGlobalOffsetEvent(offset:Number):void
        {
            super();

            _offset = offset;
        }

        public function get offset():Number
        {
            return _offset;
        }

        override public function clone():Event
        {
            return new SetGlobalOffsetEvent(_offset);
        }
    }
}
