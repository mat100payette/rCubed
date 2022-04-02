package state_management
{
    import classes.User;
    import events.navigation.ChangePanelEvent;
    import events.navigation.popups.RemovePopupEvent;
    import events.state.LogoutEvent;
    import events.state.StateEvent;
    import flash.events.IEventDispatcher;
    import state.AppState;
    import state.AuthState;
    import state.MultiplayerState;

    public class AuthController extends Controller
    {
        public function AuthController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case LogoutEvent.STATE:
                    onLogoutEvent();
                    break;
            }
        }

        private function onLogoutEvent():void
        {
            var newState:AppState = AppState.clone(owner);
            var auth:AuthState = newState.auth;

            MultiplayerState.destroyInstance();
            Flags.VALUES = {};

            auth.userSession = "0";
            auth.user = new User(true);
            auth.user.loadFull(auth.userSession);

            updateState(newState);

            target.dispatchEvent(new RemovePopupEvent());
            target.dispatchEvent(new ChangePanelEvent(Routes.PANEL_GAME_LOGIN));
        }
    }
}
