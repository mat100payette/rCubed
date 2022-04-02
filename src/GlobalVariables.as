package
{
    import arc.mp.MultiplayerState;
    import classes.SongInfo;
    import classes.User;
    import classes.UserSettings;
    import classes.chart.Song;
    import com.flashfla.loader.DataEvent;
    import com.flashfla.net.DynamicURLLoader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.system.Capabilities;
    import state.AppState;

    public class GlobalVariables extends EventDispatcher
    {
        private var _loader:DynamicURLLoader;

        public var file_replay_cache:FileCache = new FileCache("replays/cache.json", 1);

        public function loadUserSongData():void
        {
            // Export SQL to JSON
            var dbName:String = "dbinfo/" + (activeUser != null && activeUser.siteId > 0 ? activeUser.siteId : "0") + "_info.";
            var sqlFile:File = AirContext.getAppFile(dbName + "db");
            var jsonFile:File = AirContext.getAppFile(dbName + "json");

            // Use JSON first
            if (jsonFile.exists)
            {
                var jsonStr:String = AirContext.readTextFile(jsonFile);
                if (jsonStr != null)
                {
                    try
                    {
                        SQLQueries.loadFromObject(JSON.parse(jsonStr));
                    }
                    catch (e:Error)
                    {

                    }
                }
            }
            // Fallback to SQL
            else if (sqlFile.exists)
            {
                SQLQueries.exportToJSON(sqlFile, function(data:Object):void
                {
                    SQLQueries.loadFromObject(data);
                    writeUserSongData();

                    // Create Backup File
                    var backupFile:File = AirContext.getAppFile(dbName + "db.bak");
                    for (var i:int = 0; i < 10; i++)
                    {
                        if (!backupFile.exists)
                        {
                            sqlFile.moveToAsync(backupFile);
                            break;
                        }

                        backupFile = AirContext.getAppFile(dbName + "db.bak" + i);
                    }
                });
            }
        }

        public function writeUserSongData():void
        {
            var user:User = AppState.instance.auth.user;
            var dbName:String = "dbinfo/" + (user != null && user.siteId > 0 ? user.siteId : "0") + "_info.";
            var jsonFile:File = AirContext.getAppFile(dbName + "json");

            SQLQueries.writeFile(jsonFile);
        }

        //- Song Data
        public function getSongFile(songInfo:SongInfo, settings:UserSettings = null, preview:Boolean = false):Song
        {
            if (!settings)
                settings = activeUser.settings;

            // TODO: Redo caching logic
            if (!preview && songInfo.engine == AppState.instance.content.currentPlaylist.engine && (!songInfo.engine || !songInfo.engine.ignoreCache))
            {
                for (var i:int = 0; i < songCache.length; i++)
                {
                    var song:Song = songCache[i];

                    if (song != null && song.songInfo.level == songInfo.level && song.frameRate == settings.frameRate && song.rate == settings.songRate)
                        return song;
                }
            }

            return loadSongFile(songInfo, settings, preview);
        }

        private function loadSongFile(songInfo:SongInfo, settings:UserSettings, isReplay:Boolean, isPreview:Boolean = false):Song
        {
            //- Only Cache 10 Songs
            var engineCache:Boolean = (songInfo.engine == AppState.instance.content.currentPlaylist.engine) && (!songInfo.engine || !songInfo.engine.ignoreCache);
            if (!isPreview && songCache.length > 10 && engineCache)
                songCache.pop();

            //- Make new Song
            var song:Song = new Song(songInfo, isPreview, settings);

            //- Push to cache
            if (!isPreview)
                songCache.push(song);

            return song;
        }

        public function removeSongFile(song:Song):void
        {
            for (var s:int = 0; s < songCache.length; s++)
            {
                if (songCache[s] == song)
                {
                    song.unload();
                    songCache.removeAt(s);
                }
            }
        }

        public function removeSongFiles():void
        {
            for (var s:int = 0; s < songCache.length; s++)
            {
                var song:Song = songCache[s];

                if (song)
                    song.unload();
            }

            songCache = [];

            const mpInstance:MultiplayerState = MultiplayerState.instance;
            if (mpInstance != null)
            {
                mpInstance.clearStatus();
            }
        }

        private static const SONG_ICON_NO_SCORE:int = 0;
        private static const SONG_ICON_PLAYED:int = 1;
        private static const SONG_ICON_FC:int = 2;
        private static const SONG_ICON_SDG:int = 3;
        private static const SONG_ICON_BLACKFLAG:int = 4;
        private static const SONG_ICON_BOOFLAG:int = 5;
        private static const SONG_ICON_AAA:int = 6;
        private static const SONG_ICON_FC_STAR:int = 7;

        public static function getSongIconIndex(_songInfo:SongInfo, _rank:Object):int
        {
            var songIcon:int = 0;
            if (_rank)
            {
                var arrows:int = _songInfo.noteCount;
                var scoreRaw:int = _songInfo.score_raw;
                if (_rank.arrows > 0)
                {
                    arrows = _rank.arrows;
                    scoreRaw = arrows * 50;
                }
                // No Score
                if (_rank.score == 0)
                    songIcon = SONG_ICON_NO_SCORE;

                // Played
                if (_rank.score > 0)
                    songIcon = SONG_ICON_PLAYED;

                // FC* - When current score isn't FC but a FC has been achieved before.
                if (_rank.fcs > 0)
                    songIcon = SONG_ICON_FC_STAR;

                // FC
                if (_rank.perfect + _rank.good + _rank.average == arrows && _rank.miss == 0 && _rank.maxcombo == arrows)
                    songIcon = SONG_ICON_FC;

                // SDG
                if (scoreRaw - _rank.rawscore < 250)
                    songIcon = SONG_ICON_SDG;

                // BlackFlag
                if (_rank.perfect == arrows - 1 && _rank.good == 1 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == arrows)
                    songIcon = SONG_ICON_BLACKFLAG;

                // BooFlag
                if (_rank.perfect == arrows && _rank.good == 0 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 1 && _rank.maxcombo == arrows)
                    songIcon = SONG_ICON_BOOFLAG;

                // AAA
                if (_rank.rawscore == scoreRaw)
                    songIcon = SONG_ICON_AAA;
            }
            return songIcon;
        }

        public static function getSongIconIndexBitmask(_songInfo:SongInfo, _rank:Object):int
        {
            var songIcon:int = SONG_ICON_NO_SCORE;
            if (_rank)
            {
                var arrows:int = _songInfo.noteCount;
                var scoreRaw:int = _songInfo.score_raw;
                if (_rank.arrows > 0)
                {
                    arrows = _rank.arrows;
                    scoreRaw = arrows * 50;
                }
                // Played
                if (_rank.score > 0)
                    songIcon |= (1 << SONG_ICON_PLAYED);

                // FC* - When current score isn't FC but a FC has been achieved before.
                if (_rank.fcs > 0)
                    songIcon |= (1 << SONG_ICON_FC_STAR);

                // FC
                if (_rank.perfect + _rank.good + _rank.average == arrows && _rank.miss == 0 && _rank.maxcombo == arrows)
                    songIcon |= (1 << SONG_ICON_FC);

                // SDG
                if (scoreRaw - _rank.rawscore < 250)
                    songIcon |= (1 << SONG_ICON_SDG);

                // BlackFlag
                if (_rank.perfect == arrows - 1 && _rank.good == 1 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 0 && _rank.maxcombo == arrows)
                    songIcon |= (1 << SONG_ICON_BLACKFLAG);

                // BooFlag
                if (_rank.perfect == arrows && _rank.good == 0 && _rank.average == 0 && _rank.miss == 0 && _rank.boo == 1 && _rank.maxcombo == arrows)
                    songIcon |= (1 << SONG_ICON_BOOFLAG);

                // AAA
                if (_rank.rawscore == scoreRaw)
                    songIcon |= (1 << SONG_ICON_AAA);
            }
            return songIcon;
        }

        public static const SONG_ICON_TEXT:Array = ["<font color=\"#9C9C9C\">UNPLAYED</font>", "", "<font color=\"#00FF00\">FC</font>",
            "<font color=\"#f2a254\">SDG</font>", "<font color=\"#2C2C2C\">BLACKFLAG</font>",
            "<font color=\"#473218\">BOOFLAG</font>", "<font color=\"#FFFF38\">AAA</font>", "<font color=\"#00FF00\">FC*</font>"];

        public static const SONG_ICON_COLOR:Array = ["#9C9C9C", "#FFFFFF", "#00FF00", "#f2a254", "#2C2C2C", "#473218", "#FFFF38", "#00FF00"];

        public static const SONG_ICON_TEXT_FLAG:Array = ["Unplayed", "Played", "Full Combo",
            "Single Digit Good", "Blackflag", "Booflag", "AAA", "Full Combo*"];

        public static function getSongIcon(_songInfo:SongInfo, _rank:Object):String
        {
            return SONG_ICON_TEXT[getSongIconIndex(_songInfo, _rank)];
        }

        //- Hiscores
        /**
         * Returns the loaded Highscore for the specified level id.
         * @param	lvlID
         * @return	Object containing the highscores list, or null if no highscore were loaded.
         */
        public function getHighscores(lvlID:int):Object
        {
            if (songHighscores[lvlID])
                return songHighscores[lvlID];

            return null;
        }

        public function clearHighscores():void
        {
            songHighscores = {};
        }

        public function loadHighscores(lvlID:int, startIndex:int = 0):void
        {
            _loader = new DynamicURLLoader();
            addLoaderListeners();

            var req:URLRequest = new URLRequest(Constant.SITE_HISCORES_URL + "?d=" + new Date().getTime());
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = AppState.instance.auth.userSession;
            requestVars.level = lvlID;
            requestVars.start = startIndex;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            _loader.level = lvlID;
            _loader.load(req);
        }

        private function highscoreLoadComplete(e:Event):void
        {
            removeLoaderListeners();
            var lvlID:int = e.target.level;
            var data:Object = JSON.parse(e.target.data);
            var hiscores:Object = songHighscores[lvlID];

            if (!hiscores)
                songHighscores[lvlID] = {};

            if (data.error == null)
            {
                for each (var item:Object in data)
                {
                    songHighscores[lvlID][item.id] = item;
                }
            }
            this.dispatchEvent(new DataEvent(Constant.HIGHSCORES_LOAD_COMPLETE, data));
        }

        private function highscoreLoadError(e:Event = null):void
        {
            removeLoaderListeners();
            this.dispatchEvent(new Event(Constant.HIGHSCORES_LOAD_ERROR));
        }

        private function addLoaderListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, highscoreLoadComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, highscoreLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, highscoreLoadError);
        }

        private function removeLoaderListeners():void
        {
            _loader.removeEventListener(Event.COMPLETE, highscoreLoadComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, highscoreLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, highscoreLoadError);
        }

        public function logDebugError(id:String, params:Object = null):void
        {
            var output:String = id;
            if (params is Error)
            {
                var err:Error = (params as Error);
                output += "\n" + err.name + "\n" + err.message + "\n" + err.errorID + "\n" + err.getStackTrace();
            }
            else
            {
                output += "\n" + params;
            }

            var debugLoader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest(Constant.DEBUG_LOG_URL);
            var requestVars:URLVariables = new URLVariables();
            Constant.addDefaultRequestVariables(requestVars);
            requestVars.session = AppState.instance.auth.userSession;
            requestVars.error = output;
            requestVars.gameVersion = CONFIG::timeStamp;
            requestVars.gameSettings = Capabilities.serverString;
            req.data = requestVars;
            req.method = URLRequestMethod.POST;
            debugLoader.dataFormat = URLLoaderDataFormat.TEXT;
            debugLoader.load(req);
        }
    }
}
