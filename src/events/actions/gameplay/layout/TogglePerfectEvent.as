package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class TogglePerfectEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "TogglePerfectEvent";

        public function TogglePerfectEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new TogglePerfectEvent();
        }
    }
}
