package events.navigation
{

    import classes.chart.Song;
    import flash.events.Event;

    public class StartGameplayEvent extends ChangePanelEvent
    {
        private var _song:Song;

        public function StartGameplayEvent(song:Song):void
        {
            _song = song;
            super(Routes.PANEL_GAMEPLAY);
        }

        public function get song():Song
        {
            return _song;
        }

        override public function clone():Event
        {
            return new StartGameplayEvent(_song);
        }
    }
}
