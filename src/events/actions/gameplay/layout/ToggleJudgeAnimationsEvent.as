package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleJudgeAnimationsEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleJudgeAnimationsEvent";

        public function ToggleJudgeAnimationsEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleJudgeAnimationsEvent();
        }
    }
}
