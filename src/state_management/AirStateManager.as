package state_management
{

    import flash.events.IEventDispatcher;
    import events.state.StateEvent;
    import state.AppState;
    import classes.ui.WindowState;
    import state.AirState;
    import be.aboutme.airserver.AIRServer;
    import be.aboutme.airserver.messages.Message;
    import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
    import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;

    public class AirStateManager extends StateManager
    {
        private var _websocketServer:AIRServer;

        public function AirStateManager(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, updateStateCallback);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case *:
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
            airState.windowProperties = parseWindowProperties(rawWindowProperties);

            if (airState.useWebsockets)
                initWebsocketServer();

            var newState:AppState = AppState.clone(owner);
            newState.air = airState;

            updateState(newState);
        }

        private function parseWindowProperties(properties:Object):WindowState
        {
            return new WindowState(properties["x"], properties["y"], properties["width"], properties["height"]);
        }

        public function websocketPortNumber(type:String):uint
        {
            if (_websocketServer == null)
                return 0;

            return _websocketServer.getPortNumber(type);
        }

        public function initWebsocketServer():Boolean
        {
            if (_websocketServer != null)
                return false;

            _websocketServer = new AIRServer();
            _websocketServer.addEndPoint(new SocketEndPoint(21235, new WebSocketClientHandlerFactory()));

            var newState:AppState = AppState.clone(owner);

            // Didn't start, remove reference
            if (!_websocketServer.start())
            {
                _websocketServer.stop();
                _websocketServer = null;
                return false;
            }
            return true;

            updateState(newState);
        }

        public function destroyWebsocketServer():void
        {
            if (_websocketServer != null)
            {
                _websocketServer.stop();
                _websocketServer = null;
            }
        }

        public function websocketSend(cmd:String, data:Object):void
        {
            if (_websocketServer == null)
                return;

            var websocketMessage:Message = new Message();
            websocketMessage.command = cmd;
            websocketMessage.data = data;

            _websocketServer.sendMessageToAllClients(websocketMessage);
        }
    }
}
