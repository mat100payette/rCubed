package events.navigation
{

    import classes.chart.Song;
    import classes.User;
    import flash.events.Event;

    public class OpenEditorEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _user:User;

        public function OpenEditorEvent(song:Song, user:User):void
        {
            _song = song;
            _user = user;
            super(Routes.PANEL_GAMEPLAY);
        }

        public function get song():Song
        {
            return _song;
        }

        public function get user():User
        {
            return _user;
        }

        override public function clone():Event
        {
            return new OpenEditorEvent(_song, _user);
        }
    }
}
