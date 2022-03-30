package state_management
{

    import events.state.StateEvent;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    public class StateManager extends EventDispatcher
    {
        private var _target:IEventDispatcher;
        private var _owner:Object;
        private var _update:Function;

        public function StateManager(target:IEventDispatcher = null, owner:Object = null, updateCallback:Function = null)
        {
            super(target);

            _target = target;
            _update = updateCallback;
        }

        protected function get target():IEventDispatcher
        {
            return _target;
        }

        protected function get owner():Object
        {
            return _owner;
        }

        protected function get updateState():Function
        {
            return _update;
        }

        public function onStateEvent(e:StateEvent):void
        {
        }
    }
}
