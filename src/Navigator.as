package
{

    import flash.display.Sprite;
    import popups.events.AddPopupEvent;
    import menu.DisplayLayer;
    import popups.settings.SettingsWindow;
    import popups.PopupHelp;
    import popups.replays.ReplayHistoryWindow;
    import classes.SongInfo;
    import popups.PopupHighscores;
    import popups.events.AddPopupHighscoresEvent;
    import popups.events.AddPopupSongNotesEvent;
    import popups.PopupSongNotes;
    import popups.PopupQueueManager;
    import popups.PopupContextMenu;
    import popups.PopupFilterManager;
    import popups.events.AddPopupSkillRankUpdateEvent;
    import popups.PopupSkillRankUpdate;
    import popups.events.RemovePopupEvent;
    import menu.MainMenu;
    import game.GameplayDisplay;
    import game.GameLoading;
    import game.GameReplay;
    import game.GameResults;
    import com.greensock.TweenLite;
    import assets.GameBackgroundColor;
    import classes.ui.VersionText;
    import events.ChangePanelEvent;
    import events.InitialLoadingEvent;

    public class Navigator extends Sprite
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;

        private var _bg:GameBackgroundColor;
        private var _versionText:VersionText;
        private var _panelMediator:PanelMediator;

        public var activePanel:DisplayLayer;

        public function Navigator(bg:GameBackgroundColor, versionText:VersionText)
        {
            _bg = bg;
            _versionText = versionText;
            _panelMediator = new PanelMediator(this, changePanel, addPopup, removePopup);
        }

        ///- Panels
        public function changePanel(e:ChangePanelEvent):void
        {
            var panelName:String = e.panelName;
            var nextPanel:DisplayLayer;

            switch (panelName)
            {
                case PanelMediator.PANEL_INITIAL_LOADING:
                    var userLoggedIn:Boolean = (e as InitialLoadingEvent).userLoggedIn;
                    nextPanel = new InitialLoading(userLoggedIn);
                    break;

                case PanelMediator.PANEL_GAME_UPDATE:
                    nextPanel = new AirUpdater();
                    break;

                case PanelMediator.PANEL_GAME_LOGIN:
                    nextPanel = new LoginMenu();
                    break;

                case PanelMediator.PANEL_TOKENS:
                case PanelMediator.PANEL_MULTIPLAYER:
                case PanelMediator.PANEL_SONGSELECTION:
                case PanelMediator.PANEL_MAIN_MENU:
                    if (activePanel is MainMenu)
                    {
                        (activePanel as MainMenu).setActiveLayer(panelName);
                        return;
                    }
                    else
                        nextPanel = new MainMenu();
                    break;

                case PanelMediator.PANEL_GAME_MENU:
                    if (_gvars.options.isEditor)
                        nextPanel = new GameplayDisplay(_gvars.options);
                    else
                    {
                        _gvars.totalSongQueue = _gvars.songQueue.concat();
                        nextPanel = new GameLoading();
                    }
                    break;

                case PanelMediator.GAME_LOADING:
                    nextPanel = new GameLoading();
                    break;

                case PanelMediator.GAME_PLAY:
                    nextPanel = new GameplayDisplay(_gvars.options);
                    break;

                case PanelMediator.GAME_REPLAY:
                    nextPanel = new GameReplay();
                    break;

                case PanelMediator.GAME_RESULTS:
                    nextPanel = new GameResults();
                    break;
            }

            // Show Background if not gameplay
            var showBgAndVersion:Boolean = !(nextPanel is GameplayDisplay || nextPanel is GameResults);
            _bg.updateDisplay(!showBgAndVersion);
            _versionText.visible = showBgAndVersion;

            //- Remove last panel if exist
            if (activePanel != null)
            {
                activePanel.alpha = 0;
                TweenLite.to(activePanel, 0.5, {alpha: 0, onComplete: transitionPanel, onCompleteParams: [activePanel]});
                activePanel.mouseEnabled = false;
                activePanel.mouseChildren = false;

                activePanel = nextPanel;
                activePanel.alpha = 0;

                addChildAt(activePanel, 0);

                activePanel.stageAdd();
                TweenLite.to(activePanel, 0.5, {alpha: 1});
            }
            else
            {
                activePanel = nextPanel;
                activePanel.alpha = 0;

                addChildAt(activePanel, 0);

                activePanel.stageAdd();
                TweenLite.to(activePanel, 0.5, {alpha: 1});
            }
        }

        public function addPopup(e:AddPopupEvent):void
        {
            var popupName:String = e.popupName;
            var isOverlay:Boolean = e.isOverlay;
            var popup:DisplayLayer;

            switch (popupName)
            {
                case PanelMediator.POPUP_OPTIONS:
                    popup = new SettingsWindow(_gvars.activeUser);
                    break;
                case PanelMediator.POPUP_HELP:
                    popup = new PopupHelp();
                    break;
                case PanelMediator.POPUP_REPLAY_HISTORY:
                    popup = new ReplayHistoryWindow();
                    break;
                case PanelMediator.POPUP_HIGHSCORES:
                    var scoresSongInfo:SongInfo = (e as AddPopupHighscoresEvent).songInfo;
                    popup = new PopupHighscores(scoresSongInfo);
                    break;
                case PanelMediator.POPUP_SONG_NOTES:
                    var notesSongInfo:SongInfo = (e as AddPopupSongNotesEvent).songInfo;
                    popup = new PopupSongNotes(notesSongInfo);
                    break;
                case PanelMediator.POPUP_QUEUE_MANAGER:
                    popup = new PopupQueueManager();
                    break;
                case PanelMediator.POPUP_CONTEXT_MENU:
                    popup = new PopupContextMenu();
                    break;
                case PanelMediator.POPUP_FILTER_MANAGER:
                    popup = new PopupFilterManager();
                    break;
                case PanelMediator.POPUP_SKILL_RANK_UPDATE:
                    var skillRankData:Object = (e as AddPopupSkillRankUpdateEvent).skillRankData;
                    popup = new PopupSkillRankUpdate(skillRankData);
                    break;
            }

            addChildAt(popup, _panelMediator.topPopupLayer);
            popup.stageAdd();
        }

        public function removePopup(e:RemovePopupEvent):void
        {
            removeChildAt(_panelMediator.topPopupLayer - 1);
        }

        private function transitionPanel(currentPanel:DisplayLayer):void
        {
            if (currentPanel)
            {
                currentPanel.dispose();
                if (contains(currentPanel))
                    removeChild(currentPanel);

                currentPanel = null;
            }
        }
    }
}
