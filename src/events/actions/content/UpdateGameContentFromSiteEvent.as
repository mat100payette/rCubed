package events.actions.content
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IContentEvent;

    public class UpdateGameContentFromSiteEvent extends ActionEvent implements IContentEvent
    {
        public static const EVENT_TYPE:String = "UpdateGameContentFromSiteEvent";

        private var _siteData:Object;

        public function UpdateGameContentFromSiteEvent(siteData:Object):void
        {
            super();

            _siteData = siteData;
        }

        override public function clone():Event
        {
            return new UpdateGameContentFromSiteEvent(_siteData);
        }
    }
}
