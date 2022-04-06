package
{

    import arc.mp.MultiplayerState;
    import classes.Alert;
    import classes.Language;
    import classes.NoteskinsList;
    import classes.Playlist;
    import classes.Site;
    import classes.User;
    import classes.ui.BoxButton;
    import classes.ui.EpilepsyWarning;
    import classes.ui.PreloaderStatusBar;
    import com.greensock.TweenMax;
    import com.greensock.easing.SineInOut;
    import events.actions.menu.LanguageChangedEvent;
    import events.navigation.ChangePanelEvent;
    import flash.events.Event;
    import menu.DisplayLayer;
    import state.AppState;

    public class InitialLoading extends DisplayLayer
    {
        private var _lang:Language = Language.instance;
        private var _site:Site = Site.instance;
        private var _noteskinList:NoteskinsList = NoteskinsList.instance;

        private var _preloader:PreloaderStatusBar;
        private var _loadTimer:int = 0;
        private var _loadScripts:uint = 0;
        private var _loadTotal:uint;
        private var _userLoggedIn:Boolean;
        private var _retryLoadButton:BoxButton;
        private var _epilepsyWarning:EpilepsyWarning;

        public function InitialLoading(userLoggedIn:Boolean)
        {
            _userLoggedIn = userLoggedIn;

            //- Epilepsy Warning
            _epilepsyWarning = new EpilepsyWarning(10, Main.GAME_HEIGHT * 0.15, Main.GAME_WIDTH - 20);
            addChild(_epilepsyWarning);

            TweenMax.to(_epilepsyWarning, 1, {alpha: 0.6, ease: SineInOut, yoyo: true, repeat: -1});

            //- Build Preloader
            buildPreloader();

            //- Load Game Data
            loadGameData();
        }

        ///- Preloader
        public function buildPreloader():void
        {
            _preloader = new PreloaderStatusBar(8, Main.GAME_HEIGHT - 30, Main.GAME_WIDTH - 20, _userLoggedIn ? 0 : 0);

            addChild(_preloader);
            addEventListener(Event.ENTER_FRAME, updatePreloader);
        }

        private function updatePreloader(e:Event):void
        {
            // Update Text
            updateLoaderText();

            _loadTimer++;
            _preloader.bar.update(_loadScripts / _loadTotal);
            if (_loadTimer >= 300 && !_retryLoadButton)
            {
                _retryLoadButton = new BoxButton(this, Main.GAME_WIDTH - 85, _preloader.y - 35, 75, 25, "RELOAD", 12, onRetryClicked);
            }

            if (_preloader.bar.isComplete)
            {
                if (_retryLoadButton && contains(_retryLoadButton))
                {
                    removeChild(_retryLoadButton);
                    _retryLoadButton.dispose();
                }

                CONFIG::updater
                {
                    CONFIG::release
                    {
                        // Do Air Update Check
                        if (!Flags.VALUES[Flags.DID_AIR_UPDATE_CHECK])
                        {
                            Flags.VALUES[Flags.DID_AIR_UPDATE_CHECK] = true;
                            var airUpdateCheck:int = AirContext.serverVersionHigher(_site.data["game_r3air_version"]);
                            //addAlert(_site.data["game_r3air_version"] + " " + (airUpdateCheck == -1 ? "&gt;" : (airUpdateCheck == 1 ? "&lt;" : "==")) + " " + Constant.AIR_VERSION, 240);
                            if (airUpdateCheck == -1)
                            {
                                loadScripts = 0;
                                preloader.remove();
                                removeChild(loadStatus);
                                removeChild(epilepsyWarning);
                                removeEventListener(Event.ENTER_FRAME, updatePreloader);

                                // Switch to game
                                switchTo(GAME_UPDATE_PANEL);
                                return;
                            }
                            else
                            {
                                LocalStore.deleteVariable("air_update_checks");
                            }
                        }
                    }
                }

                _loadScripts = 0;
                _preloader.bar.remove();
                removeChild(_preloader);
                removeEventListener(Event.ENTER_FRAME, updatePreloader);

                _gvars.loadUserSongData();

                if (AppState.instance.auth.user.isGuest)
                    dispatchEvent(new ChangePanelEvent(Routes.PANEL_GAME_LOGIN));
                else
                {
                    if (contains(_epilepsyWarning))
                        removeChild(_epilepsyWarning);

                    dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
                }
            }
        }

        private function updateLoaderText():void
        {
            if (_preloader.text == null)
                return;

            var playlist:Playlist = AppState.instance.content.canonPlaylist;
            var updatedText:String = "";
            var user:User = AppState.instance.auth.user;

            updatedText += "Total: " + _loadScripts + " / " + _loadTotal + "\n";
            updatedText += "Playlist: " + getLoadText(playlist.isLoaded(), playlist.isError()) + "\n";
            updatedText += "User Data: " + getLoadText(user.isLoaded(), user.isError()) + "\n";
            updatedText += "Site Data: " + getLoadText(_site.isLoaded(), _site.isError());

            if (!_userLoggedIn)
            {
                updatedText += "\n" + "Noteskin Data: " + getLoadText(_noteskinList.isLoaded(), _noteskinList.isError());
                updatedText += "\n" + "Language Data: " + getLoadText(_lang.isLoaded(), _lang.isError())
            }

            _preloader.htmlText = updatedText;
        }

        ///- Game Data
        public function loadGameData():void
        {
            _loadTotal = (!_userLoggedIn) ? 5 : 3;

            _gvars.playerUser = new User(true);
            _gvars.playerUser.loadFull(_gvars.userSession, onUserLoggedIn);
            _gvars.activeUser.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
            _gvars.activeUser.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);

            _site.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
            _site.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
            AppState.instance.content.currentPlaylist.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
            _playlist.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
            _site.load();
            _playlist.load();

            if (!_userLoggedIn)
            {
                _lang.addEventListener(Constant.LOAD_COMPLETE, onLanguageDataLoaded);
                _lang.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                _noteskinList.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
                _noteskinList.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                _lang.load();
                _noteskinList.load();
            }

            // Update Text
            updateLoaderText();
        }

        private function onUserLoggedIn(username:String, password:String):void
        {
            MultiplayerState.instance.setUserCredentials(username, password);
        }

        private function gameScriptLoad(e:Event):void
        {
            e.target.removeEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
            e.target.removeEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
            _loadScripts++;

            // Update Text
            updateLoaderText();
        }

        private function gameScriptLoadError(e:Event):void
        {
            e.target.removeEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
            e.target.removeEventListener(Constant.LOAD_ERROR, gameScriptLoadError);

            // Update Text
            updateLoaderText();
        }

        private function getLoadText(isLoaded:Boolean, isError:Boolean):String
        {
            if (isError)
                return "<font color=\"#FFC4C4\">Error</font>";
            if (isLoaded)
                return "<font color=\"#C4FFCD\">Complete</font>";

            var cycle:int = 35;
            return "Loading." + ((_loadTimer % cycle > cycle / 3) ? "." : "") + ((_loadTimer % cycle > cycle / 1.5) ? "." : "");
        }

        private function onRetryClicked(e:Event):void
        {
            Alert.add(_lang.string("reload_scripts"));

            if (!_playlist.isLoaded())
            {
                _playlist.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
                _playlist.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                _playlist.load();
            }
            if (!_site.isLoaded())
            {
                _site.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
                _site.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                _site.load();
            }
            if (!_gvars.activeUser.isLoaded())
            {
                _gvars.activeUser.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
                _gvars.activeUser.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                _gvars.activeUser.loadFull(_gvars.userSession);
            }
            if (!_userLoggedIn)
            {
                if (!_noteskinList.isLoaded())
                {
                    _noteskinList.addEventListener(Constant.LOAD_COMPLETE, gameScriptLoad);
                    _noteskinList.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                    _noteskinList.load();
                }
                if (!_lang.isLoaded())
                {
                    _lang.addEventListener(Constant.LOAD_COMPLETE, onLanguageDataLoaded);
                    _lang.addEventListener(Constant.LOAD_ERROR, gameScriptLoadError);
                    _lang.load();
                }
            }

            // Update Text
            updateLoaderText();
        }

        private function onLanguageDataLoaded(e:Event):void
        {
            gameScriptLoad(e);
            dispatchEvent(new LanguageChangedEvent());
        }
    }
}
