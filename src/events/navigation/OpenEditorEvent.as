package events.navigation
{

    import classes.chart.Song;
    import flash.events.Event;

    public class OpenEditorEvent extends ChangePanelEvent
    {
        private var _song:Song;
        private var _editorMode:int;

        public function OpenEditorEvent(song:Song, editorMode:int):void
        {
            _song = song;
            _editorMode = editorMode;
            super(Routes.PANEL_GAMEPLAY);
        }

        public function get song():Song
        {
            return _song;
        }

        public function get editorMode():int
        {
            return _editorMode;
        }

        override public function clone():Event
        {
            return new OpenEditorEvent(_song, _editorMode);
        }
    }
}
