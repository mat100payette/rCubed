package state_management
{

    import flash.display.Stage;
    import flash.events.IEventDispatcher;
    import singletons.MenuMusicPlayer;
    import singletons.StreamWebsocket;
    import state.AppState;

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

            _airController = new AirController(target, this, internalUpdateState, stage);
            _menuController = new MenuController(target, this, internalUpdateState);
            _contentController = new ContentController(target, this, internalUpdateState);
            _authController = new AuthController(target, this, internalUpdateState);
            _gameplayController = new GameplayController(target, this, internalUpdateState);

            var streamWebsocket:StreamWebsocket = new StreamWebsocket(_airController);
            var menuMusicPlayer:MenuMusicPlayer = new MenuMusicPlayer(_menuController);
        }

        private function internalUpdateState(newState:AppState):void
        {
            newState.freeze();
            AppState.update(newState);
        }
    }
}
