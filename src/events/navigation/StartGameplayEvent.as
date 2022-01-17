package events.navigation
{

    import classes.chart.Song;
    import flash.events.Event;
    import classes.Room;

    public class StartGameplayEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _isAutoplay:Boolean;
        private var _mpRoom:Room;

        public function StartGameplayEvent(song:Song, isAutoplay:Boolean, mpRoom:Room):void
        {
            _song = song;
            _isAutoplay = isAutoplay;
            _mpRoom = mpRoom;

            super(Routes.PANEL_GAMEPLAY);
        }

        public function get song():Song
        {
            return _song;
        }

        public function get isAutoplay():Boolean
        {
            return _isAutoplay;
        }

        public function get mpRoom():Room
        {
            return _mpRoom;
        }

        override public function clone():Event
        {
            return new StartGameplayEvent(_song, _isAutoplay, _mpRoom);
        }
    }
}
