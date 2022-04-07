package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class AutoJudgeOffsetToggledEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "AutoJudgeOffsetToggledEvent";

        public function AutoJudgeOffsetToggledEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new AutoJudgeOffsetToggledEvent();
        }
    }
}
