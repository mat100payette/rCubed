package
{

    import classes.ui.PreloaderStatusBar;
    import menu.DisplayLayer;
    import flash.events.Event;
    import classes.ui.BoxButton;
    import classes.User;
    import arc.mp.MultiplayerState;
    import classes.Language;
    import classes.Site;
    import classes.Playlist;
    import classes.NoteskinsList;
    import classes.ui.EpilepsyWarning;
    import com.greensock.TweenMax;
    import com.greensock.easing.SineInOut;
    import classes.Alert;
    import events.navigation.ChangePanelEvent;
    import events.state.LanguageChangedEvent;

    public class InitialLoading extends DisplayLayer
    {
        private var _lang:Language = Language.instance;
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _site:Site = Site.instance;
        private var _playlist:Playlist = Playlist.instance;
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

                _playlist.updateSongAccess();
                _playlist.updatePublicSongsCount();
                _gvars.loadUserSongData();

                if (_gvars.activeUser.isGuest)
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
            if (_preloader.text != null)
            {
                var updatedText:String = "";

                updatedText += "Total: " + _loadScripts + " / " + _loadTotal + "\n";
                updatedText += "Playlist: " + getLoadText(_playlist.isLoaded(), _playlist.isError()) + "\n";
                updatedText += "User Data: " + getLoadText(_gvars.playerUser.isLoaded(), _gvars.playerUser.isError()) + "\n";
                updatedText += "Site Data: " + getLoadText(_site.isLoaded(), _site.isError());

                if (!_userLoggedIn)
                {
                    updatedText += "\n" + "Noteskin Data: " + getLoadText(_noteskinList.isLoaded(), _noteskinList.isError());
                    updatedText += "\n" + "Language Data: " + getLoadText(_lang.isLoaded(), _lang.isError())
                }

                _preloader.htmlText = updatedText;
            }
        }

        ///- Game Data
        public function loadGameData():void
        {
            _loadTotal = (!_userLoggedIn) ? 5 : 3;

            _gvars.playerUser = new User(true);
            _gvars.playerUser.loadFull(_gvars.userSession, onUserLoggedIn);
            _gvars.activeUser = _gvars.playerUser;
            _gvars.activeUser.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _gvars.activeUser.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);

            _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _site.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            _playlist.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _site.load();
            _playlist.load();

            if (!_userLoggedIn)
            {
                _lang.addEventListener(GlobalVariables.LOAD_COMPLETE, onLanguageDataLoaded);
                _lang.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _noteskinList.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _noteskinList.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
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
            e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
            _loadScripts++;

            // Update Text
            updateLoaderText();
        }

        private function gameScriptLoadError(e:Event):void
        {
            e.target.removeEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
            e.target.removeEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);

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
                _playlist.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _playlist.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _playlist.load();
            }
            if (!_site.isLoaded())
            {
                _site.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _site.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _site.load();
            }
            if (!_gvars.activeUser.isLoaded())
            {
                _gvars.activeUser.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                _gvars.activeUser.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                _gvars.activeUser.loadFull(_gvars.userSession);
            }
            if (!_userLoggedIn)
            {
                if (!_noteskinList.isLoaded())
                {
                    _noteskinList.addEventListener(GlobalVariables.LOAD_COMPLETE, gameScriptLoad);
                    _noteskinList.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
                    _noteskinList.load();
                }
                if (!_lang.isLoaded())
                {
                    _lang.addEventListener(GlobalVariables.LOAD_COMPLETE, onLanguageDataLoaded);
                    _lang.addEventListener(GlobalVariables.LOAD_ERROR, gameScriptLoadError);
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
