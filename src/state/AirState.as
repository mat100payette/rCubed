package state
{

    import classes.ui.WindowState;
    import be.aboutme.airserver.AIRServer;

    public class AirState extends State implements IState
    {
        private var _useLocalFileCache:Boolean;
        private var _autoSaveLocalReplays:Boolean;
        private var _useVSync:Boolean;
        private var _useWebsockets:Boolean;
        private var _saveWindowPosition:Boolean;
        private var _saveWindowSize:Boolean;

        private var _window:WindowState;

        public function AirState(frozen:Boolean = false)
        {
            super(frozen);

            _useLocalFileCache = false;
            _autoSaveLocalReplays = false;
            _useVSync = true;
            _useWebsockets = false;
            _saveWindowPosition = false;
            _saveWindowSize = false;

            _window = new WindowState();
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:AirState = new AirState(false);

            cloned._useLocalFileCache = _useLocalFileCache;
            cloned._autoSaveLocalReplays = _autoSaveLocalReplays;
            cloned._useVSync = _useVSync;
            cloned._useWebsockets = _useWebsockets;
            cloned._saveWindowPosition = _saveWindowPosition;
            cloned._saveWindowSize = _saveWindowSize;

            cloned._window = _window.clone();

            return cloned;
        }

        public function get useLocalFileCache():Boolean
        {
            return _useLocalFileCache;
        }

        public function set useLocalFileCache(value:Boolean):void
        {
            throwIfFrozen();
            _useLocalFileCache = value;
        }

        public function get autoSaveLocalReplays():Boolean
        {
            return _autoSaveLocalReplays;
        }

        public function set autoSaveLocalReplays(value:Boolean):void
        {
            throwIfFrozen();
            _autoSaveLocalReplays = value;
        }

        public function get useVSync():Boolean
        {
            return _useVSync;
        }

        public function set useVSync(value:Boolean):void
        {
            throwIfFrozen();
            _useVSync = value;
        }

        public function get useWebsockets():Boolean
        {
            return _useWebsockets;
        }

        public function set useWebsockets(value:Boolean):void
        {
            throwIfFrozen();
            _useWebsockets = value;
        }

        public function get saveWindowPosition():Boolean
        {
            return _saveWindowPosition;
        }

        public function set saveWindowPosition(value:Boolean):void
        {
            throwIfFrozen();
            _saveWindowPosition = value;
        }

        public function get saveWindowSize():Boolean
        {
            return _saveWindowSize;
        }

        public function set saveWindowSize(value:Boolean):void
        {
            throwIfFrozen();
            _saveWindowSize = value;
        }

        public function get windowProperties():WindowState
        {
            return _window;
        }

        public function set windowProperties(value:WindowState):void
        {
            throwIfFrozen();
            _window = value;
        }
    }
}
