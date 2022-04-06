package state_management
{

    import classes.Playlist;
    import classes.SongInfo;
    import classes.User;
    import classes.UserSettings;
    import classes.chart.Song;
    import com.flashfla.net.DynamicURLLoader;
    import events.actions.content.EngineLoadedEvent;
    import events.actions.content.ReloadEngineEvent;
    import events.actions.content.UpdateGameContentFromSiteEvent;
    import events.actions.content.UpdateSongAccessEvent;
    import events.navigation.InitialLoadingEvent;
    import events.navigation.popups.RemovePopupEvent;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.filesystem.File;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import state.AppState;
    import state.ContentState;

    public class ContentController extends Controller
    {
        private var _target:IEventDispatcher;

        private var _replayFileCache:FileCache;

        public function ContentController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);

            _replayFileCache = new FileCache("replays/cache.json", 1);

            addListeners();
        }

        private function addListeners():void
        {
            target.addEventListener(UpdateSongAccessEvent.EVENT_TYPE, updateSongAccess);
            target.addEventListener(UpdateGameContentFromSiteEvent.EVENT_TYPE, updateGameContentFromSite);
            target.addEventListener(ReloadEngineEvent.EVENT_TYPE, reloadEngine);
            target.addEventListener(EngineLoadedEvent.EVENT_TYPE, engineLoaded);
        }

        private function updateSongAccess(e:UpdateSongAccessEvent):void
        {
            var newState:AppState = AppState.clone(owner);

            var user:User = newState.auth.user;
            var currentPlaylist:Playlist = newState.content.currentPlaylist;
            var indexList:Vector.<SongInfo> = currentPlaylist.indexList;

            var songType:int = 0;
            for (var i:int = 0; i < currentPlaylist.indexList.length; i++)
            {
                songType = SongInfo.SONG_TYPE_PUBLIC;

                if (indexList[i].engine == null && newState.content.tokens[indexList[i].level] != null)
                    songType = SongInfo.SONG_TYPE_TOKEN;
                if (indexList[i].price > 0)
                    songType = SongInfo.SONG_TYPE_PURCHASED;
                if (indexList[i].credits > 0)
                    songType = SongInfo.SONG_TYPE_SECRET;

                // NOTE: This is basically caching the access, and might not be needed
                indexList[i].access = indexList[i].checkSongAccess(user);
                indexList[i].song_type = songType;
            }

            updateState(newState);
        }

        public function unlockTokenById(tokenType:String, id:String):void
        {
            var newState:AppState = AppState.clone(owner);
            var contentState:ContentState = newState.content;

            try
            {
                contentState.tokens[contentState.tokensType[tokenType][id].level].unlock = 1;
            }
            catch (err:Error)
            {
                Logger.error(this, "Attempted Unlock of Unknown Token: " + tokenType + ", " + id);
            }

            updateState(newState);
        }

        public function updateGameContentFromSite(data:Object):void
        {
            var newState:AppState = AppState.clone(owner);
            var contentState:ContentState = newState.content;

            // Has Response
            contentState.totalGenres = data.game_totalgenres;
            contentState.maxCreditsPerPlay = data.game_maxcredits;
            contentState.scorePerCredit = data.game_scorepercredit;
            contentState.maxSongDifficulty = data.game_maxdifficulty;
            contentState.difficultyRanges = data.game_difficulty_range;
            contentState.nonPublicGenres = data.game_nonpublic_genres;

            // MP Divisions
            contentState.divisionLevel = data.division_levels;
            contentState.divisionTitle = data.division_titles;

            var divisionColors:Array = [];
            for each (var value:String in data.division_colors)
                divisionColors.push(parseInt(value.substring(1), 16));

            contentState.divisionColor = divisionColors;

            // Tokens
            contentState.tokens = {};
            var tokensType:Object = {};
            for each (var token:Object in data.game_tokens_all)
            {
                if (!tokensType[token.type])
                    tokensType[token.type] = [];

                tokensType[token.type][token.id] = token;

                if (token.level)
                    contentState.tokens[token.level] = token;
            }
            contentState.tokensType = tokensType;

            // TODO: Add status to state?
            //_isLoaded = true;
            //_loadError = false;

            Logger.info(this, "Parse Complete");
        }

        private function reloadEngine(e:ReloadEngineEvent):void
        {
            MultiplayerState.destroyInstance();
            Flags.VALUES = {};

            target.dispatchEvent(new RemovePopupEvent());
            target.dispatchEvent(new InitialLoadingEvent(true));
        }

        private function engineLoaded(e:EngineLoadedEvent):void
        {
            //_gvars.removeSongFiles();
            MenuSongSelection.options.pageNumber = 0;
            MenuSongSelection.options.scroll_position = 0;
        }

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

        private function getSongFile(songInfo:SongInfo, settings:UserSettings = null, preview:Boolean = false):Song
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

        private function removeSongFile(song:Song):void
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

        private function removeSongFiles():void
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

        private function loadUserSongData():void
        {
            var user:User = AppState.instance.auth.user;

            var dbName:String = "dbinfo/" + (user != null && user.siteId > 0) ? user.siteId.toString() : "0" + "_info.";
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
    }
}
