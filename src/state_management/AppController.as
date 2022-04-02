package state_management
{

    import arc.mp.MultiplayerState;
    import events.navigation.InitialLoadingEvent;
    import events.navigation.popups.RemovePopupEvent;
    import events.state.EngineLoadedEvent;
    import events.state.ReloadEngineEvent;
    import events.state.StateEvent;
    import events.state.interfaces.IAirEvent;
    import events.state.interfaces.IAuthEvent;
    import events.state.interfaces.IContentEvent;
    import events.state.interfaces.IMenuEvent;
    import flash.display.Stage;
    import flash.events.IEventDispatcher;
    import menu.MenuSongSelection;
    import singletons.StreamWebsocket;
    import state.AppState;
    import singletons.MenuMusicPlayer;

    public class AppController extends Controller
    {
        private var _airController:AirController;
        private var _menuController:MenuController;
        private var _contentController:ContentController;
        private var _authController:AuthController;
        private var _gameplayController:GameplayController;

        public function AppController(target:IEventDispatcher, stage:Stage)
        {
            super(target, this, internalUpdateState);

            target.addEventListener(StateEvent.EVENT_TYPE, onStateEvent);

            _airController = new AirController(target, this, internalUpdateState, stage);
            _menuController = new MenuController(target, this, internalUpdateState);
            _contentController = new ContentController(target, this, internalUpdateState);

            var streamWebsocket:StreamWebsocket = new StreamWebsocket(_airController);
            var menuMusicPlayer:MenuMusicPlayer = new MenuMusicPlayer(_menuController);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            if (e is IAirEvent)
            {
                _airController.onStateEvent(e);
                return;
            }
            else if (e is IMenuEvent)
            {
                _menuController.onStateEvent(e);
                return;
            }
            else if (e is IContentEvent)
            {
                _menuController.onStateEvent(e);
                return;
            }
            else if (e is IAuthEvent)
            {
                _menuController.onStateEvent(e);
                return;
            }

            var stateName:String = e.stateName;

            switch (stateName)
            {
                case ReloadEngineEvent.STATE:
                    onReloadEngineEvent(e as ReloadEngineEvent);
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

        private function onEngineLoadedEvent(e:EngineLoadedEvent):void
        {
            //_gvars.removeSongFiles();
            MenuSongSelection.options.pageNumber = 0;
            MenuSongSelection.options.scroll_position = 0;
        }
    }
}
