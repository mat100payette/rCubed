package state_management
{

    import be.aboutme.airserver.AIRServer;
    import be.aboutme.airserver.messages.Message;
    import classes.ui.WindowState;
    import events.state.LoadLocalAirConfigEvent;
    import events.state.StateEvent;
    import events.state.ToggleVSyncEvent;
    import events.state.ToggleWebsocketEvent;
    import events.state.WebsocketStateChangedEvent;
    import flash.display.Stage;
    import flash.events.IEventDispatcher;
    import singletons.StreamWebsocket;
    import state.AirState;
    import state.AppState;

    public class AirController extends Controller
    {
        private var _stage:Stage;

        public function AirController(target:IEventDispatcher, owner:Object, updateStateCallback:Function, stage:Stage)
        {
            super(target, owner, updateStateCallback);

            _stage = stage;
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case LoadLocalAirConfigEvent.STATE:
                    loadAirConfig();
                    break;
                case ToggleWebsocketEvent.STATE:
                    onToggleWebsocketEvent();
                    break;
                case ToggleVSyncEvent.STATE:
                    toggleVSync();
                    break;
            }
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

            var newState:AppState = AppState.clone(owner);
            newState.air = airState;

            updateState(newState);
        }

        private function parseWindowProperties(properties:Object):WindowState
        {
            return new WindowState(properties["x"], properties["y"], properties["width"], properties["height"]);
        }

        private function onToggleWebsocketEvent():void
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

        private function websocketSend(cmd:String, data:Object):void
        {
            var websocket:AIRServer = StreamWebsocket.getWebsocket(this);

            if (websocket == null)
                return;

            var websocketMessage:Message = new Message();
            websocketMessage.command = cmd;
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
    }
}
