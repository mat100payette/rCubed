package
{

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    public class PanelMediator extends EventDispatcher
    {
        public static const PANEL_GAME_UPDATE:String = "GameAirUpdatePanel";
        public static const PANEL_GAME_LOGIN:String = "GameLoginPanel";
        public static const PANEL_GAME_MENU:String = "GameMenuPanel";
        public static const PANEL_GAME_PLAY:String = "GamePlayPanel";

        public static const POPUP_HELP:String = "PopupHelp";
        public static const POPUP_OPTIONS:String = "PopupOptions";
        public static const POPUP_HIGHSCORES:String = "PopupHighscores";
        public static const POPUP_SONG_NOTES:String = "PopupSongNotes";
        public static const POPUP_QUEUE_MANAGER:String = "PopupQueueManager";
        public static const POPUP_CONTEXT_MENU:String = "PopupContextMenu";
        public static const POPUP_FILTER_MANAGER:String = "PopupFilterManager";
        public static const POPUP_SKILL_RANK_UPDATE:String = "PopupSkillRankUpdate";
        public static const POPUP_REPLAY_HISTORY:String = "PopupReplayHistory";

        private var _panelCallback:Function;
        private var _popupCallback:Function;

        public function PanelMediator(switchPanelCallback:Function, addPopupCallback:Function, target:IEventDispatcher = null)
        {
            super(target);

            _panelCallback = switchPanelCallback;
            _popupCallback = addPopupCallback

            addEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent);
            addEventListener(AddPopupEvent.EVENT_TYPE, onChangePanelEvent);
        }

        private function onChangePanelEvent(e:ChangePanelEvent):void
        {
            _panelCallback(e);
        }

        private function onAddPopupEvent(e:AddPopupEvent):void
        {
            _popupCallback(e);
        }

        public function dispose():void
        {
            removeEventListener(ChangePanelEvent.EVENT_TYPE, onChangePanelEvent);
            removeEventListener(ChangePanelEvent.EVENT_TYPE, onAddPopupEvent);
        }
    }
}
