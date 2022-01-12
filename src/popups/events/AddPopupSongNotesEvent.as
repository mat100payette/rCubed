package popups.events
{

    import classes.SongInfo;

    public class AddPopupSongNotesEvent extends AddPopupEvent
    {
        private var _songInfo:SongInfo;

        public function AddPopupSongNotesEvent(songInfo:SongInfo):void
        {
            _songInfo = songInfo;
            super(PanelMediator.POPUP_SONG_NOTES);
        }

        public function get songInfo():SongInfo
        {
            return _songInfo;
        }
    }
}
