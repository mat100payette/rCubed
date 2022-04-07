package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleAutoJudgeOffsetEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleAutoJudgeOffsetEvent";

        public function ToggleAutoJudgeOffsetEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleAutoJudgeOffsetEvent();
        }
    }
}
