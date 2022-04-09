package events.actions.gameplay.layout
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class ToggleReceptorAnimationsEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "ToggleReceptorAnimationsEvent";

        public function ToggleReceptorAnimationsEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleReceptorAnimationsEvent();
        }
    }
}
