package state
{

    public class AppState extends State implements IState
    {
        private static var _instance:AppState = null;

        private var _owner:Object;

        private var _air:AirState;
        private var _content:ContentState;
        private var _auth:AuthState;
        private var _multiplayer:MultiplayerState;
        private var _gameplay:GameplayState;
        private var _menu:MenuState;

        public function AppState(owner:Object, frozen:Boolean = false)
        {
            super(frozen);

            _owner = owner;

            _air = new AirState(frozen);
            _content = new ContentState(frozen);
            _auth = new AuthState(frozen);
            _multiplayer = new MultiplayerState(frozen);
            _gameplay = new GameplayState(frozen);
            _menu = new MenuState(frozen);
        }

        public static function set instance(state:AppState):void
        {
            if (_instance != null && state._owner != _instance._owner)
                throw new Error("Multiple state instances not allowed");

            _instance = state;
        }

        public static function get instance():AppState
        {
            return _instance;
        }

        public function freeze():void
        {
            super.internalFreeze();
            _air.freeze();
            _content.freeze();
            _auth.freeze();
            _multiplayer.freeze();
            _gameplay.freeze();
            _menu.freeze();
        }

        public static function clone(owner:Object):AppState
        {
            var cloned:AppState = _instance.clone() as AppState;
            cloned._owner = owner;

            return cloned;
        }

        public function clone():State
        {
            var cloned:AppState = new AppState(false);

            cloned._air = _air.clone() as AirState;
            cloned._content = _content.clone() as ContentState;
            cloned._auth = _auth.clone() as AuthState;
            cloned._multiplayer = _multiplayer.clone() as MultiplayerState;
            cloned._gameplay = _gameplay.clone() as GameplayState;
            cloned._menu = _menu.clone() as MenuState;

            return cloned;
        }

        public static function update(newState:AppState):void
        {
            if (_instance == null)
                throw new Error("Cannot update null static state");

            if (newState._owner != _instance._owner)
                throw new Error("Arbitrary modification of state");

            _instance = newState;
        }

        public function get air():AirState
        {
            return _air;
        }

        public function set air(value:AirState):void
        {
            throwIfFrozen();
            _air = value;
        }

        public function get content():ContentState
        {
            return _content;
        }

        public function set content(value:ContentState):void
        {
            throwIfFrozen();
            _content = value;
        }

        public function get auth():AuthState
        {
            return _auth;
        }

        public function set auth(value:AuthState):void
        {
            throwIfFrozen();
            _auth = value;
        }

        public function get multiplayer():MultiplayerState
        {
            return _multiplayer;
        }

        public function set multiplayer(value:MultiplayerState):void
        {
            throwIfFrozen();
            _multiplayer = value;
        }

        public function get gameplay():GameplayState
        {
            return _gameplay;
        }

        public function set gameplay(value:GameplayState):void
        {
            throwIfFrozen();
            _gameplay = value;
        }

        public function get menu():MenuState
        {
            return _menu;
        }

        public function set menu(value:MenuState):void
        {
            throwIfFrozen();
            _menu = value;
        }
    }
}
