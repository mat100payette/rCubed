package events.state
{

    import flash.events.Event;

    public class LanguageChangedEvent extends Event
    {
        public static const EVENT_TYPE:String = "LanguageChanged";

        public function LanguageChangedEvent():void
        {
            super(EVENT_TYPE, true);
        }

        override public function clone():Event
        {
            return new LanguageChangedEvent();
        }
    }
}
