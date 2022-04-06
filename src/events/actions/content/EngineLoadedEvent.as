package events.actions.content
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IContentEvent;

    public class EngineLoadedEvent extends ActionEvent implements IContentEvent
    {
        public static const EVENT_TYPE:String = "EngineLoadedEvent";

        public function EngineLoadedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new EngineLoadedEvent();
        }
    }
}
