package state_management
{

    import be.aboutme.airserver.AIRServer;
    import be.aboutme.airserver.messages.Message;
    import classes.ui.WindowState;
    import flash.display.Stage;
    import flash.events.IEventDispatcher;
    import singletons.StreamWebsocket;
    import state.AirState;
    import state.AppState;
    import com.flashfla.utils.Screenshots;
    import flash.display.StageDisplayState;
    import events.actions.air.LoadLocalAirConfigEvent;
    import events.actions.air.ToggleWebsocketEvent;
    import events.actions.air.ToggleVSyncEvent;
    import events.actions.air.SendWebsocketMessageEvent;
    import events.actions.air.TakeScreenshotEvent;
    import events.actions.air.ToggleFullScreenEvent;
    import events.actions.air.CloseWebsocketEvent;
    import events.actions.air.WebsocketStateChangedEvent;

    public class AirController extends Controller
    {
        private var _stage:Stage;

        public function AirController(target:IEventDispatcher, owner:Object, updateStateCallback:Function, stage:Stage)
        {
            super(target, owner, updateStateCallback);

            _stage = stage;

            addListeners();
        }

        private function addListeners():void
        {
            target.addEventListener(LoadLocalAirConfigEvent.EVENT_TYPE, loadAirConfig);
            target.addEventListener(ToggleWebsocketEvent.EVENT_TYPE, toggleWebsocket);
            target.addEventListener(ToggleVSyncEvent.EVENT_TYPE, toggleVSync);
            target.addEventListener(TakeScreenshotEvent.EVENT_TYPE, takeScreenShot);
            target.addEventListener(ToggleFullScreenEvent.EVENT_TYPE, toggleFullScreen);
            target.addEventListener(SendWebsocketMessageEvent.EVENT_TYPE, websocketSend);
            target.addEventListener(CloseWebsocketEvent.EVENT_TYPE, closeWebsocket);
        }

        private function loadAirConfig():void
        {
            var airState:AirState = new AirState();

            airState.useVSync = LocalOptions.getVariable("vsync", false);
            airState.useLocalFileCache = LocalOptions.getVariable("use_local_file_cache", true);
            airState.autoSaveLocalReplays = LocalOptions.getVariable("auto_save_local_replays", true);
            airState.useWebsockets = LocalOptions.getVariable("use_websockets", false);
            airState.saveWindowPosition = LocalOptions.getVariable("save_window_position", false);
            airState.saveWindowSize = LocalOptions.getVariable("save_window_size", false);

            var rawWindowProperties:Object = LocalOptions.getVariable("window_properties", {"x": 0, "y": 0, "width": 0, "height": 0});
            airState.windowState = parseWindowProperties(rawWindowProperties);

            if (airState.useWebsockets)
                StreamWebsocket.initWebsocketServer(this);

            if (airState.saveWindowPosition)
            {
                _stage.nativeWindow.x = airState.windowState.x;
                _stage.nativeWindow.y = airState.windowState.y;
            }

            if (airState.saveWindowSize)
            {
                _stage.nativeWindow.width = Math.max(100, airState.windowState.width + Main.WINDOW_WIDTH_EXTRA);
                _stage.nativeWindow.height = Math.max(100, airState.windowState.height + Main.WINDOW_HEIGHT_EXTRA);
            }

            var newState:AppState = AppState.clone(owner);
            newState.air = airState;

            updateState(newState);
        }

        private function parseWindowProperties(properties:Object):WindowState
        {
            return new WindowState(properties["x"], properties["y"], properties["width"], properties["height"]);
        }

        private function toggleWebsocket():void
        {
            var newState:AppState = AppState.clone(owner);
            var airState:AirState = newState.air;

            var successfulInit:Boolean = false;

            if (airState.useWebsockets)
            {
                StreamWebsocket.destroyWebsocketServer(this);
                airState.useWebsockets = false;
                LocalOptions.setVariable("use_websockets", airState.useWebsockets);
            }
            else
            {
                successfulInit = StreamWebsocket.initWebsocketServer(this);

                if (successfulInit)
                {
                    airState.useWebsockets = true;
                    LocalOptions.setVariable("use_websockets", airState.useWebsockets);
                }
            }

            updateState(newState);

            target.dispatchEvent(new WebsocketStateChangedEvent(airState.useWebsockets, !successfulInit));
        }

        private function closeWebsocket():void
        {
            StreamWebsocket.destroyWebsocketServer(this);
        }

        private function websocketSend(event:SendWebsocketMessageEvent):void
        {
            var command:String = event.command;
            var data:Object = event.data;

            var websocket:AIRServer = StreamWebsocket.getWebsocket(this);

            if (websocket == null)
                return;

            var websocketMessage:Message = new Message();
            websocketMessage.command = command;
            websocketMessage.data = data;

            websocket.sendMessageToAllClients(websocketMessage);
        }

        private function toggleVSync():void
        {
            var newState:AppState = AppState.clone(owner);
            var airState:AirState = newState.air;

            airState.useVSync = !airState.useVSync;

            _stage.vsyncEnabled = airState.useVSync;
            LocalOptions.setVariable("vsync", airState.useVSync);

            updateState(newState);
        }

        /**
         * Takes a screenshot of the stage and saves it to disk.
         */
        private function takeScreenShot(event:TakeScreenshotEvent):void
        {
            Screenshots.takeScreenshot(_stage, event.path);
        }

        private function toggleFullScreen():void
        {
            if (_stage == null)
                return;

            if (_stage.displayState == StageDisplayState.NORMAL)
                _stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
            else
                _stage.displayState = StageDisplayState.NORMAL;
        }
    }
}
