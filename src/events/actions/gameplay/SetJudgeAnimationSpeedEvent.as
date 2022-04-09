package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetJudgeAnimationSpeedEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetJudgeAnimationSpeedEvent";

        private var _speed:Number;

        public function SetJudgeAnimationSpeedEvent(speed:Number):void
        {
            super();

            _speed = speed;
        }

        public function get speed():Number
        {
            return _speed;
        }

        override public function clone():Event
        {
            return new SetJudgeAnimationSpeedEvent(_speed);
        }
    }
}
