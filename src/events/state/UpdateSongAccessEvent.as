package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IContentStateEvent;

    public class UpdateSongAccessEvent extends StateEvent implements IContentStateEvent
    {
        public static const STATE:String = "UpdateSongAccess";

        public function UpdateSongAccessEvent():void
        {
            super(STATE);
        }

        override public function clone():Event
        {
            return new UpdateSongAccessEvent();
        }
    }
}
