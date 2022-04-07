package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetJudgeOffsetEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetJudgeOffsetEvent";

        private var _offset:Number;

        public function SetJudgeOffsetEvent(offset:Number):void
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
            return new SetJudgeOffsetEvent(_offset);
        }
    }
}
