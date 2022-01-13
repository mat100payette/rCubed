/**
 * @author Jonathan (Velocity)
 */

package
{
    CONFIG::vsync
    {
        import flash.events.VsyncStateChangeAvailabilityEvent;
    }

    import assets.GameBackgroundColor;
    import classes.Alert;
    import classes.Language;
    import classes.NoteskinsList;
    import classes.Playlist;
    import classes.Site;
    import classes.ui.VersionText;
    import com.flashdynamix.utils.SWFProfiler;
    import com.greensock.TweenLite;
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
    import events.navigation.popups.AddPopupEvent;
    import events.navigation.InitialLoadingEvent;
    import events.state.GameDataLoadedEvent;
    import events.state.LanguageChangedEvent;
    import flash.display.Sprite;

    public class Main extends Sprite
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

        public var navigator:Navigator;
        private var _stateManager:StateManager;

        private var _popupQueue:Array = [];

        public var ignoreWindowChanges:Boolean = false;
        public var disablePopups:Boolean = false;

        public var versionText:VersionText;
        public var bg:GameBackgroundColor

        ///- Constructor
        public function Main():void
        {
            super();

            _gvars.gameMain = this;

            setListeners();

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

        private function setListeners():void
        {
            addEventListener(GameDataLoadedEvent.EVENT_TYPE, buildContextMenu);
            addEventListener(LanguageChangedEvent.EVENT_TYPE, onLanguageChanged);
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
            stage.nativeWindow.addEventListener(Event.CLOSING, onNativeWindowClosing);
            NativeApplication.nativeApplication.addEventListener(Event.EXITING, onNativeShutdown);
            stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, onNativeWindowPropertyChange, false, 1);
            stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onNativeWindowPropertyChange, false, 1);

            CONFIG::vsync
            {
                stage.addEventListener(VsyncStateChangeAvailabilityEvent.VSYNC_STATE_CHANGE_AVAILABILITY, onVsyncStateChangeAvailability);
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

            versionText = new VersionText(stage.width - 5, 2);
            navigator = new Navigator(this, bg, versionText);
            _stateManager = new StateManager(this, navigator);
            addChild(navigator);

            //- Add Debug Tracking
            addChild(versionText);

            //- Key listener
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, false, 0, true);
            stage.focus = stage;

            //- Notify if running dev build
            CONFIG::debug
            {
                Alert.add("Development Build - " + CONFIG::timeStamp + " - NOT FOR RELEASE", 120, Alert.RED);
            }

            navigator.changePanel(new InitialLoadingEvent(false));
        }

        private function onLanguageChanged(e:LanguageChangedEvent):void
        {
            buildContextMenu();
        }

        private function buildContextMenu():void
        {
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
        private function onNativeShutdown(e:Event):void
        {
            Logger.destroy();
            LocalOptions.flush();
            _gvars.onNativeProcessClose(e);
        }

        private function onNativeWindowClosing(e:Event):void
        {
            _gvars.airWindowProperties.width = stage.nativeWindow.width - Main.WINDOW_WIDTH_EXTRA;
            _gvars.airWindowProperties.height = stage.nativeWindow.height - Main.WINDOW_HEIGHT_EXTRA;
            _gvars.airWindowProperties.x = stage.nativeWindow.x;
            _gvars.airWindowProperties.y = stage.nativeWindow.y;

            LocalOptions.setVariable("window_properties", _gvars.airWindowProperties);
        }

        private function onNativeWindowPropertyChange(e:NativeWindowBoundsEvent):void
        {
            if (ignoreWindowChanges)
                return;

            _gvars.airWindowProperties.width = e.afterBounds.width - Main.WINDOW_WIDTH_EXTRA;
            _gvars.airWindowProperties.height = e.afterBounds.height - Main.WINDOW_HEIGHT_EXTRA;
            _gvars.airWindowProperties.x = e.afterBounds.x;
            _gvars.airWindowProperties.y = e.afterBounds.y;
        }

        CONFIG::vsync
        public function onVsyncStateChangeAvailability(event:VsyncStateChangeAvailabilityEvent):void
        {
            stage.vsyncEnabled = event.available ? _gvars.air_useVSync : true;
        }

        public function addPopupQueue(_panel:*, newLayer:Boolean = false):void
        {
            _popupQueue.push({"panel": _panel, "layer": newLayer});
        }

        public function redrawBackground():void
        {
            bg.redraw();
        }

        ///- Fullscreen Handling
        private function toggleContextPopup(e:Event):void
        {
            if (!disablePopups)
                dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_CONTEXT_MENU));
        }

        ///- Key Handling
        private function keyboardKeyDown(e:KeyboardEvent):void
        {
            var keyCode:int = e.keyCode;
            if (Flags.VALUES[Flags.ENABLE_GLOBAL_POPUPS])
            {
                // Options
                if (keyCode == _gvars.playerUser.settings.keyOptions && (stage.focus == null || !(stage.focus is TextField)))
                    dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_OPTIONS));

                // Help Menu
                else if (keyCode == Keyboard.F1)
                    dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_HELP));

                // Replay History
                else if (keyCode == Keyboard.F2)
                    dispatchEvent(new AddPopupEvent(PanelMediator.POPUP_REPLAY_HISTORY));
            }
        }
    }
}
