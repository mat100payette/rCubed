package state_management
{
    import classes.User;
    import events.actions.auth.LogoutEvent;
    import events.actions.auth.SetUserSessionEvent;
    import events.navigation.ChangePanelEvent;
    import events.navigation.popups.RemovePopupEvent;
    import flash.events.IEventDispatcher;
    import state.AppState;
    import state.AuthState;
    import state.MultiplayerState;

    public class AuthController extends Controller
    {
        public function AuthController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);

            addListeners();
        }

        private function addListeners():void
        {
            target.addEventListener(LogoutEvent.EVENT_TYPE, logout);
            target.addEventListener(SetUserSessionEvent.EVENT_TYPE, setUserSession);
        }

        private function logout():void
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

        private function setUserSession(event:SetUserSessionEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var auth:AuthState = newState.auth;

            auth.userSession = event.session;

            updateState(newState);
        }
    }
}
