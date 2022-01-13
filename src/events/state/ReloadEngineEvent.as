package events.state
{

    import flash.events.Event;

    public class ReloadEngineEvent extends StateEvent
    {
        public static const STATE:String = "ReloadEngine";

        public function ReloadEngineEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new ReloadEngineEvent();
        }
    }
}
