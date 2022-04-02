package popups.replays
{

    import classes.Alert;
    import classes.Language;
    import classes.replay.Replay;
    import classes.ui.BoxButton;
    import classes.ui.Text;
    import com.flashfla.net.WebRequest;
    import com.flashfla.utils.SpriteUtil;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFormatAlign;
    import state.AppState;

    public class ReplayHistoryTabOnline extends ReplayHistoryTabBase
    {
        private var initialLoad:Boolean = false;
        private var replays:Vector.<Replay>;

        private var _lang:Language = Language.instance;

        private var _http:WebRequest;
        private var _btnRefresh:BoxButton;

        private var _uiLock:Sprite;
        private var _uiLockBG:Bitmap;
        private var _loadingCancelButton:BoxButton;

        public function ReplayHistoryTabOnline(replayWindow:ReplayHistoryWindow):void
        {
            super(replayWindow);

            // UI Lock
            _uiLock = new Sprite();
            var lockUIText:Text = new Text(_uiLock, 0, 200, _lang.string("replay_loading_online"), 24);
            lockUIText.setAreaParams(780, 30, TextFormatAlign.CENTER);

            _loadingCancelButton = new BoxButton(_uiLock, 390 - 40, 440, 80, 30, _lang.string("menu_cancel"), 12, cancelWebLoading);
        }

        override public function get name():String
        {
            return "online";
        }

        override public function openTab():void
        {
            // Add UI Elements
            if (!_btnRefresh)
            {
                _btnRefresh = new BoxButton(null, 5, Main.GAME_HEIGHT - 35, 162, 29, _lang.string("menu_refresh"), 12, loadOnlineReplays);
            }
            parent.addChild(_btnRefresh);

            // Initial Load
            if (!initialLoad)
            {
                loadOnlineReplays();
                initialLoad = true;
            }
        }

        override public function closeTab():void
        {
            parent.removeChild(_btnRefresh);
        }

        override public function setValues():void
        {
            var renderList:Array = [];
            for each (var r:Replay in replays)
            {
                if (r.songInfo == null)
                    continue;

                if (parent.searchText.length >= 1 && r.songInfo.name.toLowerCase().indexOf(parent.searchText) == -1)
                    continue;

                renderList[renderList.length] = r;
            }
            parent.pane.setRenderList(renderList);
            parent.updateScrollPane();
        }

        private function loadOnlineReplays(e:MouseEvent = null):void
        {
            Logger.info(this, "Loading Online Replays");
            lockUI();

            // TODO: Put in state maybe
            replays = new <Replay>[];

            _http = new WebRequest(Constant.SITE_REPLAYS_URL, onReplaysFetched, onReplaysFetchError);
            _http.load({"session": AppState.instance.auth.userSession});
        }

        private function cancelWebLoading(e:MouseEvent):void
        {
            if (e.target == _loadingCancelButton)
                webLoadComplete(true);
        }

        private function onReplaysFetched(e:Event):void
        {
            var data:String = e.target.data;

            try
            {
                var json:Object = JSON.parse(data);
                for each (var replay:Object in json)
                {
                    var r:Replay = new Replay(replay["replayid"]);
                    r.parseReplay(replay, false);
                    r.loadSongInfo();
                    replays[replays.length] = r;
                }
            }
            catch (error:Error)
            {
                // TODO: Add localised string
                Alert.add("Error parsing online replays", 120, Alert.RED);
            }

            webLoadComplete();
        }

        private function onReplaysFetchError(e:Event):void
        {
            Alert.add(_lang.string("replay_error_retrieving_online"), 120, Alert.RED);
            webLoadComplete();
        }

        private function webLoadComplete(cancelled:Boolean = false):void
        {
            if (cancelled)
                _http.loader.close();

            _http = null;

            unlockUI();
            setValues();
        }

        private function lockUI():void
        {
            // TODO: Check if this stage actually works for this
            _uiLockBG = SpriteUtil.getBitmapSprite(parent.stage, 0.3);
            _uiLock.addChildAt(_uiLockBG, 0);
            parent.addChild(_uiLock);
        }

        private function unlockUI():void
        {
            if (!parent.contains(_uiLock))
                return;

            _uiLock.removeChildAt(0);
            _uiLockBG = null;
            parent.removeChild(_uiLock);
        }
    }
}
