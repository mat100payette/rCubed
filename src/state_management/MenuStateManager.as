package state_management
{

    import flash.events.IEventDispatcher;
    import events.state.StateEvent;
    import events.state.SetPopupsEnabledEvent;
    import state.AppState;

    public class MenuStateManager extends StateManager
    {
        private var _target:IEventDispatcher;

        public function MenuStateManager(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case SetPopupsEnabledEvent.STATE:
                    onSetPopupsEnabled(e as SetPopupsEnabledEvent);
                    break;
            }
        }

        private function onSetPopupsEnabled(e:SetPopupsEnabledEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.menu.disablePopups = e.enabled;

            updateState(newState);
        }
    }
}
