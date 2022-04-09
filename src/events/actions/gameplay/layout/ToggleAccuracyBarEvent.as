package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleAccuracyBarEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleAccuracyBarEvent";

        public function ToggleAccuracyBarEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleAccuracyBarEvent();
        }
    }
}
