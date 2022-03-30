package
{
    import classes.Alert;
    import classes.Language;
    import classes.Playlist;
    import classes.ui.Box;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.BoxText;
    import classes.ui.SimpleBoxButton;
    import classes.ui.Text;
    import com.flashfla.utils.Crypt;
    import com.flashfla.utils.SpriteUtil;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.navigateToURL;
    import flash.ui.Keyboard;
    import menu.DisplayLayer;
    import events.navigation.ChangePanelEvent;
    import events.navigation.InitialLoadingEvent;

    public class LoginMenu extends DisplayLayer
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _loader:URLLoader;

        private const STORED_NONE:int = 0;
        private const STORED_PASSWORD:int = 1;
        private const STORED_SESSION:int = 2;

        private var _savedInfos:Object;

        private var _box:Box;
        private var _panelLogin:Sprite;
        private var _panelSession:Sprite;

        private var _inputUser:BoxText;
        private var _inputPass:BoxText;
        private var _saveDetails:BoxCheck;

        private var _isLoading:Boolean = false;

        public function LoginMenu()
        {
            _savedInfos = loadLoginDetails();
        }

        override public function dispose():void
        {
            if (stage)
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, loginKeyDown);
            _saveDetails.dispose();
            super.dispose();
        }

        override public function stageAdd():void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, loginKeyDown);

            //- BG
            _box = new Box(this, (Main.GAME_WIDTH - 300) / 2, (Main.GAME_HEIGHT - 140) / 2, false);
            _box.setSize(300, 140);

            // Register Button
            var register_online_btn:BoxButton = new BoxButton(this, _box.x, _box.y + _box.height + 10, 300, 30, _lang.string("register_online"), 12, registerOnline);

            /// 
            _panelSession = new Sprite();

            var draw_pane:Sprite = new Sprite();
            draw_pane.graphics.lineStyle(1, 0xffffff, 0);

            draw_pane.graphics.beginFill(0xffffff, 0.1);
            draw_pane.graphics.drawRect(6, 6, 87, 87);
            draw_pane.graphics.endFill();

            draw_pane.graphics.lineStyle(1, 0xffffff, 0.3);
            draw_pane.graphics.moveTo(100, 50);
            draw_pane.graphics.lineTo(265, 50);
            draw_pane.graphics.moveTo(1, 98);
            draw_pane.graphics.lineTo(_box.width, 98);
            _panelSession.addChild(draw_pane);

            if (_savedInfos.avatar != null)
            {
                try
                {
                    var avatarLoader:Loader = new Loader();
                    avatarLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, displayAvatarComplete);
                    avatarLoader.loadBytes(_savedInfos.avatar, AirContext.getLoaderContext());

                    function displayAvatarComplete(e:Event):void
                    {
                        avatarLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, displayAvatarComplete);

                        var userAvatar:DisplayObject = avatarLoader;
                        if (userAvatar && userAvatar.height > 0 && userAvatar.width > 0)
                        {
                            SpriteUtil.scaleTo(userAvatar, 77, 77);
                            userAvatar.x = 11 + ((77 - userAvatar.width) / 2);
                            userAvatar.y = 11 + ((77 - userAvatar.height) / 2);
                            _panelSession.addChildAt(userAvatar, 1);
                        }
                    }
                }
                catch (e:Error)
                {

                }
            }

            // Username
            var session_label_user:Text = new Text(_panelSession, 100, 30, _lang.string("login_continue_as"));
            var session_txt_username:Text = new Text(_panelSession, 100, 50, _savedInfos.username ? _savedInfos.username : "----", 16, "#F3FAFF");

            //- Buttons
            var session_continueAsbtn:SimpleBoxButton = new SimpleBoxButton(_box.width, 98);
            session_continueAsbtn.addEventListener(MouseEvent.CLICK, attemptLoginSession);
            _panelSession.addChild(session_continueAsbtn);

            var session_guestbtn:BoxButton = new BoxButton(_panelSession, 6, _box.height - 36, 120, 30, _lang.string("login_guest"), 12, playAsGuest);
            var session_changeusertbtn:BoxButton = new BoxButton(_panelSession, _box.width - 126, _box.height - 36, 120, 30, _lang.string("login_change_user"), 12, changeUserEvent);

            /// Login Screen
            _panelLogin = new Sprite();

            //- Text
            // Username
            var txt_user:Text = new Text(_panelLogin, 5, 5, _lang.string("login_name"));
            _inputUser = new BoxText(_panelLogin, 5, 25, 290, 20);

            // Password
            var txt_pass:Text = new Text(_panelLogin, 5, 55, _lang.string("login_pass"));
            _inputPass = new BoxText(_panelLogin, 5, 75, 290, 20);
            _inputPass.displayAsPassword = true;

            // Save Details
            _saveDetails = new BoxCheck(_panelLogin, 92, 113);
            var txt_save:Text = new Text(_panelLogin, 110, 111, _lang.string("login_remember"));

            //- Buttons
            var login_guestbtn:BoxButton = new BoxButton(_panelLogin, 6, _box.height - 36, 75, 30, _lang.string("login_guest"), 12, playAsGuest);
            var loginbtn:BoxButton = new BoxButton(_panelLogin, _box.width - 81, _box.height - 36, 75, 30, _lang.string("login_text"), 12, attemptLogin);

            // Set Values
            if (_savedInfos.state == STORED_SESSION)
            {

            }
            else if (_savedInfos.state == STORED_PASSWORD)
            {
                _inputUser.text = _savedInfos.username;
                _inputPass.text = _savedInfos.password;
                _saveDetails.checked = true;
            }

            // Set Focus when at textboxes
            if (_savedInfos.state == STORED_SESSION)
            {
                _box.addChild(_panelSession);
            }
            else if (_savedInfos.state == STORED_NONE || _savedInfos.state == STORED_PASSWORD)
            {
                _box.addChild(_panelLogin);
                stage.focus = _inputUser.field;
                _inputUser.field.setSelection(_inputUser.text.length, _inputUser.text.length);
            }
        }


        private function get rememberPassword():Boolean
        {
            return _saveDetails.checked;
        }

        public function playAsGuest(e:Event = null):void
        {
            dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
        }

        public function registerOnline(e:Event = null):void
        {
            navigateToURL(new URLRequest(Constant.USER_REGISTER_URL), "_blank");
        }

        private function changeUserEvent(e:Event):void
        {
            saveLoginDetails(false);

            if (_box.contains(_panelSession))
                _box.removeChild(_panelSession);

            _box.addChild(_panelLogin);

            if (_savedInfos.username != null)
                _inputUser.text = _savedInfos.username;

            stage.focus = _inputUser.field;
            _inputUser.field.setSelection(_inputUser.text.length, _inputUser.text.length);
        }

        public function attemptLoginSession(e:Event = null):void
        {
            if (_isLoading)
                return;

            _loader = new URLLoader();
            addLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.USER_LOGIN_URL);
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.username = _savedInfos.username;
            requestVars.token = _savedInfos.token;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);

            Logger.info(this, "Attempting session login for: " + requestVars.username.substr(0, 4) + "..." + requestVars.token.substr(-4));

            _isLoading = true;
        }

        public function attemptLogin(e:Event = null):void
        {
            if (_isLoading)
                return;

            _loader = new URLLoader();
            addLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.USER_LOGIN_URL);
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.username = _inputUser.text;
            requestVars.password = _inputPass.text;
            requestVars.rememberPassword = (rememberPassword ? "true" : "false");
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);

            Logger.info(this, "Attempting login for: " + requestVars.username.substr(0, 4) + "...");

            setFields(true);
        }

        private function loginKeyDown(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.ENTER)
            {
                // Session Screen
                if (_panelSession.stage != null)
                {
                    attemptLoginSession(event);
                }
                // Login Screen
                else
                {
                    if (_inputUser.text.length > 0)
                        attemptLogin(event);
                    else
                        playAsGuest(event);
                }
            }
        }

        private function loginLoadComplete(e:Event):void
        {
            removeLoaderListeners();

            // Parse Response
            var _data:Object;
            var siteDataString:String = e.target.data;
            try
            {
                _data = JSON.parse(siteDataString);
            }
            catch (err:Error)
            {
                Logger.error(this, "Parse Failure: " + Logger.exception_error(err));
                Logger.error(this, "Wrote invalid response data to log folder. [logs/login.txt]");
                AirContext.writeTextFile(AirContext.getAppFile("logs/login.txt"), siteDataString);

                Alert.add(_lang.string("login_connection_error"));
                setFields(false);
                return;
            }

            // Has Response
            if (_data.result == 4)
            {
                Logger.error(this, "Invalid User/Session");
                _isLoading = false;
                Alert.add(_lang.string("login_invalid_session"));
                changeUserEvent(e);
            }
            else if (_data.result >= 1 && _data.result <= 3)
            {
                Logger.info(this, "Login Success!");
                if (_data.result == 1 || _data.result == 2)
                    saveLoginDetails(this.rememberPassword, _data.session);
                _gvars.userSession = _data.session;
                // TODO: Event to reset load status on InitialLoading
                //_gvars.gameMain.loadComplete = false;

                dispatchEvent(new InitialLoadingEvent(true));
            }
            else
            {
                setFields(false, true);
            }
        }

        private function loginLoadError(e:ErrorEvent):void
        {
            Logger.error(this, "Login Load Error: " + Logger.event_error(e));
            Alert.add(_lang.string("login_connection_error"));
            removeLoaderListeners();
            setFields(false);
        }

        private function addLoaderListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, loginLoadComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, loginLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loginLoadError);
        }

        private function removeLoaderListeners():void
        {
            _loader.removeEventListener(Event.COMPLETE, loginLoadComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, loginLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loginLoadError);
        }

        private function setFields(val:Boolean, isError:Boolean = false):void
        {
            if (val)
            {
                _isLoading = true;
                _inputUser.selectable = false;
                _inputPass.selectable = false;
                _inputUser.textColor = 0xD6D6D6;
                _inputPass.textColor = 0xD6D6D6;
                _inputPass.color = 0xD6D6D6;
                _inputPass.borderColor = 0xFFFFFF;
            }
            else
            {
                _isLoading = false;
                _inputUser.selectable = true;
                _inputPass.selectable = true;
                _inputUser.textColor = 0xFFFFFF;
                _inputPass.textColor = 0xFFFFFF;
                _inputPass.color = 0xFFFFFF;
                _inputPass.borderColor = 0xFFFFFF;
            }

            if (isError)
            {
                _inputPass.text = "";
                _inputPass.textColor = 0xFFDBDB;
                _inputPass.color = 0xFF0000;
                _inputPass.borderColor = 0xFF0000;
            }
        }

        public function saveLoginDetails(saveLogin:Boolean = false, session:String = ""):void
        {
            if (saveLogin && session != "")
            {
                LocalStore.setVariable("uUsername", Crypt.Encode(_inputUser.text));
                LocalStore.setVariable("uSessionToken", Crypt.Encode(session));
            }
            else
            {
                LocalStore.deleteVariable("uPassword");
                LocalStore.deleteVariable("uUsername");
                LocalStore.deleteVariable("uSessionToken");
                LocalStore.deleteVariable("uAvatar");

                LocalStore.flush();
            }
        }

        public function loadLoginDetails():Object
        {
            var out:Object = {"state": STORED_NONE};

            var username:String = LocalStore.getVariable("uUsername", "");
            var sessionToken:String = LocalStore.getVariable("uSessionToken", "");

            if (sessionToken != "")
            {
                out["state"] = STORED_SESSION;
                out["username"] = Crypt.Decode(username);
                out["token"] = Crypt.Decode(sessionToken);
                out["avatar"] = LocalStore.getVariable("uAvatar", null);
            }
            else if (username != "")
            {
                var password:String = LocalStore.getVariable("uPassword", "");

                out["state"] = STORED_PASSWORD;
                out["username"] = Crypt.Decode(username);
                out["password"] = Crypt.Decode(password);
            }

            return out;
        }

    }
}
