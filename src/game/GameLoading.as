package game
{
    import classes.Language;
    import classes.Playlist;
    import classes.SongInfo;
    import classes.chart.Song;
    import classes.ui.BoxButton;
    import classes.ui.PreloaderStatusBar;
    import com.flashfla.utils.NumberUtil;
    import com.greensock.TweenLite;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextFormat;
    import menu.DisplayLayer;
    import events.navigation.ChangePanelEvent;

    public class GameLoading extends DisplayLayer
    {
        private var _textFormat:TextFormat = new TextFormat(Language.UNI_FONT_NAME, 16, 0xFFFFFF, true);

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _playlist:Playlist = Playlist.instance;

        private var _preloader:PreloaderStatusBar;
        private var _blackOverlay:Sprite;
        private var _loadTimer:int = 0;
        private var _cancelLoadButton:BoxButton;

        private var _song:Song;
        private var _songNameHtml:String = "";

        public function GameLoading()
        {
            init();
        }

        public function init():void
        {
            _gvars.songRestarts = 0;
            //- Set Active Song
            if (_gvars.songQueue.length > 0)
            {
                var songInfo:SongInfo = _gvars.songQueue[0];
                _gvars.songQueue.shift();

                _song = _gvars.getSongFile(songInfo, _gvars.options.loadPreview);
                _gvars.options.song = _song;
            }
            else if (_gvars.options.song)
                _song = _gvars.options.song;
            else
            { // No songs in queue? Something went wrong...
                dispatchEvent(new ChangePanelEvent(Routes.PANEL_GAME_MENU));
            }
            if (_song && _song.isLoaded)
                dispatchEvent(new ChangePanelEvent(Routes.GAME_PLAY));
        }

        override public function stageAdd():void
        {
            _songNameHtml = _lang.wrapFont(_song.songInfo.name ? _song.songInfo.name : "Invalid Song / Replay");

            //- Preloader Display
            _preloader = new PreloaderStatusBar(10, Main.GAME_HEIGHT - 30, Main.GAME_WIDTH - 20, 6);
            _preloader.text.defaultTextFormat = _textFormat;
            _preloader.htmlText = _songNameHtml;

            addChild(_preloader);

            //- Frame Listener
            addEventListener(Event.ENTER_FRAME, updatePreloader);
        }

        override public function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, updatePreloader);

            if (_cancelLoadButton)
                _cancelLoadButton.dispose();

            if (_preloader)
                _preloader.removeEventListener(Event.REMOVED_FROM_STAGE, preloaderRemoved);
        }

        ///- PreloaderHandlers
        private function updatePreloader(e:Event):void
        {
            _loadTimer++;

            // TODO: use localized strings here
            var preloaderHtmlText:String = "";
            if (_song.songInfo.name)
            {
                preloaderHtmlText += _song.songInfo.name + " - " + _song.progress + "%  --- ";

                if (_song.bytesTotal > 0)
                    preloaderHtmlText += "(" + NumberUtil.bytesToString(_song.bytesLoaded) + " / " + NumberUtil.bytesToString(_song.bytesTotal) + ")";
                else
                    preloaderHtmlText += "Connecting..."

                if (_song.loadFail)
                    preloaderHtmlText += " --- <font color=\"#FFC4C4\">[Loading Failed]</font>";
            }
            else
                preloaderHtmlText += _songNameHtml;

            _preloader.htmlText = preloaderHtmlText
            _preloader.bar.update(_song.progress / 100);

            if ((_loadTimer >= 60 || _song.loadFail) && !_cancelLoadButton)
            {
                _cancelLoadButton = new BoxButton(this, Main.GAME_WIDTH - 85, _preloader.y - 35, 75, 25, "Cancel", 12, e_cancelClick);
            }

            if (_song.loadFail)
            {
                // Loading Failed :/
                _gvars.removeSongFile(_song);
                if (_cancelLoadButton)
                    _cancelLoadButton.text = "Return";
                removeEventListener(Event.ENTER_FRAME, updatePreloader);
            }

            if (_preloader.bar.isComplete && _song.isLoaded)
            {
                removeEventListener(Event.ENTER_FRAME, updatePreloader);
                _preloader.bar.addEventListener(Event.REMOVED_FROM_STAGE, preloaderRemoved);
                _preloader.bar.remove();

                _blackOverlay = new Sprite();
                _blackOverlay.alpha = 0;
                _blackOverlay.graphics.beginFill(0x000000);
                _blackOverlay.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
                addChild(_blackOverlay);

                TweenLite.to(_blackOverlay, 0.5, {alpha: 1});
            }
        }

        private function e_cancelClick(e:Event):void
        {
            _gvars.removeSongFile(_song);

            removeEventListener(Event.ENTER_FRAME, updatePreloader);
            dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
        }

        private function preloaderRemoved(e:Event):void
        {
            _preloader.bar.removeEventListener(Event.REMOVED_FROM_STAGE, preloaderRemoved);
            dispatchEvent(new ChangePanelEvent(Routes.GAME_PLAY));
        }
    }
}
