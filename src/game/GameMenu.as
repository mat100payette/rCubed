package game
{
    import classes.Language;
    import classes.Playlist;
    import com.flashfla.utils.SystemUtil;
    import menu.MenuPanel;

    public class GameMenu extends MenuPanel
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _playlist:Playlist = Playlist.instance;

        public var panel:MenuPanel;

        public function GameMenu()
        {
        }

        override public function init():Boolean
        {
            if (_gvars.options.isEditor)
            {
                dispatchEvent(new ChangePanelEvent(PanelMediator.GAME_PLAY));
            }
            else
            {
                // Clone Song queue
                _gvars.totalSongQueue = _gvars.songQueue.concat();
                dispatchEvent(new ChangePanelEvent(PanelMediator.GAME_LOADING));
            }
            return false;
        }

        override public function dispose():void
        {
            if (panel)
            {
                panel.stageRemove();
                panel.dispose();
                if (this.contains(panel))
                    this.removeChild(panel);
                panel = null;
            }
            super.stageRemove();
        }
    }
}
