package state
{

    public class GameplayState extends State implements IState
    {
        public function GameplayState(frozen:Boolean = false)
        {
            super(frozen);
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:GameplayState = new GameplayState(false);

            return cloned;
        }
    }
}
