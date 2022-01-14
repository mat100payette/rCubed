package events.navigation.popups
{

    import classes.SongInfo;

    public class AddPopupHighscoresEvent extends AddPopupEvent
    {
        private var _songInfo:SongInfo;

        public function AddPopupHighscoresEvent(songInfo:SongInfo):void
        {
            _songInfo = songInfo;
            super(Routes.POPUP_HIGHSCORES);
        }

        public function get songInfo():SongInfo
        {
            return _songInfo;
        }
    }
}
