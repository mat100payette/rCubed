package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class ToggleMirrorEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "ToggleMirrorEvent";

        public function ToggleMirrorEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ToggleMirrorEvent();
        }
    }
}
