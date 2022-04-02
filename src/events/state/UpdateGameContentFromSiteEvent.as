package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IContentEvent;

    public class UpdateGameContentFromSiteEvent extends StateEvent implements IContentEvent
    {
        public static const STATE:String = "UpdateGameContentFromSite";

        private var _siteData:Object;

        public function UpdateGameContentFromSiteEvent(siteData:Object):void
        {
            super(STATE);

            _siteData = siteData;
        }

        override public function clone():Event
        {
            return new UpdateGameContentFromSiteEvent(_siteData);
        }
    }
}
