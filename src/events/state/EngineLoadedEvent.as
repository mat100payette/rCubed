package events.state
{

    import flash.events.Event;

    public class EngineLoadedEvent extends StateEvent
    {
        public static const STATE:String = "EngineLoaded";

        public function EngineLoadedEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new EngineLoadedEvent();
        }
    }
}
