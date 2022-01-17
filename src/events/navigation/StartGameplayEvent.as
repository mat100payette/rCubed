package events.navigation
{

    import classes.chart.Song;
    import flash.events.Event;

    public class StartGameplayEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _isAutoplay:Boolean;

        public function StartGameplayEvent(song:Song, isAutoplay:Boolean):void
        {
            _song = song;
            _isAutoplay = isAutoplay;

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

        override public function clone():Event
        {
            return new StartGameplayEvent(_song, _isAutoplay);
        }
    }
}
