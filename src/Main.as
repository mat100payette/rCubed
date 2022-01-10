/**
 * @author Jonathan (Velocity)
 */

package
{
    CONFIG::vsync
    {
        import flash.events.VsyncStateChangeAvailabilityEvent;
    }

    import arc.mp.MultiplayerState;
    import assets.GameBackgroundColor;
    import classes.Alert;
    import classes.Language;
    import classes.NoteskinsList;
    import classes.Playlist;
    import classes.Site;
    import classes.User;
    import classes.ui.BoxButton;
    import classes.ui.EpilepsyWarning;
    import classes.ui.PreloaderStatusBar;
    import classes.ui.VersionText;
    import com.flashdynamix.utils.SWFProfiler;
    import com.flashfla.utils.ObjectUtil;
    import com.flashfla.utils.SystemUtil;
    import com.greensock.TweenLite;
    import com.greensock.TweenMax;
    import com.greensock.easing.SineInOut;
    import com.greensock.plugins.AutoAlphaPlugin;
    import com.greensock.plugins.TintPlugin;
    import com.greensock.plugins.TweenPlugin;
    import flash.desktop.NativeApplication;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.text.TextField;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import game.GameMenu;
    import menu.MainMenu;
    import menu.MenuPanel;
    import popups.PopupHelp;
    import popups.replays.ReplayHistoryWindow;
    import popups.settings.SettingsWindow;

    public class Main extends MenuPanel
    {
        public static const GAME_WIDTH:int = 780;
        public static const GAME_HEIGHT:int = 480;

        public static var WINDOW_WIDTH_EXTRA:Number = 0;
        public static var WINDOW_HEIGHT_EXTRA:Number = 0;

        private var _lang:Language = Language.instance;
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _site:Site = Site.instance;
        private var _playlist:Playlist = Playlist.instance;
        private var _noteskinList:NoteskinsList = NoteskinsList.instance;

        private var _loadTimer:int = 0;
        private var _preloader:PreloaderStatusBar;
        private var _loadScripts:uint = 0;
        private var _loadTotal:uint;
        private var _isLoginLoad:Boolean = false;
        private var _retryLoadButton:BoxButton;
        private var _epilepsyWarning:EpilepsyWarning;
        private var _popupQueue:Array = [];
        private var _lastPanel:MenuPanel;

        private var _panelMediator:PanelMediator;

        public var ignoreWindowChanges:Boolean = false;
        public var loadComplete:Boolean = false;
        public var disablePopups:Boolean = false;

        public var activePanel:MenuPanel;
        public var activePanelName:String;

        public var versionText:VersionText;
        public var bg:GameBackgroundColor

        ///- Constructor
        public function Main():void
        {
            super();

            _panelMediator = new PanelMediator(changePanel, addPopup, this);

            //- Set GlobalVariables Stage
            _gvars.gameMain = this;

            // Sometimes AIR doesn't load the stage right away.
            if (stage)
                gameInit();
            else
                addEventListener(Event.ADDED_TO_STAGE, function _init(e:Event):void
                {
                    removeEventListener(Event.ADDED_TO_STAGE, _init);
                    gameInit();
                });
        }

        private function gameInit():void
        {
            //- Static Class Init
            Logger.init();
            AirContext.initFolders();
            LocalOptions.init();
            Alert.init(stage);

            //- Setup Tween Override mode
            TweenPlugin.activate([TintPlugin, AutoAlphaPlugin]);
            TweenLite.defaultOverwrite = "all";
            stage.stageFocusRect = false;

            //- Load Air Items
            _gvars.loadAirOptions();

            //- Window Options
            stage.nativeWindow.addEventListener(Event.CLOSING, e_onNativeWindowClosing);
            NativeApplication.nativeApplication.addEventListener(Event.EXITING, e_onNativeShutdown);
            stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, e_onNativeWindowPropertyChange, false, 1);
            stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, e_onNativeWindowPropertyChange, false, 1);

            CONFIG::vsync
            {
                stage.addEventListener(VsyncStateChangeAvailabilityEvent.VSYNC_STATE_CHANGE_AVAILABILITY, e_onVsyncStateChangeAvailability);
            }

            stage.nativeWindow.title = Constant.AIR_WINDOW_TITLE;

            WINDOW_WIDTH_EXTRA = stage.nativeWindow.width - GAME_WIDTH;
            WINDOW_HEIGHT_EXTRA = stage.nativeWindow.height - GAME_HEIGHT;

            ignoreWindowChanges = true;
            if (_gvars.air_saveWindowPosition)
            {
                stage.nativeWindow.x = _gvars.airWindowProperties.x;
                stage.nativeWindow.y = _gvars.airWindowProperties.y;
            }
            if (_gvars.air_saveWindowSize)
            {
                stage.nativeWindow.width = Math.max(100, _gvars.airWindowProperties.width + WINDOW_WIDTH_EXTRA);
                stage.nativeWindow.height = Math.max(100, _gvars.airWindowProperties.height + WINDOW_HEIGHT_EXTRA);
            }
            ignoreWindowChanges = false;

            //- Load Menu Music
            _gvars.loadMenuMusic();

            //- Background
            stage.color = 0x000000;
            bg = new GameBackgroundColor();
            addChild(bg);

            //- Epilepsy Warning
            _epilepsyWarning = new EpilepsyWarning(10, stage.stageHeight * 0.15, GAME_WIDTH - 20);
            addChild(_epilepsyWarning);

            TweenMax.to(_epilepsyWarning, 1, {alpha: 0.6, ease: SineInOut, yoyo: true, repeat: -1});

            //- Add Debug Tracking
            versionText = new VersionText(stage.width - 5, 2);
            addChild(versionText);

            //- Build global right-click context menu
            buildContextMenu();

            //- Build Preloader
            buildPreloader();

            //- Load Game Data
            loadGameData();

            //- Key listener
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, false, 0, true);
            stage.focus = stage;

            //- Notify if running dev build
            CONFIG::debug
            {
                Alert.add("Development Build - " + CONFIG::timeStamp + " - NOT FOR RELEASE", 120, Alert.RED);
            }
        }

        public function buildContextMenu():void
        {
            //- Backup Menu incase
            var cm:ContextMenu = new ContextMenu();

            //- Toggle Fullscreen
            var fscmi:ContextMenuItem = new ContextMenuItem(_lang.stringSimple("show_menu"));
            fscmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleContextPopup);
            cm.customItems.push(fscmi);

            //- Assign Menu Context
            contextMenu = cm;

            //- Profiler
            SWFProfiler.init(stage, this);

            CONFIG::release
            {
                cm.hideBuiltInItems();
            }
        }

        ///- Window Methods
        private function e_onNativeShutdown(e:Event):void
        {
            _panelMediator.dispose();

            Logger.destroy();
            LocalOptions.flush();
            _gvars.onNativeProcessClose(e);
        }

        private function e_onNativeWindowClosing(e:Event):void
        {
            _gvars.airWindowProperties.width = stage.nativeWindow.width - Main.WINDOW_WIDTH_EXTRA;
            _gvars.airWindowProperties.height = stage.nativeWindow.height - Main.WINDOW_HEIGHT_EXTRA;
            _gvars.airWindowProperties.x = stage.nativeWindow.x;
            _gvars.airWindowProperties.y = stage.nativeWindow.y;

            LocalOptions.setVariable("window_properties", _gvars.airWindowProperties);
        }

        private function e_onNativeWindowPropertyChange(e:NativeWindowBoundsEvent):void
        {
            if (ignoreWindowChanges)
                return;

            _gvars.airWindowProperties.width = e.afterBounds.width - Main.WINDOW_WIDTH_EXTRA;
            _gvars.airWindowProperties.height = e.afterBounds.height - Main.WINDOW_HEIGHT_EXTRA;
            _gvars.airWindowProperties.x = e.afterBounds.x;
            _gvars.airWindowProperties.y = e.afterBounds.y;
        }

        CONFIG::vsync
        public function e_onVsyncStateChangeAvailability(event:VsyncStateChangeAvailabilityEvent):void
        {
            stage.vsyncEnabled = event.available ? _gvars.air_useVSync : true;
        }


        ///- Preloader
        public function buildPreloader():void
        {
            _preloader = new PreloaderStatusBar(8, GAME_HEIGHT - 30, GAME_WIDTH - 20, _isLoginLoad ? 88 : 125);
            addChild(_preloader);
            addEventListener(Event.ENTER_FRAME, updatePreloader);
        }

        ///- Game Data
        public function loadGameData():void
        {
            _loadTotal = (!_isLoginLoad) ? 5 : 3;

            _gvars.playerUser = new User(true);
            _gvars.playerUser.loadFull(_gvars.userSession, onUserLoggedIn);
            _gvars.activeUser = _gvars.playerUser;
            _gvars.activeUser.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _gvars.activeUser.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);

            _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _site.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _playlist.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _site.load();
            _playlist.load();

            if (!_isLoginLoad)
            {
                _lang.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _lang.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _noteskinList.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _noteskinList.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _lang.load();
                _noteskinList.load();
            }

            // Update Text
            updateLoaderText();
        }

        private function onUserLoggedIn(username:String, password:String):void
        {
            MultiplayerState.instance.setUserCredentials(username, password);
        }

        private function gameScriptLoad(e:Event):void
        {
            e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _loadScripts++;

            // Update Text
            updateLoaderText();
        }

        private function gameScriptLoadError(e:Event):void
        {
            e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);

            // Update Text
            updateLoaderText();
        }

        private function updateLoaderText():void
        {
            if (_preloader.text != null)
            {
                var updatedText:String = "";

                updatedText += "Total: " + _loadScripts + " / " + _loadTotal + "\n";
                updatedText += "Playlist: " + getLoadText(_playlist.isLoaded(), _playlist.isError()) + "\n";
                updatedText += "User Data: " + getLoadText(_gvars.playerUser.isLoaded(), _gvars.playerUser.isError()) + "\n";
                updatedText += "Site Data: " + getLoadText(_site.isLoaded(), _site.isError());

                if (!_isLoginLoad)
                {
                    updatedText += "\n" + "Noteskin Data: " + getLoadText(_noteskinList.isLoaded(), _noteskinList.isError());
                    updatedText += "\n" + "Language Data: " + getLoadText(_lang.isLoaded(), _lang.isError())
                }

                _preloader.text.htmlText = updatedText;
            }
        }

        private function getLoadText(isLoaded:Boolean, isError:Boolean):String
        {
            if (isError)
                return "<font color=\"#FFC4C4\">Error</font>";
            if (isLoaded)
                return "<font color=\"#C4FFCD\">Complete</font>";

            var cycle:int = 35;
            return "Loading." + ((_loadTimer % cycle > cycle / 3) ? "." : "") + ((_loadTimer % cycle > cycle / 1.5) ? "." : "");
        }

        ///- PreloaderHandlers
        private function updatePreloader(e:Event):void
        {
            // Update Text
            updateLoaderText();

            _loadTimer++;
            _preloader.bar.update(_loadScripts / _loadTotal);
            if (_loadTimer >= 300 && !_retryLoadButton)
            {
                _retryLoadButton = new BoxButton(this, Main.GAME_WIDTH - 85, _preloader.y - 35, 75, 25, "RELOAD", 12, e_retryClick);
            }

            if (_preloader.bar.isComplete)
            {
                loadComplete = true;
                if (_retryLoadButton && contains(_retryLoadButton))
                {
                    removeChild(_retryLoadButton);
                    _retryLoadButton.dispose();
                }

                buildContextMenu();

                CONFIG::updater
                {
                    CONFIG::release
                    {
                        // Do Air Update Check
                        if (!Flags.VALUES[Flags.DID_AIR_UPDATE_CHECK])
                        {
                            Flags.VALUES[Flags.DID_AIR_UPDATE_CHECK] = true;
                            var airUpdateCheck:int = AirContext.serverVersionHigher(_site.data["game_r3air_version"]);
                            //addAlert(_site.data["game_r3air_version"] + " " + (airUpdateCheck == -1 ? "&gt;" : (airUpdateCheck == 1 ? "&lt;" : "==")) + " " + Constant.AIR_VERSION, 240);
                            if (airUpdateCheck == -1)
                            {
                                loadScripts = 0;
                                preloader.remove();
                                removeChild(loadStatus);
                                removeChild(epilepsyWarning);
                                removeEventListener(Event.ENTER_FRAME, updatePreloader);

                                // Switch to game
                                switchTo(GAME_UPDATE_PANEL);
                                return;
                            }
                            else
                            {
                                LocalStore.deleteVariable("air_update_checks");
                            }
                        }
                    }
                }

                _loadScripts = 0;
                _preloader.bar.remove();
                removeChild(_preloader);
                removeEventListener(Event.ENTER_FRAME, updatePreloader);

                _playlist.updateSongAccess();
                _playlist.updatePublicSongsCount();
                _gvars.loadUserSongData();

                // TODO: Validate this switchTo logic
                if (_gvars.activeUser.isGuest)
                    dispatchEvent(new ChangePanelEvent(PanelMediator.PANEL_GAME_LOGIN));
                else
                    dispatchEvent(new ChangePanelEvent(PanelMediator.PANEL_GAME_MENU));
            }
        }

        private function e_retryClick(e:Event):void
        {
            Alert.add(_lang.string("reload_scripts"));

            if (!_playlist.isLoaded())
            {
                _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _playlist.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _playlist.load();
            }
            if (!_site.isLoaded())
            {
                _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _site.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _site.load();
            }
            if (!_gvars.activeUser.isLoaded())
            {
                _gvars.activeUser.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _gvars.activeUser.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _gvars.activeUser.loadFull(_gvars.userSession);
            }
            if (!_isLoginLoad)
            {
                if (!_noteskinList.isLoaded())
                {
                    _noteskinList.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                    _noteskinList.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                    _noteskinList.load();
                }
                if (!_lang.isLoaded())
                {
                    _lang.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                    _lang.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                    _lang.load();
                }
            }

            // Update Text
            updateLoaderText();
        }

        ///- Panels
        private function changePanel(e:ChangePanelEvent):void
        {
            var panelName:String = e.panelName;

            var isFound:Boolean = false;
            var nextPanel:MenuPanel;

            if (panelName == PanelMediator.PANEL_MAIN)
            {
                // Make background force displayed.
                bg.updateDisplay();
                versionText.visible = true;

                //- Remove last panel if exist
                if (activePanel != null)
                    TweenLite.to(activePanel, 0.5, {alpha: 0, onComplete: removeLastPanel, onCompleteParams: [activePanel]});

                // Only load data that depend on the global session token after logging in
                _isLoginLoad = true;

                //- Build Preloader
                buildPreloader();

                //- Load Game Data
                loadGameData();

                return;
            }

            //- Add Requested Panel
            switch (panelName)
            {
                case PanelMediator.PANEL_GAME_UPDATE:
                    nextPanel = new AirUpdater();
                    break;

                case PanelMediator.PANEL_GAME_LOGIN:
                    nextPanel = new LoginMenu();
                    break;

                case PanelMediator.PANEL_GAME_MENU:
                    nextPanel = new MainMenu();

                    if (contains(_epilepsyWarning))
                        removeChild(_epilepsyWarning);
                    break;

                case PanelMediator.PANEL_GAME_PLAY:
                    nextPanel = new GameMenu();
                    break;
            }

            // Show Background if not gameplay
            if (panelName != PanelMediator.PANEL_GAME_PLAY)
            {
                bg.visible = true;
                versionText.visible = true;
            }

            //- Remove last panel if exist
            if (activePanel != null)
            {
                TweenLite.to(activePanel, 0.5, {alpha: 0, onComplete: removeLastPanel, onCompleteParams: [activePanel]});
                activePanel.mouseEnabled = false;
                activePanel.mouseChildren = false;
            }

            activePanel = nextPanel;
            activePanel.alpha = 0;

            addChildAt(activePanel, 1);
            if (!activePanel.hasInit)
            {
                activePanel.init();
                activePanel.hasInit = true;
            }

            activePanel.stageAdd();
            TweenLite.to(activePanel, 0.5, {alpha: 1});
        }

        private function removeLastPanel(removePanel:MenuPanel):void
        {
            if (removePanel)
            {
                removePanel.dispose();
                if (contains(removePanel))
                    removeChild(removePanel);

                removePanel = null;
            }
            SystemUtil.gc();
        }

        ///- Popups
        public function addPopup(e:AddPopupEvent, overlay:Boolean = false):void
        {
            var popupName:String = e.popupName;
            var popup:MenuPanel;

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
            }

            addChildAt(popup, 2);
            if (!popup.hasInit)
            {
                popup.init();
                popup.hasInit = true;
            }

            popup.stageAdd();
        }

        public function addPopupQueue(_panel:*, newLayer:Boolean = false):void
        {
            _popupQueue.push({"panel": _panel, "layer": newLayer});
        }

        private function removeChildClass(clazz:Class):void
        {
            for (var i:int = 0; i < numChildren; i++)
            {
                if (getChildAt(i) is clazz)
                {
                    removeChildAt(i);
                    break;
                }
            }
        }

        ///- Fullscreen Handling
        private function toggleContextPopup(e:Event):void
        {
            if (!disablePopups)
                dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_CONTEXT_MENU));
            //addPopup(new PopupContextMenu());
        }

        ///- Key Handling
        private function keyboardKeyDown(e:KeyboardEvent):void
        {
            var keyCode:int = e.keyCode;
            if (Flags.VALUES[Flags.ENABLE_GLOBAL_POPUPS])
            {
                // Options
                if (keyCode == _gvars.playerUser.settings.keyOptions && (stage.focus == null || !(stage.focus is TextField)))
                {
                    dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_OPTIONS));
                }

                // Help Menu
                else if (keyCode == Keyboard.F1)
                {
                    dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_HELP));
                }

                // Replay History
                else if (keyCode == Keyboard.F2)
                {
                    dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_REPLAY_HISTORY));
                }
            }
        }
    }
}
