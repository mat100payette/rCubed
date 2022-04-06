package state_management
{
    import flash.events.IEventDispatcher;
    import state.AppState;
    import events.actions.gameplay.ClearSongQueueEvent;

    public class GameplayController extends Controller
    {
        public function GameplayController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);

            addListeners();
        }

        private function addListeners():void
        {
            target.addEventListener(ClearSongQueueEvent.EVENT_TYPE, clearSongQueue);
        }

        private function clearSongQueue():void
        {
            var newState:AppState = AppState.clone(owner);
            newState.gameplay.songQueue = [];
            newState.gameplay.songQueueIndex = 0;

            updateState(newState);
        }
    }
}
