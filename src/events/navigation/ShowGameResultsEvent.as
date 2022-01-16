package events.navigation
{

    import classes.chart.Song;
    import flash.events.Event;
    import classes.replay.Replay;
    import classes.Room;

    public class ShowGameResultsEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _isAutoplay:Boolean;
        private var _replay:Replay;
        private var _mpRoom:Room;

        public function ShowGameResultsEvent(song:Song, isAutoplay:Boolean, replay:Replay, mpRoom:Room):void
        {
            _song = song;
            _isAutoplay = isAutoplay;
            _replay = replay;
            _mpRoom = mpRoom;
            super(Routes.PANEL_RESULTS);
        }

        public function get song():Song
        {
            return _song;
        }

        public function get isAutoplay():Boolean
        {
            return _isAutoplay;
        }

        public function get replay():Replay
        {
            return _replay;
        }

        public function get mpRoom():Room
        {
            return _mpRoom;
        }

        override public function clone():Event
        {
            return new ShowGameResultsEvent(_song, _isAutoplay, _replay, _mpRoom);
        }
    }
}
