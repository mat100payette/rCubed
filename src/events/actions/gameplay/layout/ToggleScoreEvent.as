package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleScoreEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleScoreEvent";

        public function ToggleScoreEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleScoreEvent();
        }
    }
}
