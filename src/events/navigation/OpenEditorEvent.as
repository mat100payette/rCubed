package events.navigation
{

    import classes.chart.Song;
    import classes.User;
    import flash.events.Event;

    public class OpenEditorEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _user:User;
        private var _editorMode:int;

        public function OpenEditorEvent(song:Song, user:User, editorMode:int):void
        {
            _song = song;
            _user = user;
            _editorMode = editorMode;
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

        public function get editorMode():int
        {
            return _editorMode;
        }

        override public function clone():Event
        {
            return new OpenEditorEvent(_song, _user, _editorMode);
        }
    }
}
