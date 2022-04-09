package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleMPPAEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleMPPAEvent";

        public function ToggleMPPAEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleMPPAEvent();
        }
    }
}
