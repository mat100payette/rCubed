package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class LanguageChangedEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "LanguageChangedEvent";

        public function LanguageChangedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new LanguageChangedEvent();
        }
    }
}
