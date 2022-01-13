package events
{

    import flash.events.Event;

    public class LanguageChangedEvent extends Event
    {
        public static const EVENT_NAME:String = "LanguageChanged";

        public function LanguageChangedEvent():void
        {
            super(EVENT_NAME, true);
        }

        override public function clone():Event
        {
            return new LanguageChangedEvent();
        }
    }
}
