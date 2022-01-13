package
{

    import flash.events.IEventDispatcher;
    import events.state.StateEvent;
    import events.state.ReloadEngineEvent;
    import arc.mp.MultiplayerState;
    import classes.Playlist;
    import flash.events.EventDispatcher;
    import game.GameLoading;
    import game.GameplayDisplay;
    import events.navigation.ChangePanelEvent;
    import events.state.LogoutEvent;
    import classes.User;
    import events.navigation.popups.RemovePopupEvent;
    import events.navigation.InitialLoadingEvent;

    public class StateManager extends EventDispatcher
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;

        private var _target:IEventDispatcher;
        private var _navigator:Navigator;

        public function StateManager(target:IEventDispatcher, navigator:Navigator)
        {
            super(target);
            _target = target;
            _navigator = navigator;

            _target.addEventListener(StateEvent.EVENT_TYPE, onStateEvent);
        }

        private function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case ReloadEngineEvent.STATE:
                    onReloadEngineEvent(e as ReloadEngineEvent);
                    break;
                case LogoutEvent.STATE:
                    onLogoutEvent(e as LogoutEvent);
                    break;
            }
        }

        private function onReloadEngineEvent(e:ReloadEngineEvent):void
        {
            if (_navigator.activePanel is GameLoading || _navigator.activePanel is GameplayDisplay || _navigator.activePanel is InitialLoading)
                return;

            MultiplayerState.destroyInstance();
            Flags.VALUES = {};
            Playlist.clearCanon();

            _target.dispatchEvent(new RemovePopupEvent());
            _target.dispatchEvent(new InitialLoadingEvent(true));
        }

        private function onLogoutEvent(e:LogoutEvent):void
        {

            if (_navigator.activePanel is GameLoading || _navigator.activePanel is GameplayDisplay || _navigator.activePanel is InitialLoading)
                return;

            MultiplayerState.destroyInstance();
            Flags.VALUES = {};
            _gvars.userSession = "0";
            _gvars.playerUser = new User(true);
            _gvars.playerUser.loadFull(_gvars.userSession);
            _gvars.activeUser = _gvars.playerUser;

            _target.dispatchEvent(new RemovePopupEvent());
            _target.dispatchEvent(new ChangePanelEvent(PanelMediator.PANEL_GAME_LOGIN));
        }
    }
}
