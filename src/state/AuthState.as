package state
{

    import classes.User;

    public class AuthState extends State implements IState
    {
        private var _user:User;
        private var _userSession:String;
        private var _isGuest:Boolean;

        public function AuthState(frozen:Boolean = false)
        {
            super(frozen);

            _user = null;
            _userSession = "0";
            _isGuest = false;
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:AuthState = new AuthState(false);

            cloned._user = _user;
            cloned._userSession = _userSession;
            cloned._isGuest = _isGuest;

            return cloned;
        }

        public function get user():User
        {
            return _user;
        }

        public function set user(value:User):void
        {
            throwIfFrozen();
            _user = value;
        }

        public function get userSession():String
        {
            return _userSession;
        }

        public function set userSession(value:String):void
        {
            throwIfFrozen();
            _userSession = value;
        }

        public function get isGuest():Boolean
        {
            return _isGuest;
        }

        public function set isGuest(value:Boolean):void
        {
            throwIfFrozen();
            _isGuest = value;
        }
    }
}
