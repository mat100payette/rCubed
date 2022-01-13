package events
{

    import flash.events.Event;

    public class GameDataLoadedEvent extends Event
    {
        public static const EVENT_NAME:String = "GameDataLoaded";

        public function GameDataLoadedEvent():void
        {
            super(EVENT_NAME, true);
        }

        override public function clone():Event
        {
            return new GameDataLoadedEvent();
        }
    }
}
