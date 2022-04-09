package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleMPJudgeEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleMPJudgeEvent";

        public function ToggleMPJudgeEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleMPJudgeEvent();
        }
    }
}
