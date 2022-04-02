package singletons
{

    import be.aboutme.airserver.AIRServer;
    import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
    import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;

    public class StreamWebsocket
    {
        private static var _instance:StreamWebsocket = null;

        private var _owner:Object;

        private var _websocketServer:AIRServer;

        public function StreamWebsocket(owner:Object)
        {
            if (_instance != null && owner != _instance._owner)
                throw new Error("Multiple state instances not allowed");

            _owner = owner;
            _instance = this;
        }

        public static function get instance():StreamWebsocket
        {
            return _instance;
        }

        public static function initWebsocketServer(owner:Object):Boolean
        {
            if (_instance == null)
                return false;

            if (_instance._websocketServer == null)
            {
                _instance._websocketServer = new AIRServer();
                _instance._websocketServer.addEndPoint(new SocketEndPoint(21235, new WebSocketClientHandlerFactory()));
            }

            // Didn't start, remove reference
            if (!_instance._websocketServer.start())
            {
                _instance._websocketServer.stop();
                return false;
            }
            return true;
        }

        public static function getWebsocket(owner:Object):AIRServer
        {
            if (_instance == null || owner != _instance._owner)
                throw new Error("Arbitrary modification of state");

            return _instance._websocketServer;
        }

        public static function destroyWebsocketServer(owner:Object):void
        {
            if (_instance == null || _instance._websocketServer == null)
                return;

            if (owner != _instance._owner)
                throw new Error("Arbitrary modification of state");

            _instance._websocketServer.stop();
            _instance._websocketServer = null;
        }

        public static function websocketPortNumber(type:String):uint
        {
            if (_instance == null || _instance._websocketServer == null)
                return 0;

            return _instance._websocketServer.getPortNumber(type);
        }
    }
}
