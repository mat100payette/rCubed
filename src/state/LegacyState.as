package state
{

    public class LegacyState extends State implements IState
    {
        private var _engineDefaultLoad:Boolean;
        private var _engineDefaultLoadSkip:Boolean;

        public function LegacyState(frozen:Boolean = false)
        {
            super(frozen);

            _engineDefaultLoad = false;
            _engineDefaultLoadSkip = false;
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:LegacyState = new LegacyState(false);

            return cloned;
        }

        public function get engineDefaultLoad():Boolean
        {
            return _engineDefaultLoad;
        }

        public function get engineDefaultLoadSkip():Boolean
        {
            return _engineDefaultLoadSkip;
        }
    }
}
