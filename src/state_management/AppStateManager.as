package state_management
{

    import flash.events.IEventDispatcher;
    import events.state.StateEvent;
    import events.state.ReloadEngineEvent;
    import arc.mp.MultiplayerState;
    import flash.events.EventDispatcher;
    import events.navigation.ChangePanelEvent;
    import events.state.LogoutEvent;
    import classes.User;
    import events.navigation.popups.RemovePopupEvent;
    import events.navigation.InitialLoadingEvent;
    import events.state.EngineLoadedEvent;
    import menu.MenuSongSelection;
    import state.AppState;
    import events.state.SetAirConfigEvent;
    import events.state.interfaces.IAirStateEvent;

    public class AppStateManager extends StateManager
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;

        private var _airStateManager:AirStateManager;
        private var _menuStateManager:MenuStateManager;

        public function AppStateManager(target:IEventDispatcher)
        {
            super(target, this, internalUpdateState);

            target.addEventListener(StateEvent.EVENT_TYPE, onStateEvent);

            _airStateManager = new AirStateManager(target, this, internalUpdateState);
            _menuStateManager = new MenuStateManager(target, this, internalUpdateState);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            if (e is IAirStateEvent)
            {
                _menuStateManager.onStateEvent(e);
                return;
            }

            switch (stateName)
            {
                case SetAirConfigEvent.STATE:
                    _airStateManager.onStateEvent(e);
                    break;
                case ReloadEngineEvent.STATE:
                    onReloadEngineEvent(e as ReloadEngineEvent);
                    break;
                case LogoutEvent.STATE:
                    onLogoutEvent(e as LogoutEvent);
                    break;
                case EngineLoadedEvent.STATE:
                    onEngineLoadedEvent(e as EngineLoadedEvent);
                    break;
            }
        }

        private function internalUpdateState(newState:AppState):void
        {
            newState.freeze();

            AppState.update(newState);
        }

        private function onReloadEngineEvent(e:ReloadEngineEvent):void
        {
            MultiplayerState.destroyInstance();
            Flags.VALUES = {};

            target.dispatchEvent(new RemovePopupEvent());
            target.dispatchEvent(new InitialLoadingEvent(true));
        }

        private function onLogoutEvent(e:LogoutEvent):void
        {
            MultiplayerState.destroyInstance();
            Flags.VALUES = {};

            _gvars.userSession = "0";
            _gvars.playerUser = new User(true);
            _gvars.playerUser.loadFull(_gvars.userSession);
            _gvars.activeUser = _gvars.playerUser;

            target.dispatchEvent(new RemovePopupEvent());
            target.dispatchEvent(new ChangePanelEvent(Routes.PANEL_GAME_LOGIN));
        }

        private function onEngineLoadedEvent(e:EngineLoadedEvent):void
        {
            _gvars.removeSongFiles();
            MenuSongSelection.options.pageNumber = 0;
            MenuSongSelection.options.scroll_position = 0;
        }
    }
}
