package state
{

    public class State
    {
        private var _frozen:Boolean;
        private var _freeze:Function;

        public function State(frozen:Boolean = false)
        {
            _frozen = frozen;
            _freeze = internalFreeze;
        }

        protected function internalFreeze():void
        {
            _frozen = true;
        }

        protected function get frozen():Boolean
        {
            return _frozen;
        }

        protected function throwIfFrozen():void
        {
            throw new Error("Attempted to mutate frozen state");
        }
    }
}
