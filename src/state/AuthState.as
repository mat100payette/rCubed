package state
{

    import classes.User;

    public class AuthState extends State implements IState
    {
        private var _user:User;

        public function AuthState(frozen:Boolean = false)
        {
            super(frozen);
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:AuthState = new AuthState(false);

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
    }
}
