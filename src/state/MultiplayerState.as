package state
{

    public class MultiplayerState extends State implements IState
    {
        public function MultiplayerState(frozen:Boolean = false)
        {
            super(frozen);
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:MultiplayerState = new MultiplayerState(false);

            return cloned;
        }
    }
}
