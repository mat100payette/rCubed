package classes
{
    import arc.ArcGlobals;
    import com.flashfla.utils.VectorUtil;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import sql.SQLSongUserInfo;

    public class User extends EventDispatcher
    {
        //- Constants
        public static const ADMIN_ID:int = 6;
        public static const DEVELOPER_ID:int = 83;
        public static const BANNED_ID:int = 8;
        public static const CHAT_MOD_ID:int = 24;
        public static const FORUM_MOD_ID:int = 5;
        public static const MULTI_MOD_ID:int = 44;
        public static const MUSIC_PRODUCER_ID:int = 46;
        public static const PROFILE_MOD_ID:int = 56;
        public static const SIM_AUTHOR_ID:int = 47;
        public static const VETERAN_ID:int = 49;

        ///- Private Locals
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _loader:URLLoader;
        private var _isLoaded:Boolean = false;
        private var _isLoading:Boolean = false;
        private var _loadError:Boolean = false;
        private var _isLiteUser:Boolean;

        //- SFS vars
        public var id:int;
        public var variables:Array;
        public var isSpec:Boolean;
        public var wantsToWatch:Boolean;

        //- User Vars
        public var name:String;
        public var siteId:int;
        public var hash:String;
        public var groups:Vector.<Number>;

        public var playerIdx:int;

        public var userLevel:int;
        public var userClass:int;
        public var userColor:int;
        public var userStatus:int;

        public var joinDate:String;
        public var skillLevel:Number;
        public var skillRating:Number;
        public var gameRank:Number;
        public var gamesPlayed:Number;
        public var grandTotal:Number;
        public var credits:Number;
        public var purchased:Vector.<Boolean>;
        public var averageRank:Number;
        public var levelRanks:Object = {};
        public var avatar:Loader;

        public var loggedIn:Boolean;

        public var songRatings:Object = {};

        public var gameplay:Gameplay;
        public var settings:UserSettings = new UserSettings();

        //- Permissions
        public var isGuest:Boolean;
        public var isPlayer:Boolean;
        public var isVeteran:Boolean;
        public var isAdmin:Boolean;
        public var isDeveloper:Boolean
        public var isForumBanned:Boolean;
        public var isGameBanned:Boolean;
        public var isProfileBanned:Boolean;
        public var isModerator:Boolean;
        public var isForumModerator:Boolean;
        public var isProfileModerator:Boolean;
        public var isChatModerator:Boolean;
        public var isMultiModerator:Boolean;
        public var isMusician:Boolean;
        public var isSimArtist:Boolean;

        ///- Constructor
        /**
         * Defines the creation of a new User object.
         *
         * @param	isActiveUser Sets the active user flag.
         * @tiptext
         */
        public function User(isActiveUser:Boolean = false, sfsId:int = -1):void
        {
            this.id = sfsId;
            this.variables = [];
            this.isSpec = false;
            this.wantsToWatch = false;
            this._isLiteUser = !isActiveUser;

            this.settings = new UserSettings(!isActiveUser);
        }

        /**
         * Initiates fetching the user's data from the database, including only the necessary data.
         * @param includeProfile
         * @param includeSettings
         */
        public function loadData(includeProfile:Boolean = true, includeSettings:Boolean = true):void
        {
            if (includeProfile)
                if (includeSettings)
                    _loadFullUser();
                else
                    _loadUserNoSettings();
        }

        public function refreshUser():void
        {
            _gvars.userSession = "0";
            _gvars.playerUser = new User(true);
            _gvars.playerUser.loadData(true, true);
            _gvars.activeUser = _gvars.playerUser;
        }

        ///- Public
        public function calculateAverageRank():void
        {
            var rankTotal:int = 0;
            for each (var levelRank:Object in this.levelRanks)
            {
                var genre:int = levelRank.genre;
                if (genre != 10 && genre != 12 && genre != 23)
                {
                    rankTotal += levelRank.rank;
                }
            }
            this.averageRank = (rankTotal / _gvars.TOTAL_PUBLIC_SONGS);
        }

        ///- Profile Loading
        public function isLoaded():Boolean
        {
            return _isLoaded && !_loadError;
        }

        public function isError():Boolean
        {
            return _loadError;
        }

        private function _loadFullUser():void
        {
            // Kill old Loading Stream
            if (_loader && _isLoading)
            {
                _loader.removeEventListener(Event.COMPLETE, _onFullUserDataLoaded);
                _removeCommonLoaderListeners();
                _loader.close();
            }

            Logger.info(this, "User Load Requested");
            _isLoaded = false;
            _loadError = false;
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, _onFullUserDataLoaded);
            _addCommonLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.USER_INFO_URL + "?d=" + new Date().getTime());
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = _gvars.userSession;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
            _isLoading = true;
        }

        private function _loadUserNoSettings():void
        {
            Logger.info(this, "User No Settings Load Requested");
            _isLoaded = false;
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, _onUserDataNoSettingsLoaded);
            _addCommonLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.USER_INFO_LITE_URL + "?d=" + new Date().getTime());
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.userid = siteId;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
            _isLoading = true;
        }

        private function _onFullUserDataLoaded(e:Event):void
        {
            Logger.info(this, "Full User Load Success");
            _loader.removeEventListener(Event.COMPLETE, _onFullUserDataLoaded);
            _onUserLoaded(e, true, true);
        }

        private function _onUserDataNoSettingsLoaded(e:Event):void
        {
            Logger.info(this, "User No Settings Load Success");
            _loader.removeEventListener(Event.COMPLETE, _onUserDataNoSettingsLoaded);
            _onUserLoaded(e, true, false);
        }

        private function _onUserLoaded(e:Event, includeProfile:Boolean, includeSettings:Boolean):void
        {
            _removeCommonLoaderListeners();

            // Parse Response
            var data:Object;
            var siteDataString:String = e.target.data;
            try
            {
                data = JSON.parse(siteDataString);
            }
            catch (err:Error)
            {
                Logger.error(this, "Profile Parse Failure: " + Logger.exception_error(err));
                Logger.error(this, "Wrote invalid response data to log folder. [logs/user_main.txt]");
                AirContext.writeTextFile(AirContext.getAppFile("logs/user_main.txt"), siteDataString);

                _loadError = true;
                this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
                return;
            }

            _applyLoadedUserProfile(data);
            if (includeSettings)
                _applyLoadedUserSettings(data);

            if (!_isLiteUser)
            {
                loadLevelRanks();
            }
            else
            {
                _isLoaded = true;
                this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
            }
        }

        private function _applyLoadedUserProfile(data:Object):void
        {
            // Private
            if (!_isLiteUser)
            {
                this.hash = data.hash;
                this.credits = data.credits;
                setPurchasedString(data["purchased"]);
                if (data["song_ratings"] != null)
                    this.songRatings = data["song_ratings"];
            }

            // Public
            this.name = data["name"];
            this.siteId = data["id"];
            this.groups = Vector.<Number>(VectorUtil.fromArr(data["groups"]));
            this.joinDate = data["joinDate"];
            this.gameRank = data["gameRank"];
            this.gamesPlayed = data["gamesPlayed"];
            this.grandTotal = data["grandTotal"];
            this.skillLevel = data["skillLevel"];
            this.skillRating = data["skillRating"];

            setupPermissions();

            // Load Avatar
            loadAvatar();
        }

        private function _applyLoadedUserSettings(data:Object):void
        {
            var loadedSettings:Object;
            if (this.isGuest || data["settings"] == null)
                loadedSettings = _loadLocalSettings();
            else
                loadedSettings = data.settings;

            try
            {
                settings.update(JSON.parse(data.settings));
            }
            catch (err:Error)
            {
                Logger.error(this, "Settings Parse Failure: " + Logger.exception_error(err));
            }
        }

        public function setPurchasedString(str:String):void
        {
            this.purchased = new <Boolean>[];
            for (var x:int = 1; x < str.length; x++)
            {
                this.purchased.push(str.charAt(x) == "1");
            }
        }

        private function _onUserLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Profile Load Failure: " + Logger.event_error(err));

            _loader.removeEventListener(Event.COMPLETE, _onFullUserDataLoaded);
            _loader.removeEventListener(Event.COMPLETE, _onUserDataNoSettingsLoaded);
            _removeCommonLoaderListeners();

            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
        }

        private function _addCommonLoaderListeners():void
        {
            _loader.addEventListener(IOErrorEvent.IO_ERROR, _onUserLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onUserLoadError);
        }

        private function _removeCommonLoaderListeners():void
        {
            _isLoaded = false;
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, _onUserLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onUserLoadError);
        }

        private function setupPermissions():void
        {
            this.isGuest = (this.siteId <= 2);
            this.isVeteran = VectorUtil.inVector(this.groups, new <Number>[VETERAN_ID]);
            this.isAdmin = VectorUtil.inVector(this.groups, new <Number>[ADMIN_ID]);
            this.isDeveloper = VectorUtil.inVector(this.groups, new <Number>[DEVELOPER_ID])
            this.isForumBanned = VectorUtil.inVector(this.groups, new <Number>[BANNED_ID]);
            this.isModerator = VectorUtil.inVector(this.groups, new <Number>[ADMIN_ID, FORUM_MOD_ID, CHAT_MOD_ID, PROFILE_MOD_ID, MULTI_MOD_ID]);
            this.isForumModerator = VectorUtil.inVector(this.groups, new <Number>[FORUM_MOD_ID, ADMIN_ID]);
            this.isProfileModerator = VectorUtil.inVector(this.groups, new <Number>[PROFILE_MOD_ID, ADMIN_ID]);
            this.isChatModerator = VectorUtil.inVector(this.groups, new <Number>[CHAT_MOD_ID, ADMIN_ID]);
            this.isMultiModerator = VectorUtil.inVector(this.groups, new <Number>[MULTI_MOD_ID, ADMIN_ID]);
            this.isMusician = VectorUtil.inVector(this.groups, new <Number>[MUSIC_PRODUCER_ID]);
            this.isSimArtist = VectorUtil.inVector(this.groups, new <Number>[SIM_AUTHOR_ID]);
        }

        public function loadAvatar():void
        {
            this.avatar = new Loader();
            if (!_isLiteUser && !isGuest)
            {
                this.avatar.contentLoaderInfo.addEventListener(Event.COMPLETE, avatarLoadComplete);

                function avatarLoadComplete(e:Event):void
                {
                    LocalStore.setVariable("uAvatar", LoaderInfo(e.target).bytes);
                    avatar.removeEventListener(Event.COMPLETE, avatarLoadComplete);
                }
            }
            this.avatar.load(new URLRequest(Constant.USER_AVATAR_URL + "?uid=" + this.siteId + "&cHeight=99&cWidth=99"));
        }

        ///- Level Ranks
        public function loadLevelRanks():void
        {
            _loader = new URLLoader();
            addLoaderRanksListeners();

            var req:URLRequest = new URLRequest(Constant.USER_RANKS_URL);
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = _gvars.userSession;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
        }

        private function ranksLoadComplete(e:Event):void
        {
            Logger.info(this, "Ranks Load Success");
            removeLoaderRanksListeners();
            levelRanks = {};

            // Check Level ranks for Non-empty
            if (e.target.data != "")
            {
                var ranksTemp:Array = e.target.data.split(",");
                var rankLength:int = ranksTemp.length;
                for (var i:int = 0; i < rankLength; i++)
                {
                    // [0] = Level ID : [1] = Rank : [2] = Score : [3] = Genre : [4] = Results : [5] = Play Count : [6] = AAA Count : [7] = FC Count
                    var rankSplit:Array = ranksTemp[i].split(":");

                    // [0]'perfect' - [1]'good' - [2]'average' - [3]'miss' - [4]'boo' - [5]'maxcombo'
                    var scoreResults:Array = rankSplit[4].split("-");
                    for (var s:String in scoreResults)
                        scoreResults[s] = Number(scoreResults[s]);

                    levelRanks[Number(rankSplit[0])] = {"genre": Number(rankSplit[3]),
                            "rank": Number(rankSplit[1]),
                            "score": Number(rankSplit[2]),
                            "results": rankSplit[4],
                            "plays": Number(rankSplit[5]),
                            "aaas": Number(rankSplit[6]),
                            "fcs": Number(rankSplit[7]),
                            "perfect": scoreResults[0],
                            "good": scoreResults[1],
                            "average": scoreResults[2],
                            "miss": scoreResults[3],
                            "boo": scoreResults[4],
                            "maxcombo": scoreResults[5],
                            "rawscore": ((scoreResults[0] * 50) + (scoreResults[1] * 25) + (scoreResults[2] * 5) - (scoreResults[3] * 10) - (scoreResults[4] * 5))};
                }
            }
            _isLoaded = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }

        private function ranksLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Ranks Load Failure: " + Logger.event_error(err));
            removeLoaderRanksListeners();
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
        }

        private function addLoaderRanksListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, ranksLoadComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ranksLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ranksLoadError);
        }

        private function removeLoaderRanksListeners():void
        {
            _loader.removeEventListener(Event.COMPLETE, ranksLoadComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, ranksLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, ranksLoadError);
        }

        public function saveSettingsOnline():void
        {
            if (isGuest)
                return;

            //- Save to server
            _loader = new URLLoader();
            addLoaderSaveListeners();

            var req:URLRequest = new URLRequest(Constant.USER_SAVE_SETTINGS_URL);
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = _gvars.userSession;

            requestVars.settings = settings.stringify();
            requestVars.action = "save";
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.load(req);
        }

        private function settingSaveComplete(e:Event):void
        {
            Logger.debug(this, "Settings Save Success");
            removeLoaderSaveListeners();
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }

        private function settingLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Settings Save Failure: " + Logger.event_error(err));
            removeLoaderSaveListeners();
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
        }

        private function addLoaderSaveListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, settingSaveComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, settingLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, settingLoadError);
        }

        private function removeLoaderSaveListeners():void
        {
            _loader.removeEventListener(Event.COMPLETE, settingSaveComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, settingLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, settingLoadError);
        }

        public function saveSettingsLocally():void
        {
            LocalStore.setVariable("sEncode", settings.stringify());
            LocalStore.flush();
        }

        private function _loadLocalSettings():Object
        {
            var encodedSettings:String = LocalStore.getVariable("sEncode", null);
            if (encodedSettings == null)
                return null;

            return JSON.parse(encodedSettings);
        }

        public function getLevelRank(songInfo:SongInfo):Object
        {
            if (songInfo.engine)
                return ArcGlobals.instance.legacyLevelRanksGet(songInfo);

            if (levelRanks[songInfo.level] == null)
                return {"genre": 23,
                        "rank": 1,
                        "score": 0,
                        "results": "0-0-0-0-0-0",
                        "plays": 0,
                        "aaas": 0,
                        "fcs": 0,
                        "perfect": 0,
                        "good": 0,
                        "average": 0,
                        "miss": 0,
                        "boo": 0,
                        "maxcombo": 0,
                        "rawscore": 0};

            return levelRanks[songInfo.level];
        }

        public function getSongRating(songInfo:SongInfo):Number
        {
            if (songInfo.engine != null)
            {
                var sDetails:SQLSongUserInfo = SQLQueries.getSongDetails(songInfo.engine.id, songInfo.level_id);
                if (sDetails)
                    return sDetails.song_rating;

                return 0;
            }
            return songRatings[songInfo.level] != null ? songRatings[songInfo.level] : 0;
        }

        /**
         * Set the User Variables.
         *
         * @param	o:	an object containing variables' key-value pairs.
         *
         * @exclude
         */
        public function setVariables(o:Object):void
        {
            /*
             * TODO: only string, number (int, uint) and boolean should be allowed
             */
            for (var key:String in o)
            {
                var v:* = o[key];
                if (v != null)
                    this.variables[key] = v;

                else
                    delete this.variables[key];
            }
        }
    }
}
