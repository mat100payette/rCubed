package menu
{
    import assets.menu.ScrollBackground;
    import assets.menu.ScrollDragger;
    import assets.menu.SongSelectionBackground;
    import by.blooddy.crypto.MD5;
    import classes.Language;
    import classes.Playlist;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.ScrollBar;
    import classes.ui.ScrollPane;
    import classes.ui.Text;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import events.navigation.ChangePanelEvent;

    public class MenuTokens extends DisplayLayer
    {
        private var _lang:Language = Language.instance;

        private var _background:SongSelectionBackground;
        private var _scrollbar:ScrollBar;
        private var _pane:ScrollPane;

        private var _normalTokenButton:BoxButton;
        private var _skillTokenButton:BoxButton;
        private var _hideCompleteCheck:BoxCheck;

        private var _options:Object;

        private static var _loadedTokenImages:Object = {};
        private static var _loadQueue:Array = [];
        private static var _activeDownload:Object = null;

        public function MenuTokens()
        {
            super();
            init();
        }

        public function init():void
        {
            //- Setup Settings
            _options = {};
            _options.active_type = "ski";
            _options.filter_complete = false;

            //- Add Background
            _background = new SongSelectionBackground();
            _background.x = 145;
            _background.y = 52;
            _background.pageBackground.visible = false;
            _background.visible = LocalOptions.getVariable("menu_show_song_selection_background", true);
            this.addChild(_background);

            //- Add ScrollPane
            _pane = new ScrollPane(this, 155, 64, 578, 358);
            var border:Sprite = new Sprite();
            border.graphics.lineStyle(1, 0xFFFFFF, 1, true);
            border.graphics.moveTo(0.3, -0.5);
            border.graphics.lineTo(577, -0.5);
            border.graphics.moveTo(0.3, 358.5);
            border.graphics.lineTo(577, 358.5);
            border.alpha = 0.35;
            _pane.addChild(border);

            //- Add ScrollBar
            _scrollbar = new ScrollBar(this, 744, 81, 21, 325, new ScrollDragger(), new ScrollBackground());

            // Menu Left
            _normalTokenButton = new BoxButton(this, 5, 130, 124, 29, _lang.string("menu_tokens_normal"), 12, onNormalSelect);

            _skillTokenButton = new BoxButton(this, 5, 164, 124, 29, _lang.string("menu_tokens_skill"), 12, onSkillSelect);
            _skillTokenButton.active = true;

            var hideLabel:Text = new Text(this, 10, 230, _lang.string("menu_tokens_hide_complete"));
            _hideCompleteCheck = new BoxCheck(this, 106, 233, hideCompleteClick);

            //- Add Content
            buildTokens();
        }

        private function hideCompleteClick(e:Event):void
        {
            _options.filter_complete = !_options.filter_complete;
            _hideCompleteCheck.checked = _options.filter_complete;
            buildTokens();
        }

        private function onNormalSelect(e:Event):void
        {
            if (_options.active_type != "has")
            {
                _options.active_type = "has";
                _normalTokenButton.active = true;
                _skillTokenButton.active = false;
                buildTokens();
            }
        }

        private function onSkillSelect(e:Event):void
        {
            if (_options.active_type != "ski")
            {
                _options.active_type = "ski";
                _normalTokenButton.active = false;
                _skillTokenButton.active = true;
                buildTokens();
            }
        }

        override public function dispose():void
        {
            if (_pane)
            {
                _pane.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false);
                _pane.dispose();
                removeChild(_pane);

                _pane = null;
            }

            _normalTokenButton.dispose();
            _skillTokenButton.dispose();

            //- Remove Listeners
            if (stage)
            {
                _scrollbar.removeEventListener(Event.CHANGE, scrollBarMoved, false);
            }

            super.dispose();
        }

        override public function stageAdd():void
        {
            //- Add Listeners
            if (stage)
            {
                _scrollbar.addEventListener(Event.CHANGE, scrollBarMoved, false, 0, false);
                _pane.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false, 0, false);
            }
        }

        public function buildTokens():void
        {
            //- Clear out old MC in content pane
            _scrollbar.reset();
            _pane.clear();
            _loadQueue = [];

            var yOffset:int = 0;
            var sX:int = 0;
            var token:TokenItem;

            for each (var item:Object in _gvars.TOKENS_TYPE[_options.active_type])
            {
                if (_options.filter_complete && item["unlock"])
                    continue;

                token = new TokenItem(item);
                token.y = yOffset;
                token.addEventListener(MouseEvent.CLICK, e_tokenClick);
                _pane.content.addChild(token);
                yOffset += token.height + 5;
                sX += 1;

                addTokenImageLoader(item, token);
            }

            downloadTokenImage();

            _options.totalItems = sX;
            _pane.scrollTo(_scrollbar.scroll, false);
            _scrollbar.draggerVisibility = (yOffset > _pane.height);
        }

        private function e_tokenClick(e:Event):void
        {
            var token_songs:Array = [];

            for each (var level:int in(e.target as TokenItem).token_levels)
            {
                if (level > 0)
                {
                    var songData:Object = _playlist.getSongInfo(level);
                    if (!songData.hasOwnProperty("error"))
                    {
                        token_songs.push(songData);
                    }
                }
            }

            if (token_songs.length <= 0)
                return;

            _gvars.songQueue = token_songs;
            MenuSongSelection.options.queuePlaylist = _gvars.songQueue;

            dispatchEvent(new ChangePanelEvent(Routes.PANEL_SONGSELECTION));
            MenuSongSelection.options.infoTab = MenuSongSelection.TAB_QUEUE;
            var panel:MenuSongSelection = ((_gvars.gameMain.navigator.activePanel as MainMenu).currentPanel as MenuSongSelection);
            panel.swapToQueue();
        }

        private function addTokenImageLoader(token_info:Object, token_ui:TokenItem):void
        {
            var imageHash:String = MD5.hash(token_info["picture"]);

            if (_loadedTokenImages[imageHash] != null)
            {
                token_ui.addTokenImage(_loadedTokenImages[imageHash] as Bitmap, false);
                return;
            }

            // Load Image
            _loadQueue.push({"hash": imageHash, "url": token_info["picture"], "ui": token_ui});
        }

        private function downloadTokenImage():void
        {
            if (_loadQueue.length <= 0 || _activeDownload != null)
                return;

            _activeDownload = _loadQueue.shift();

            // Load Avatar
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, downloadTokenImageComplete);
            loader.load(new URLRequest(_activeDownload["url"]));
        }

        private function downloadTokenImageComplete(e:Event):void
        {
            _loadedTokenImages[_activeDownload["hash"]] = e.target.content as Bitmap;

            if ((_activeDownload["ui"] as TokenItem).parent != null)
                (_activeDownload["ui"] as TokenItem).addTokenImage(e.target.content as Bitmap);

            _activeDownload = null;

            downloadTokenImage();
        }

        private function mouseWheelMoved(e:MouseEvent):void
        {
            var dist:Number = _scrollbar.scroll + (_pane.scrollFactorVertical / 2) * (e.delta > 0 ? -1 : 1);
            _pane.scrollTo(dist);
            _scrollbar.scrollTo(dist);
        }

        private function scrollBarMoved(e:Event):void
        {
            _pane.scrollTo(e.target.scroll, false);
        }
    }
}
