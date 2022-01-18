package events.navigation
{

    import flash.events.Event;
    import classes.replay.Replay;
    import classes.chart.Song;

    public class StartReplayEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _replay:Replay;

        public function StartReplayEvent(song:Song, replay:Replay):void
        {
            _song = song;
            _replay = replay;

            super(Routes.PANEL_GAMEPLAY);
        }

        public function get song():Song
        {
            return _song;
        }

        public function get replay():Replay
        {
            return _replay;
        }

        override public function clone():Event
        {
            return new StartReplayEvent(_song, _replay);
        }
    }
}
