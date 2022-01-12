package
{

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import popups.events.RemovePopupEvent;
    import popups.events.AddPopupEvent;
    import flash.concurrent.Mutex;

    public class PanelMediator extends EventDispatcher
    {
        public static const PANEL_MAIN:String = "MainPanel";
        public static const PANEL_GAME_UPDATE:String = "GameAirUpdatePanel";
        public static const PANEL_GAME_LOGIN:String = "GameLoginPanel";
        public static const PANEL_GAME_MENU:String = "GameMenuPanel";
        public static const PANEL_GAME_PLAY:String = "GamePlayPanel";

        public static const GAME_LOADING:String = "GameLoading";
        public static const GAME_PLAY:String = "GamePlay";
        public static const GAME_REPLAY:String = "GameReplay";
        public static const GAME_RESULTS:String = "GameResults";

        public static const REMOVE_POPUP:String = "RemovePopup";
        public static const POPUP_HELP:String = "PopupHelp";
        public static const POPUP_OPTIONS:String = "PopupOptions";
        public static const POPUP_HIGHSCORES:String = "PopupHighscores";
        public static const POPUP_SONG_NOTES:String = "PopupSongNotes";
        public static const POPUP_QUEUE_MANAGER:String = "PopupQueueManager";
        public static const POPUP_CONTEXT_MENU:String = "PopupContextMenu";
        public static const POPUP_FILTER_MANAGER:String = "PopupFilterManager";
        public static const POPUP_SKILL_RANK_UPDATE:String = "PopupSkillRankUpdate";
        public static const POPUP_REPLAY_HISTORY:String = "PopupReplayHistory";

        private var _target:IEventDispatcher;

        private var _panelCallback:Function;
        private var _addPopupCallback:Function;
        private var _removePopupCallback:Function;

        private var _topPopupLayer:uint = 1;
        private var _layerMutex:Mutex = new Mutex();

        public function PanelMediator(target:IEventDispatcher = null, switchPanelCallback:Function = null, addPopupCallback:Function = null, removePopupCallback:Function = null)
        {
            super(target);

            _panelCallback = switchPanelCallback;
            _addPopupCallback = addPopupCallback;
            _removePopupCallback = removePopupCallback;
            _target = target;

            _target.addEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent);
            _target.addEventListener(AddPopupEvent.EVENT_TYPE, onAddPopupEvent);
            _target.addEventListener(RemovePopupEvent.EVENT_TYPE, onRemovePopupEvent);
        }

        private function onChangePanelEvent(e:ChangePanelEvent):void
        {
            _panelCallback(e);
        }

        private function onAddPopupEvent(e:AddPopupEvent):void
        {
            if (!_layerMutex.tryLock())
                e.preventDefault();

            try
            {
                _addPopupCallback(e);
                _topPopupLayer++;
            }
            finally
            {
                _layerMutex.unlock();
            }
        }

        private function onRemovePopupEvent(e:RemovePopupEvent):void
        {
            if (!_layerMutex.tryLock())
                e.preventDefault();

            try
            {
                if (_topPopupLayer == 1)
                    return;

                _removePopupCallback(e);
                _topPopupLayer--;
            }
            finally
            {
                _layerMutex.unlock();
            }
        }

        public function get topPopupLayer():uint
        {
            return _topPopupLayer;
        }

        public function dispose():void
        {
            _target.removeEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent);
            _target.removeEventListener(AddPopupEvent.EVENT_TYPE, onAddPopupEvent);
            _target.removeEventListener(RemovePopupEvent.EVENT_TYPE, onRemovePopupEvent);
        }
    }
}
