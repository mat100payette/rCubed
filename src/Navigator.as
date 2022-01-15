package
{

    import flash.display.Sprite;
    import events.navigation.popups.AddPopupEvent;
    import menu.DisplayLayer;
    import popups.settings.SettingsWindow;
    import popups.PopupHelp;
    import popups.replays.ReplayHistoryWindow;
    import classes.SongInfo;
    import popups.PopupHighscores;
    import events.navigation.popups.AddPopupHighscoresEvent;
    import events.navigation.popups.AddPopupSongNotesEvent;
    import popups.PopupSongNotes;
    import popups.PopupQueueManager;
    import popups.PopupContextMenu;
    import popups.PopupFilterManager;
    import events.navigation.popups.AddPopupSkillRankUpdateEvent;
    import popups.PopupSkillRankUpdate;
    import events.navigation.popups.RemovePopupEvent;
    import menu.MainMenu;
    import game.GameplayDisplay;
    import game.GameLoading;
    import game.GameResults;
    import com.greensock.TweenLite;
    import assets.GameBackgroundColor;
    import classes.ui.VersionText;
    import events.navigation.ChangePanelEvent;
    import events.navigation.InitialLoadingEvent;
    import flash.events.IEventDispatcher;
    import flash.concurrent.Mutex;
    import flash.events.Event;
    import classes.chart.Song;
    import classes.User;
    import classes.replay.Replay;
    import classes.Room;
    import classes.UserSettings;

    public class Navigator extends Sprite implements IDisposable
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;

        private var _bg:GameBackgroundColor;
        private var _versionText:VersionText;

        private var _target:IEventDispatcher;

        private var _newLayerCallback:Function;
        private var _addPopupCallback:Function;
        private var _removePopupCallback:Function;

        private var _topLayerIndex:uint = 1;
        private var _popupMutex:Mutex = new Mutex();

        public var activePanel:DisplayLayer;

        public function Navigator(target:IEventDispatcher, bg:GameBackgroundColor, versionText:VersionText)
        {
            _target = target;
            _bg = bg;
            _versionText = versionText;

            _target.addEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent);
            _target.addEventListener(AddPopupEvent.EVENT_TYPE, onAddPopupEvent);
            _target.addEventListener(RemovePopupEvent.EVENT_TYPE, onRemovePopupEvent);
        }

        public function onChangePanelEvent(e:ChangePanelEvent):void
        {
            var panelName:String = e.panelName;
            var nextPanel:DisplayLayer;

            switch (panelName)
            {
                case Routes.PANEL_INITIAL_LOADING:
                    var userLoggedIn:Boolean = (e as InitialLoadingEvent).userLoggedIn;
                    nextPanel = new InitialLoading(userLoggedIn);
                    break;

                case Routes.PANEL_GAME_UPDATE:
                    nextPanel = new AirUpdater();
                    break;

                case Routes.PANEL_GAME_LOGIN:
                    nextPanel = new LoginMenu();
                    break;

                case Routes.PANEL_TOKENS:
                case Routes.PANEL_MULTIPLAYER:
                case Routes.PANEL_SONGSELECTION:
                case Routes.PANEL_MAIN_MENU:
                    if (activePanel is MainMenu)
                    {
                        (activePanel as MainMenu).setActiveLayer(panelName);
                        return;
                    }
                    else
                        nextPanel = new MainMenu();
                    break;

                case Routes.PANEL_GAME_MENU:
                    onRemoveAllPopupsEvent();

                    // TODO: Get from event
                    var isEditor2:Boolean = false;

                    if (isEditor2)
                    {
                        // TODO: Get from event
                        var song2:Song;
                        var user2:User;
                        var isAutoplay2:Boolean;
                        var replay2:Replay;
                        var mpRoom2:Room;

                        nextPanel = new GameplayDisplay(song2, user2, isEditor2, isAutoplay2, replay2, mpRoom2);
                    }
                    else
                    {
                        var song3:Song;

                        // TODO: What does this do
                        //_gvars.totalSongQueue = _gvars.songQueue.concat();

                        nextPanel = new GameLoading(song3);
                    }
                    break;

                case Routes.GAME_LOADING:
                    var song4:Song;

                    nextPanel = new GameLoading(song4);
                    break;

                case Routes.GAME_PLAY:
                    var isEditor5:Boolean = false;

                    var song5:Song;
                    var user5:User;
                    var isAutoplay5:Boolean;
                    var replay5:Replay;
                    var mpRoom5:Room;

                    nextPanel = new GameplayDisplay(song5, user5, isEditor5, isAutoplay5, replay5, mpRoom5);
                    break;

                case Routes.GAME_RESULTS:
                    // TODO: Get from event
                    var settings1:UserSettings;
                    var isReplay1:Boolean;
                    var isReplayValid1:Boolean;
                    var isAutoplay1:Boolean;
                    var mpRoom1:Room;

                    nextPanel = new GameResults(settings1, isReplay1, isReplayValid1, isAutoplay1, mpRoom1);
                    break;
            }

            // Show Background only if not gameplay or results
            var showBgAndVersion:Boolean = !(nextPanel is GameplayDisplay || nextPanel is GameResults);
            _bg.updateDisplay(!showBgAndVersion);
            _versionText.visible = showBgAndVersion;

            transitionPanel(nextPanel);
        }

        private function onAddPopupEvent(e:AddPopupEvent = null):void
        {
            if (!_popupMutex.tryLock())
            {
                if (e != null)
                    e.preventDefault();

                return;
            }

            try
            {
                var popupName:String = e.popupName;
                var isOverlay:Boolean = e.isOverlay;
                var popup:DisplayLayer;

                switch (popupName)
                {
                    case Routes.POPUP_OPTIONS:
                        popup = new SettingsWindow(_gvars.activeUser);
                        break;
                    case Routes.POPUP_HELP:
                        popup = new PopupHelp();
                        break;
                    case Routes.POPUP_REPLAY_HISTORY:
                        popup = new ReplayHistoryWindow();
                        break;
                    case Routes.POPUP_HIGHSCORES:
                        var scoresSongInfo:SongInfo = (e as AddPopupHighscoresEvent).songInfo;
                        popup = new PopupHighscores(scoresSongInfo);
                        break;
                    case Routes.POPUP_SONG_NOTES:
                        var notesSongInfo:SongInfo = (e as AddPopupSongNotesEvent).songInfo;
                        popup = new PopupSongNotes(notesSongInfo);
                        break;
                    case Routes.POPUP_QUEUE_MANAGER:
                        popup = new PopupQueueManager();
                        break;
                    case Routes.POPUP_CONTEXT_MENU:
                        popup = new PopupContextMenu();
                        break;
                    case Routes.POPUP_FILTER_MANAGER:
                        popup = new PopupFilterManager();
                        break;
                    case Routes.POPUP_SKILL_RANK_UPDATE:
                        var skillRankData:Object = (e as AddPopupSkillRankUpdateEvent).skillRankData;
                        popup = new PopupSkillRankUpdate(skillRankData);
                        break;
                }

                addChildAt(popup, _topLayerIndex);
                popup.stageAdd();

                _topLayerIndex++;
            }
            finally
            {
                _popupMutex.unlock();
            }
        }

        public function onRemovePopupEvent(e:RemovePopupEvent = null):void
        {
            if (!_popupMutex.tryLock())
            {
                if (e != null)
                    e.preventDefault();

                return;
            }

            try
            {
                if (_topLayerIndex == 1)
                    return;

                removeChildAt(_topLayerIndex - 1);
                _topLayerIndex--;
            }
            finally
            {
                _popupMutex.unlock();
            }
        }

        private function onRemoveAllPopupsEvent(e:Event = null):void
        {
            if (!_popupMutex.tryLock())
            {
                if (e != null)
                    e.preventDefault();

                return;
            }

            try
            {
                while (_topLayerIndex > 1)
                {
                    removeChildAt(_topLayerIndex - 1);
                    _topLayerIndex--;
                }
            }
            finally
            {
                _popupMutex.unlock();
            }
        }

        private function transitionPanel(nextPanel:DisplayLayer):void
        {
            //- Remove last panel if exist
            if (activePanel != null)
            {
                activePanel.alpha = 0;
                TweenLite.to(activePanel, 0.5, {alpha: 0, onComplete: disposePanel, onCompleteParams: [activePanel]});
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

        private function disposePanel(currentPanel:DisplayLayer):void
        {
            if (currentPanel)
            {
                currentPanel.dispose();
                if (contains(currentPanel))
                    removeChild(currentPanel);

                currentPanel = null;
            }
        }

        public function dispose():void
        {
            _target.removeEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent);
            _target.removeEventListener(AddPopupEvent.EVENT_TYPE, onAddPopupEvent);
            _target.removeEventListener(RemovePopupEvent.EVENT_TYPE, onRemovePopupEvent);
        }
    }
}
