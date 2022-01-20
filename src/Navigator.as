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
    import events.navigation.OpenEditorEvent;
    import events.navigation.SpectateGameEvent;
    import events.navigation.WatchPreviewEvent;
    import events.navigation.StartGameplayEvent;
    import events.navigation.WatchReplayEvent;
    import events.navigation.ShowGameResultsEvent;
    import game.GameScoreResult;
    import events.navigation.StartReplayEvent;
    import events.navigation.StartSpectatingEvent;

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

            _target.addEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent, false, 100);
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
                    {
                        nextPanel = new MainMenu(panelName);
                    }
                    break;

                case Routes.PANEL_GAMEPLAY:
                    onRemoveAllPopupsEvent();

                    if (e is OpenEditorEvent)
                    {
                        var openEditorEvent:OpenEditorEvent = e as OpenEditorEvent;
                        var editorMode:int = openEditorEvent.editorMode;

                        nextPanel = new GameplayDisplay(openEditorEvent.song, openEditorEvent.user, editorMode, true, false, null, null);
                    }
                    else if (e is SpectateGameEvent)
                    {
                        var spectateGameEvent:SpectateGameEvent = e as SpectateGameEvent;
                        nextPanel = new GameLoading(_gvars.getSongFile(spectateGameEvent.room.songInfo), null, GameplayDisplay.SPECTATOR, spectateGameEvent.room, true);
                    }
                    else if (e is WatchReplayEvent)
                    {
                        var watchReplayEvent:WatchReplayEvent = e as WatchReplayEvent;
                        nextPanel = new GameLoading(null, watchReplayEvent.replay, GameplayDisplay.SOLO, null, false);
                    }
                    else if (e is WatchPreviewEvent)
                    {
                        var watchPreviewEvent:WatchPreviewEvent = e as WatchPreviewEvent;
                        var previewSong:Song = _gvars.getSongFile(watchPreviewEvent.replay.songInfo, null, true);
                        nextPanel = new GameLoading(previewSong, null, GameplayDisplay.SOLO, null, true);
                    }

                    else if (e is StartReplayEvent)
                    {
                        var startReplayEvent:StartReplayEvent = e as StartReplayEvent;
                        nextPanel = new GameplayDisplay(startReplayEvent.song, startReplayEvent.replay.user, GameplayDisplay.SOLO, false, null, startReplayEvent.replay, null);
                    }
                    else if (e is StartSpectatingEvent)
                    {
                        var startSpectatingEvent:StartSpectatingEvent = e as StartSpectatingEvent;
                        nextPanel = new GameplayDisplay(null, _gvars.activeUser, GameplayDisplay.SPECTATOR, false, true, null, startSpectatingEvent.room);
                    }
                    else if (e is StartGameplayEvent)
                    {
                        var startGameplayEvent:StartGameplayEvent = e as StartGameplayEvent;
                        var startGameplaySong:Song = startGameplayEvent.song;

                        // TODO: Add queue logic here
                        _gvars.songResults = new Vector.<GameScoreResult>();

                        if (startGameplaySong.isLoaded)
                            nextPanel = new GameplayDisplay(startGameplaySong, _gvars.activeUser, startGameplayEvent.mode, false, false, null, startGameplayEvent.mpRoom);
                        else
                            nextPanel = new GameLoading(startGameplaySong, null, startGameplayEvent.mode, startGameplayEvent.mpRoom, false);
                    }
                    break;

                case Routes.PANEL_RESULTS:
                    var gameResultsEvent:ShowGameResultsEvent = e as ShowGameResultsEvent;
                    nextPanel = new GameResults(gameResultsEvent.song, _gvars.activeUser.settings, gameResultsEvent.replay, gameResultsEvent.isAutoplay, gameResultsEvent.mpRoom);
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
