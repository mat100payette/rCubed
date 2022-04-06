package events.actions.content
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IContentEvent;

    public class ReloadEngineEvent extends ActionEvent implements IContentEvent
    {
        public static const EVENT_TYPE:String = "ReloadEngineEvent";

        public function ReloadEngineEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new ReloadEngineEvent();
        }
    }
}
