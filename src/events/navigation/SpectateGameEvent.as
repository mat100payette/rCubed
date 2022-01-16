package events.navigation
{

    import flash.events.Event;
    import classes.Room;

    public class SpectateGameEvent extends ChangePanelEvent
    {
        private var _room:Room;

        public function SpectateGameEvent(room:Room):void
        {
            _room = room;
            super(Routes.PANEL_GAMEPLAY);
        }

        public function get room():Room
        {
            return _room;
        }

        override public function clone():Event
        {
            return new SpectateGameEvent(_room);
        }
    }
}
