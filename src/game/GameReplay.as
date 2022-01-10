package game
{
    import classes.Language;
    import classes.Playlist;
    import flash.text.TextFormat;
    import menu.MenuPanel;

    public class GameReplay extends MenuPanel
    {
        private var _textFormat:TextFormat = new TextFormat(Language.UNI_FONT_NAME, 16, 0xFFFFFF, true);

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _playlist:Playlist = Playlist.instance;

        public function GameReplay()
        {
        }

        override public function init():Boolean
        {
            var replay:Object = _gvars.options.replay;
            _gvars.activeUser = replay.user;
            _gvars.options.fill();
            _gvars.options.fillFromReplay();

            dispatchEvent(new ChangePanelEvent(GameMenu.GAME_LOADING));

            return false;
        }
    }
}
