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
    import classes.ui.VersionText;
    import classes.ui.WindowState;
    import com.flashdynamix.utils.SWFProfiler;
    import com.flashfla.utils.Screenshots;
    import com.greensock.TweenLite;
    import com.greensock.plugins.AutoAlphaPlugin;
    import com.greensock.plugins.TintPlugin;
    import com.greensock.plugins.TweenPlugin;
    import events.navigation.InitialLoadingEvent;
    import events.navigation.popups.AddPopupEvent;
    import events.state.GameDataLoadedEvent;
    import events.state.LanguageChangedEvent;
    import events.state.LoadLocalAirConfigEvent;
    import flash.desktop.NativeApplication;
    import flash.display.Sprite;
    import flash.display.StageDisplayState;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.text.TextField;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import state.AirState;
    import state.AppState;
    import state_management.AppController;
    import state_management.Controller;

    public class Main extends Sprite
    {
        public static const GAME_WIDTH:int = 780;
        public static const GAME_HEIGHT:int = 480;

        public static var WINDOW_WIDTH_EXTRA:Number = 0;
        public static var WINDOW_HEIGHT_EXTRA:Number = 0;

        private var _lang:Language = Language.instance;

        public var navigator:Navigator;
        private var _appController:Controller;

        public var ignoreWindowChanges:Boolean = false;

        public var versionText:VersionText;
        public var bg:GameBackgroundColor;

        ///- Constructor
        public function Main():void
        {
            super();

            // Initiate singleton state with its manager
            _appController = new AppController(this, null);
            AppState.instance = new AppState(_appController, true);

            setListeners();

            // Sometimes AIR doesn't load the stage right away.
            if (stage)
                gameInit();
            else
            {
                addEventListener(Event.ADDED_TO_STAGE, function _init(e:Event):void
                {
                    removeEventListener(Event.ADDED_TO_STAGE, _init);
                    gameInit();
                });
            }
        }

        private function setListeners():void
        {
            addEventListener(GameDataLoadedEvent.EVENT_TYPE, buildContextMenu);
            addEventListener(LanguageChangedEvent.EVENT_TYPE, onLanguageChanged);
        }

        public function loadAirOptions():void
        {
            dispatchEvent(new LoadLocalAirConfigEvent());
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
            loadAirOptions();

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

            var airState:AirState = AppState.instance.air;
            if (airState.saveWindowPosition)
            {
                stage.nativeWindow.x = airState.windowState.x;
                stage.nativeWindow.y = airState.windowState.y;
            }
            if (airState.saveWindowSize)
            {
                stage.nativeWindow.width = Math.max(100, airState.windowState.width + WINDOW_WIDTH_EXTRA);
                stage.nativeWindow.height = Math.max(100, airState.windowState.height + WINDOW_HEIGHT_EXTRA);
            }
            ignoreWindowChanges = false;

            //- Load Menu Music
            dispatchEvent(new LoadMenuMusicEvent());

            //- Background
            stage.color = 0x000000;
            bg = new GameBackgroundColor();
            addChild(bg);

            versionText = new VersionText(stage.width - 5, 2);
            navigator = new Navigator(this, bg, versionText);

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

            navigator.onChangePanelEvent(new InitialLoadingEvent(false));
        }

        // TODO: Place this window stuff elsewhere
        /**
         * Takes a screenshot of the stage and saves it to disk.
         */
        public function takeScreenShot(filename:String = null):void
        {
            Screenshots.takeScreenshot(stage, filename);
        }

        //- Full Screen
        public function toggleFullScreen(e:Event = null):void
        {
            if (stage)
            {
                if (stage.displayState == StageDisplayState.NORMAL)
                    stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
                else
                    stage.displayState = StageDisplayState.NORMAL;
            }
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

            dispatchEvent(new CloseWebsocketEvent());
        }

        private function onNativeWindowClosing(e:Event):void
        {
            var airWindowProperties:WindowState = AppState.instance.air.windowState;

            // TODO: Do not mutate state in here
            airWindowProperties.width = stage.nativeWindow.width - Main.WINDOW_WIDTH_EXTRA;
            airWindowProperties.height = stage.nativeWindow.height - Main.WINDOW_HEIGHT_EXTRA;
            airWindowProperties.x = stage.nativeWindow.x;
            airWindowProperties.y = stage.nativeWindow.y;

            LocalOptions.setVariable("window_properties", airWindowProperties);
        }

        private function onNativeWindowPropertyChange(e:NativeWindowBoundsEvent):void
        {
            if (ignoreWindowChanges)
                return;

            var airWindowProperties:WindowState = AppState.instance.air.windowState;

            // TODO: Do not mutate state in here
            airWindowProperties.width = e.afterBounds.width - Main.WINDOW_WIDTH_EXTRA;
            airWindowProperties.height = e.afterBounds.height - Main.WINDOW_HEIGHT_EXTRA;
            airWindowProperties.x = e.afterBounds.x;
            airWindowProperties.y = e.afterBounds.y;
        }

        CONFIG::vsync
        public function onVsyncStateChangeAvailability(event:VsyncStateChangeAvailabilityEvent):void
        {
            stage.vsyncEnabled = event.available ? AppState.instance.air.useVSync : true;
        }

        public function redrawBackground():void
        {
            bg.redraw();
        }

        ///- Fullscreen Handling
        private function toggleContextPopup(e:Event):void
        {
            if (!AppState.instance.menu.disablePopups)
                dispatchEvent(new AddPopupEvent(Routes.POPUP_CONTEXT_MENU));
        }

        ///- Key Handling
        private function keyboardKeyDown(e:KeyboardEvent):void
        {
            var keyCode:int = e.keyCode;
            if (Flags.VALUES[Flags.ENABLE_GLOBAL_POPUPS])
            {
                // Options
                if (keyCode == AppState.instance.auth.user.settings.keyOptions && (stage.focus == null || !(stage.focus is TextField)))
                    dispatchEvent(new AddPopupEvent(Routes.POPUP_OPTIONS));

                // Help Menu
                else if (keyCode == Keyboard.F1)
                    dispatchEvent(new AddPopupEvent(Routes.POPUP_HELP));

                // Replay History
                else if (keyCode == Keyboard.F2)
                    dispatchEvent(new AddPopupEvent(Routes.POPUP_REPLAY_HISTORY));
            }
        }
    }
}
