package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleGameBottomBarEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleGameBottomBarEvent";

        public function ToggleGameBottomBarEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleGameBottomBarEvent();
        }
    }
}
