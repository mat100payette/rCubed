package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetJudgeColorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetJudgeColorEvent";

        private var _judgeIndex:int;
        private var _color:int;

        public function SetJudgeColorEvent(judgeIndex:int, color:int):void
        {
            super();

            _judgeIndex = judgeIndex;
            _color = color;
        }

        public function get judgeIndex():int
        {
            return _judgeIndex;
        }

        public function get color():int
        {
            return _color;
        }

        override public function clone():Event
        {
            return new SetJudgeColorEvent(_judgeIndex, _color);
        }
    }
}
