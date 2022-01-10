package popups.settings
{
    import arc.ArcGlobals;
    import classes.Alert;
    import classes.Language;
    import classes.Playlist;
    import classes.UserSettings;
    import classes.chart.parse.ChartFFRLegacy;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.Prompt;
    import classes.ui.Text;
    import classes.ui.ValidatedText;
    import classes.ui.WindowOptionConfirm;
    import com.bit101.components.ComboBox;
    import com.bit101.components.Style;
    import com.flashfla.utils.sprintf;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.system.Capabilities;
    import flash.text.TextFormatAlign;
    import menu.MainMenu;

    public class SettingsTabMisc extends SettingsTabBase
    {

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _playlist:Playlist = Playlist.instance;

        private var _languagesComboItems:Array = [];
        private var _startUpScreenComboItems:Array = [];

        private var _ignoreEngineCombo:Boolean;
        private var _ignoreLanguageCombo:Boolean;

        private var _optionLanguage:ComboBox;
        private var _optionStartUpScreen:ComboBox;

        private var _optionMPTextSize:ValidatedText;
        private var _optionMPTimestamp:BoxCheck;

        private var _optionForceJudge:BoxCheck;
        private var _optionUseCache:BoxCheck;
        private var _optionAutosaveLocal:BoxCheck;
        private var _optionUseVSync:BoxCheck;
        private var _optionUseWebsockets:BoxCheck;
        private var _optionWebsocketOverlay:BoxButton;

        private var _optionEngine:ComboBox;
        private var _optionEngineDefault:ComboBox;

        private var _optionIncludeLegacy:BoxCheck;
        private var _optionFramerate:ValidatedText;

        private var _optionWindowX:ValidatedText;
        private var _optionWindowY:ValidatedText;
        private var _optionWindowWidth:ValidatedText;
        private var _optionWindowHeight:ValidatedText;
        private var _optionWindowSaveSize:BoxCheck;
        private var _optionWindowSavePosition:BoxCheck;

        private var _setWindowSizeBtn:BoxButton;
        private var _resetWindowSizeBtn:BoxButton;
        private var _setWindowPositionBtn:BoxButton;
        private var _resetWindowPositionBtn:BoxButton;

        public function SettingsTabMisc(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "misc";
        }

        override public function openTab():void
        {
            _gvars.gameMain.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onWindowPropertyChanged);
            _gvars.gameMain.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowPropertyChanged);

            var i:int;
            var xOff:int = 15;
            var yOff:int = 15;

            /// Col 1
            //- Game Languages
            _languagesComboItems = [];
            const languageLabel:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAME_LANGUAGE));
            yOff += 20;

            var selectedLanguage:String = "";
            for (var languageId:String in _lang.indexed)
            {
                var lang:String = _lang.indexed[languageId];
                var lang_name:String = _lang.string2Simple("_real_name", lang) + (_lang.data[lang]["_en_name"] != _lang.data[lang]["_real_name"] ? (" / " + _lang.string2Simple("_en_name", lang)) : "");

                _languagesComboItems.push({"label": lang_name, "data": lang});

                if (lang == _settings.language)
                    selectedLanguage = lang_name;
            }

            _optionLanguage = new ComboBox(container, xOff, yOff, selectedLanguage, _languagesComboItems);
            _optionLanguage.x = xOff;
            _optionLanguage.y = yOff;
            _optionLanguage.width = 200;
            _optionLanguage.openPosition = ComboBox.BOTTOM;
            _optionLanguage.fontSize = 11;
            _optionLanguage.addEventListener(Event.SELECT, onLanguageSelected);
            setLanguage();
            yOff += 30;

            // Start Up Screen
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_STARTUP_SCREEN));
            yOff += 20;

            _startUpScreenComboItems = [];
            for (i = 0; i <= 2; i++)
                _startUpScreenComboItems.push({"label": _lang.stringSimple(Lang.OPTIONS_STARTUP_SCREEN_PREFIX + i), "data": i});

            _optionStartUpScreen = new ComboBox(container, xOff, yOff, "Selection...", _startUpScreenComboItems);
            _optionStartUpScreen.x = xOff;
            _optionStartUpScreen.y = yOff;
            _optionStartUpScreen.width = 200;
            _optionStartUpScreen.openPosition = ComboBox.BOTTOM;
            _optionStartUpScreen.fontSize = 11;
            _optionStartUpScreen.addEventListener(Event.SELECT, onStartUpScreenSelected);
            yOff += 30;

            yOff += drawSeperator(container, xOff, 250, yOff, 0, 0);

            // Multiplayer - Text Size
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_MP_TEXT_SIZE));
            yOff += 20;

            _optionMPTextSize = new ValidatedText(container, xOff + 3, yOff + 3, 120, 20, ValidatedText.R_INT_P, onMPTextSizeChanged);
            yOff += 30;

            // Multiplayer - Timestamps
            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_MP_TIMESTAMP));
            _optionMPTimestamp = new BoxCheck(container, xOff + 3, yOff + 3, onMPTimestampClicked);
            yOff += 30;

            yOff += drawSeperator(container, xOff, 250, yOff, 0, 0);

            // Force engine Judge Mode
            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_FORCE_JUDGE_MODE));
            _optionForceJudge = new BoxCheck(container, xOff + 3, yOff + 3, onForceJudgeClicked);
            yOff += 30;

            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_AUTO_SAVE_LOCAL_REPLAYS));
            _optionAutosaveLocal = new BoxCheck(container, xOff + 3, yOff + 3, onAutosaveLocalClicked);
            yOff += 30;

            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_USE_CACHE));
            _optionUseCache = new BoxCheck(container, xOff + 3, yOff + 3, onUseCacheClicked);
            yOff += 30;

            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_USE_WEBSOCKETS));
            _optionUseWebsockets = new BoxCheck(container, xOff + 3, yOff + 3, onUseWebsocketsClicked);
            _optionUseWebsockets.addEventListener(MouseEvent.MOUSE_OVER, onUseWebsocketMouseOver, false, 0, true);
            yOff += 30;

            // https://github.com/flashflashrevolution/web-stream-overlay
            _optionWebsocketOverlay = new BoxButton(container, xOff, yOff, 200, 27, _lang.string(Lang.OPTIONS_WEBSOCKET_OVERLAY), 12, onWebsocketOverlayClicked);
            yOff += 30;

            /// Col 2
            xOff = 330;
            yOff = 15;

            // Game Engine
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAME_ENGINE));
            yOff += 20;

            _optionEngine = new ComboBox();
            _optionEngine.x = xOff;
            _optionEngine.y = yOff;
            _optionEngine.width = 200;
            _optionEngine.openPosition = ComboBox.BOTTOM;
            _optionEngine.fontSize = 11;
            _optionEngine.addEventListener(Event.SELECT, onEngineSelected);
            container.addChild(_optionEngine);
            yOff += 30;

            // Default Game Engine
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_DEFAULT_GAME_ENGINE));
            yOff += 20;

            _optionEngineDefault = new ComboBox();
            _optionEngineDefault.x = xOff;
            _optionEngineDefault.y = yOff;
            _optionEngineDefault.width = 200;
            _optionEngineDefault.openPosition = ComboBox.BOTTOM;
            _optionEngineDefault.fontSize = 11;
            _optionEngineDefault.addEventListener(Event.SELECT, onEngineDefaultSelected);
            container.addChild(_optionEngineDefault);
            engineRefresh();
            yOff += 30;

            // Legacy Song Display
            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_INCLUDE_LEGACY_SONGS));
            _optionIncludeLegacy = new BoxCheck(container, xOff + 3, yOff + 3, onDisplayLegacyClicked);
            _optionIncludeLegacy.addEventListener(MouseEvent.MOUSE_OVER, onLegacyEngineMouseOver, false, 0, true);
            yOff += 30;

            yOff += drawSeperator(container, xOff, 250, yOff, 0, 0);

            // Engine Framerate
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_FRAMERATE));
            yOff += 20;

            _optionFramerate = new ValidatedText(container, xOff + 3, yOff + 3, 120, 20, ValidatedText.R_INT_P, onFramerateChanged);
            CONFIG::vsync
            {
                new Text(container, xOff + 163, yOff + 4, _lang.string(Lang.OPTIONS_USE_VSYNC));
                _optionUseVSync = new BoxCheck(container, xOff + 143, yOff + 7, onVSyncClicked);
            }
            yOff += 30;

            yOff += drawSeperator(container, xOff, 250, yOff, 0, 0);

            // Window Size
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_WINDOW_SIZE));
            yOff += 20;

            _optionWindowWidth = new ValidatedText(container, xOff + 3, yOff + 3, 60, 20, ValidatedText.R_INT);
            new Text(container, xOff + 73, yOff + 3, "X");
            _optionWindowHeight = new ValidatedText(container, xOff + 93, yOff + 3, 60, 20, ValidatedText.R_INT);
            _setWindowSizeBtn = new BoxButton(container, xOff + 163, yOff + 3, 51, 21, "Set", 12, onWindowSetSizeClicked);
            _resetWindowSizeBtn = new BoxButton(container, xOff + 223, yOff + 3, 21, 21, "R", 12, onWindowResetSizeClicked);
            yOff += 30;

            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_SAVE_WINDOW_SIZE));
            _optionWindowSaveSize = new BoxCheck(container, xOff + 3, yOff + 3, onWindowRememberSizeClicked);
            yOff += 30;

            // Window Position
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_WINDOW_POSITION));
            yOff += 20;

            _optionWindowX = new ValidatedText(container, xOff + 3, yOff + 3, 60, 20, ValidatedText.R_INT);
            new Text(container, xOff + 73, yOff + 3, "X");
            _optionWindowY = new ValidatedText(container, xOff + 93, yOff + 3, 60, 20, ValidatedText.R_INT);
            _setWindowPositionBtn = new BoxButton(container, xOff + 163, yOff + 3, 51, 21, "Set", 12, onWindowSetPositionClicked);
            _resetWindowPositionBtn = new BoxButton(container, xOff + 223, yOff + 3, 21, 21, "R", 12, onWindowResetPositionClicked);
            yOff += 30;

            new Text(container, xOff + 23, yOff, _lang.string(Lang.OPTIONS_SAVE_WINDOW_POSITION));
            _optionWindowSavePosition = new BoxCheck(container, xOff + 3, yOff + 3, onWindowRememberPositionClicked);
            yOff += 30;

            setTextMaxWidth(245);
        }

        override public function closeTab():void
        {
            _gvars.gameMain.stage.nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVE, onWindowPropertyChanged);
            _gvars.gameMain.stage.nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, onWindowPropertyChanged);
        }

        override public function setValues():void
        {
            // Set Framerate
            _optionFramerate.text = _settings.frameRate.toString();

            _optionForceJudge.checked = _settings.forceNewJudge;

            _optionMPTimestamp.checked = _settings.displayMPTimestamp;
            _optionIncludeLegacy.checked = _settings.displayLegacySongs;
            _optionMPTextSize.text = _avars.configMPSize.toString();
            _optionStartUpScreen.selectedIndex = _settings.startUpScreen;

            setLanguage();

            _optionAutosaveLocal.checked = _gvars.air_autoSaveLocalReplays;
            _optionUseCache.checked = _gvars.air_useLocalFileCache;
            _optionUseWebsockets.checked = _gvars.air_useWebsockets;

            CONFIG::vsync
            {
                _optionUseVSync.checked = _gvars.air_useVSync;
            }

            _optionWindowWidth.text = _gvars.airWindowProperties.width.toString();
            _optionWindowHeight.text = _gvars.airWindowProperties.height.toString();
            _optionWindowX.text = _gvars.airWindowProperties.x.toString();
            _optionWindowY.text = _gvars.airWindowProperties.y.toString();

            _optionWindowSavePosition.checked = _gvars.air_saveWindowPosition;
            _optionWindowSaveSize.checked = _gvars.air_saveWindowSize;
        }

        private function onForceJudgeClicked(e:Event):void
        {
            _settings.forceNewJudge = !_settings.forceNewJudge;
        }

        private function onMPTimestampClicked(e:Event):void
        {
            _settings.displayMPTimestamp = !_settings.displayMPTimestamp;
        }

        private function onDisplayLegacyClicked(e:Event):void
        {
            _settings.displayLegacySongs = !_settings.displayLegacySongs;
        }

        private function onAutosaveLocalClicked(e:Event):void
        {
            _gvars.air_autoSaveLocalReplays = !_gvars.air_autoSaveLocalReplays;
            LocalOptions.setVariable("auto_save_local_replays", _gvars.air_autoSaveLocalReplays);
        }

        private function onUseCacheClicked(e:Event):void
        {
            _gvars.air_useLocalFileCache = !_gvars.air_useLocalFileCache;
            LocalOptions.setVariable("use_local_file_cache", _gvars.air_useLocalFileCache);
        }

        private function onVSyncClicked(e:Event):void
        {
            CONFIG::vsync
            {
                _gvars.gameMain.stage.vsyncEnabled = _gvars.air_useVSync = !_gvars.air_useVSync;
                LocalOptions.setVariable("vsync", _gvars.air_useVSync);
            }
        }

        private function onUseWebsocketsClicked(e:Event):void
        {
            if (_gvars.air_useWebsockets)
            {
                _gvars.destroyWebsocketServer();
                _gvars.air_useWebsockets = false;
                LocalOptions.setVariable("use_websockets", _gvars.air_useWebsockets);
            }
            else
            {
                if (_gvars.initWebsocketServer())
                {
                    _gvars.air_useWebsockets = true;
                    LocalOptions.setVariable("use_websockets", _gvars.air_useWebsockets);
                    onUseWebsocketMouseOver(null);
                }
                else
                {
                    _optionUseWebsockets.checked = false;
                    Alert.add(_lang.string(Lang.OPTIONS_UNABLE_TO_START_WEBSOCKETS), 120, Alert.RED);
                }
            }
        }

        private function onWebsocketOverlayClicked(e:Event):void
        {
            navigateToURL(new URLRequest(Constant.WEBSOCKET_OVERLAY_URL), "_blank");
        }

        private function onWindowRememberPositionClicked(e:Event):void
        {
            _gvars.air_saveWindowPosition = !_gvars.air_saveWindowPosition;
            LocalOptions.setVariable("save_window_position", _gvars.air_saveWindowPosition);
        }

        private function onWindowSetPositionClicked(e:Event):void
        {
            _parent.addChild(new WindowOptionConfirm(_gvars.airWindowProperties, onWindowOptionUpdated));

            _gvars.airWindowProperties.x = _optionWindowX.validate(Math.round((Capabilities.screenResolutionX - _gvars.gameMain.stage.nativeWindow.width) * 0.5));
            _gvars.airWindowProperties.y = _optionWindowY.validate(Math.round((Capabilities.screenResolutionY - _gvars.gameMain.stage.nativeWindow.height) * 0.5));
            onWindowOptionUpdated();
        }

        private function onWindowResetPositionClicked(e:Event):void
        {
            _gvars.airWindowProperties.x = Math.round((Capabilities.screenResolutionX - _gvars.gameMain.stage.nativeWindow.width) * 0.5);
            _gvars.airWindowProperties.y = Math.round((Capabilities.screenResolutionY - _gvars.gameMain.stage.nativeWindow.height) * 0.5);
            onWindowOptionUpdated();
        }

        private function onWindowRememberSizeClicked(e:Event):void
        {
            _gvars.air_saveWindowSize = !_gvars.air_saveWindowSize;
            LocalOptions.setVariable("save_window_size", _gvars.air_saveWindowSize);
        }

        private function onWindowSetSizeClicked(e:Event):void
        {
            _parent.addChild(new WindowOptionConfirm(_gvars.airWindowProperties, onWindowOptionUpdated));

            _gvars.airWindowProperties.width = _optionWindowWidth.validate(Main.GAME_WIDTH);
            _gvars.airWindowProperties.height = _optionWindowHeight.validate(Main.GAME_HEIGHT);
            onWindowOptionUpdated();
        }

        private function onWindowResetSizeClicked(e:Event):void
        {
            _gvars.airWindowProperties.width = Main.GAME_WIDTH;
            _gvars.airWindowProperties.height = Main.GAME_HEIGHT;
            onWindowOptionUpdated();
        }

        private function onFramerateChanged(e:Event):void
        {
            _settings.frameRate = _optionFramerate.validate(60);
            _settings.frameRate = Math.max(Math.min(_settings.frameRate, 1000), 10);
            _gvars.removeSongFiles();
        }

        private function onMPTextSizeChanged(e:Event):void
        {
            Style.fontSize = _avars.configMPSize = _optionMPTextSize.validate(10);
            _avars.mpSave();
        }

        private function onWindowPropertyChanged(e:Event):void
        {
            _optionWindowX.text = _gvars.airWindowProperties.x.toString();
            _optionWindowY.text = _gvars.airWindowProperties.y.toString();
            _optionWindowWidth.text = _gvars.airWindowProperties.width.toString();
            _optionWindowHeight.text = _gvars.airWindowProperties.height.toString();
        }

        public function onWindowOptionUpdated():void
        {
            _gvars.gameMain.ignoreWindowChanges = true;
            _gvars.gameMain.stage.nativeWindow.x = _gvars.airWindowProperties.x;
            _gvars.gameMain.stage.nativeWindow.y = _gvars.airWindowProperties.y;
            _gvars.gameMain.stage.nativeWindow.width = _gvars.airWindowProperties.width + Main.WINDOW_WIDTH_EXTRA;
            _gvars.gameMain.stage.nativeWindow.height = _gvars.airWindowProperties.height + Main.WINDOW_HEIGHT_EXTRA;
            _gvars.gameMain.ignoreWindowChanges = false;
        }

        private function onLegacyEngineMouseOver(e:Event):void
        {
            _optionIncludeLegacy.addEventListener(MouseEvent.MOUSE_OUT, onLegacyEngineMouseOut);
            displayToolTip(_optionIncludeLegacy.x, _optionIncludeLegacy.y + 22, _lang.string("popup_legacy_songs"), TextFormatAlign.LEFT);
        }

        private function onLegacyEngineMouseOut(e:Event):void
        {
            _optionIncludeLegacy.removeEventListener(MouseEvent.MOUSE_OUT, onLegacyEngineMouseOut);
            hideTooltip();
        }

        private function onUseWebsocketMouseOver(e:Event):void
        {
            if (!_gvars.air_useWebsockets)
                return;

            const activePort:uint = _gvars.websocketPortNumber("websocket");
            if (activePort == 0)
                return;

            _optionUseWebsockets.addEventListener(MouseEvent.MOUSE_OUT, onUseWebsocketMouseOut);
            displayToolTip(_optionUseWebsockets.x, _optionUseWebsockets.y + 22, sprintf(_lang.string(Lang.OPTIONS_ACTIVE_PORT), {"port": _gvars.websocketPortNumber("websocket").toString()}));
        }

        private function onUseWebsocketMouseOut(e:Event):void
        {
            _optionUseWebsockets.removeEventListener(MouseEvent.MOUSE_OUT, onUseWebsocketMouseOut);
            hideTooltip();
        }

        private function onStartUpScreenSelected(e:Event):void
        {
            _settings.startUpScreen = e.target.selectedItem.data as int;
        }

        private function setLanguage():void
        {
            _ignoreLanguageCombo = true;
            _optionLanguage.selectedItemByData = _settings.language;
            _ignoreLanguageCombo = false;
        }

        private function onLanguageSelected(e:Event):void
        {
            if (!_ignoreLanguageCombo)
            {
                _settings.language = e.target.selectedItem.data as String;

                _gvars.gameMain.activePanel.draw();
                _gvars.gameMain.buildContextMenu();

                if (_gvars.gameMain.activePanel is MainMenu)
                {
                    const mmpanel:MainMenu = (_gvars.gameMain.activePanel as MainMenu);
                    mmpanel.updateMenuMusicControls();
                }

                // refresh popup
                _gvars.gameMain.dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_OPTIONS));
            }
        }

        private function onEngineDefaultSelected(e:Event):void
        {
            if (!_ignoreEngineCombo)
            {
                _avars.legacyDefaultEngine = (e.target as ComboBox).selectedItem.data;
                _avars.legacyDefaultSave();
            }
        }

        private function onAddEngine(url:String):void
        {
            ChartFFRLegacy.parseEngine(url, onEngineAdded);
        }

        private function onEngineSelected(e:Event):void
        {
            const data:Object = _optionEngine.selectedItem.data;
            // Add Engine
            if (data == this)
            {
                new Prompt(_parent, 320, "Engine URL", 120, "Add Engine", onAddEngine);
            }
            // Clears Engines
            else if (data == _optionEngine)
            {
                _avars.legacyEngines = [];
                _avars.legacySave();
                engineRefresh();
            }
            // Change Engine
            else if (!_ignoreEngineCombo && data != _avars.configLegacy)
            {
                _avars.configLegacy = data;
                _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, _playlist.engineChangeHandler);
                _playlist.addEventListener(GlobalVariables.LOAD_ERROR, _playlist.engineChangeHandler);
                _playlist.load();
            }
        }

        private function onEngineAdded(engine:Object):void
        {
            Alert.add("Engine Loaded: " + engine.name, 80);
            for (var i:int = 0; i < _avars.legacyEngines.length; i++)
            {
                if (_avars.legacyEngines[i].id == engine.id)
                {
                    engine.level_ranks = _avars.legacyEngines[i].level_ranks;
                    _avars.legacyEngines[i] = engine;
                    break;
                }
            }

            if (i == _avars.legacyEngines.length)
                _avars.legacyEngines.push(engine);

            _avars.legacySave();
            engineRefresh();
        }

        private function engineRefresh():void
        {
            _ignoreEngineCombo = true;

            // Engine Playlist Select
            _optionEngine.removeAll();
            _optionEngineDefault.removeAll();
            _optionEngine.addItem({label: Constant.BRAND_NAME_LONG, data: null});
            _optionEngineDefault.addItem({label: Constant.BRAND_NAME_LONG, data: null});
            _optionEngine.selectedIndex = 0;
            _optionEngineDefault.selectedIndex = 0;

            for each (var engine:Object in _avars.legacyEngines)
            {
                const item:Object = {label: engine.name, data: engine};
                if (!ChartFFRLegacy.validURL(engine["playlistURL"]))
                    continue;

                if (engine["config_url"] == null)
                {
                    Alert.add("Please re-add " + engine["name"] + ", missing required information.", 240, Alert.RED);
                    continue;
                }

                _optionEngine.addItem(item);
                _optionEngineDefault.addItem(item);

                if (engine == _avars.configLegacy || (_avars.configLegacy && engine["id"] == _avars.configLegacy["id"]))
                    _optionEngine.selectedItem = item;

                if (engine == _avars.legacyDefaultEngine || (_avars.legacyDefaultEngine && engine["id"] == _avars.legacyDefaultEngine["id"]))
                    _optionEngineDefault.selectedItem = item;
            }

            _optionEngine.addItem({label: "Add Engine...", data: this});
            if (_avars.legacyEngines.length > 0 && _optionEngine.items.length > 2)
                _optionEngine.addItem({label: "Clear Engines", data: _optionEngine});

            _ignoreEngineCombo = false;
        }
    }
}
