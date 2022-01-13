package events.state
{

    import flash.events.Event;

    public class GameDataLoadedEvent extends Event
    {
        public static const EVENT_TYPE:String = "GameDataLoaded";

        public function GameDataLoadedEvent():void
        {
            super(EVENT_TYPE, true);
        }

        override public function clone():Event
        {
            return new GameDataLoadedEvent();
        }
    }
}
