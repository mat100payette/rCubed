package classes
{
    import arc.ArcGlobals;
    import classes.chart.parse.ChartFFRLegacy;
    import com.flashfla.utils.Crypt;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import events.state.EngineLoadedEvent;
    import flash.events.IEventDispatcher;

    public class PlaylistLoader extends EventDispatcher
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        private var _loader:URLLoader;
        private var _isLoaded:Boolean = false;
        private var _isLoading:Boolean = false;
        private var _loadError:Boolean = false;

        private var _onPlaylistDataLoaded:Function;

        public function PlaylistLoader(target:IEventDispatcher, onPlaylistDataLoaded:Function)
        {
            super(target);

            _onPlaylistDataLoaded = onPlaylistDataLoaded;
        }

        public function isLoaded():Boolean
        {
            return _isLoaded && !_loadError;
        }

        public function isError():Boolean
        {
            return _loadError;
        }

        ///- Playlist Loading
        public function load():void
        {
            // Kill old Loading Stream
            if (_loader && _isLoading)
            {
                removeLoaderListeners();
                _loader.close();
            }

            // Load New
            var time:Number = new Date().getTime();
            _isLoaded = false;
            _loadError = false;
            _loader = new URLLoader();
            addLoaderListeners();

            if (ArcGlobals.instance.configLegacy)
            {
                var url:String = ArcGlobals.instance.configLegacy.playlistURL;
                _loader.load(new URLRequest(url + (url.indexOf("?") == -1 ? "?d=" + time : "&d=" + time)));
                _isLoading = true;
            }
            else
            {
                var req:URLRequest = new URLRequest(Constant.SITE_PLAYLIST_URL + "?d=" + time);
                var requestVars:URLVariables = new URLVariables();
                Constant.addDefaultRequestVariables(requestVars);
                requestVars.session = _gvars.userSession;
                req.data = requestVars;
                req.method = URLRequestMethod.POST;
                _loader.load(req);
                _isLoading = true;
            }
        }

        private function playlistLoadComplete(e:Event):void
        {
            removeLoaderListeners();
            var data:Object;
            var legacy:Boolean = ArcGlobals.instance.configLegacy;
            try
            {
                if (legacy)
                    data = ChartFFRLegacy.parsePlaylist(e.target.data);
                else
                {
                    data = JSON.parse(e.target.data);
                }
            }
            catch (e:Error)
            {
                _loadError = true;
                this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
                return;
            }

            var generatedQueues:Array = [];
            var genreList:Array = [];
            var playList:Array = [];
            var indexList:Vector.<SongInfo> = new <SongInfo>[];

            for each (var dynamicSongInfo:Object in data)
            {
                var songInfo:SongInfo;

                if (dynamicSongInfo is SongInfo)
                {
                    songInfo = dynamicSongInfo as SongInfo;

                    if (genreList[songInfo.genre] == undefined)
                    {
                        genreList[songInfo.genre] = [];
                        generatedQueues[songInfo.genre] = [];
                    }
                }
                else
                {
                    var genre:int = dynamicSongInfo.genre;
                    if (genreList[genre] == undefined)
                    {
                        genreList[genre] = [];
                        generatedQueues[genre] = [];
                    }

                    // Important to note that the dynamic fields aren't all exactly the same name
                    var newSongInfo:SongInfo = new SongInfo();
                    newSongInfo.author = dynamicSongInfo.author;
                    newSongInfo.authorUrl = dynamicSongInfo.authorURL;
                    newSongInfo.credits = dynamicSongInfo.credits;
                    newSongInfo.difficulty = dynamicSongInfo.difficulty;
                    newSongInfo.genre = dynamicSongInfo.genre;
                    newSongInfo.level = dynamicSongInfo.level;
                    newSongInfo.minNps = dynamicSongInfo.min_nps;
                    newSongInfo.maxNps = dynamicSongInfo.max_nps;
                    newSongInfo.name = dynamicSongInfo.name;
                    newSongInfo.noteCount = dynamicSongInfo.arrows;
                    newSongInfo.order = dynamicSongInfo.order;
                    newSongInfo.playHash = dynamicSongInfo.playhash;
                    newSongInfo.prerelease = dynamicSongInfo.prerelease;
                    newSongInfo.previewHash = dynamicSongInfo.previewhash;
                    newSongInfo.price = dynamicSongInfo.price;
                    newSongInfo.release_Date = dynamicSongInfo.releasedate;
                    newSongInfo.songRating = dynamicSongInfo.song_rating;
                    newSongInfo.stepauthor = dynamicSongInfo.stepauthor;
                    newSongInfo.stepauthorUrl = dynamicSongInfo.stepauthorURL;
                    newSongInfo.style = dynamicSongInfo.style;
                    newSongInfo.time = dynamicSongInfo.time;

                    songInfo = newSongInfo;
                }

                // Song Time
                if (songInfo.time == null)
                    songInfo.time = "0:00";

                // Note Count
                if (isNaN(Number(songInfo.noteCount)))
                    songInfo.noteCount = 0;

                // Extra Info
                songInfo.index = genreList[songInfo.genre].length;
                songInfo.timeSecs = (Number(songInfo.time.split(":")[0]) * 60) + Number(songInfo.time.split(":")[1]);

                // Author with URL
                if (songInfo.authorUrl != null && songInfo.authorUrl.length > 7)
                    songInfo.authorHtml = "<a href=\"" + songInfo.authorUrl + "\">" + songInfo.author + "</a>";
                else
                    songInfo.authorHtml = songInfo.author;

                // Multiple Step Authors
                if (songInfo.stepauthor != null && songInfo.stepauthor.indexOf(" & ") !== false)
                {
                    var stepAuthors:Array = songInfo.stepauthor.split(" & ");
                    songInfo.stepauthorHtml = "<a href=\"" + Constant.ROOT_URL + "profile/" + Crypt.urlencode(stepAuthors[0]) + "\">" + stepAuthors[0] + "</a>";

                    for (var i:int = 1; i < stepAuthors.length; i++)
                        songInfo.stepauthorHtml += " & <a href=\"" + Constant.ROOT_URL + "profile/" + Crypt.urlencode(stepAuthors[i]) + "\">" + stepAuthors[i] + "</a>";
                }
                else
                    songInfo.stepauthorHtml = "<a href=\"" + Constant.ROOT_URL + "profile/" + Crypt.urlencode(songInfo.stepauthor) + "\">" + songInfo.stepauthor + "</a>";

                // Song Price
                if (isNaN(Number(songInfo.price)))
                    songInfo.price = -1;

                // Secret Credits
                if (isNaN(Number(songInfo.credits)))
                    songInfo.credits = -1;

                // Max Score Totals
                songInfo.score_total = songInfo.noteCount * 1550;
                songInfo.score_raw = songInfo.noteCount * 50;

                // Legacy Sync
                if (!legacy && isNaN(songInfo.sync))
                    songInfo.sync = oldOffsets(songInfo.level);

                // Add to lists
                playList[songInfo.level] = songInfo;
                indexList.push(songInfo);
                genreList[songInfo.genre].push(songInfo);
                generatedQueues[songInfo.genre].push(songInfo.level);
                    //_gvars.songQueue.push(songData);
            }
            indexList.sort(compareSongLevel);
            _isLoaded = true;
            _loadError = false;

            _onPlaylistDataLoaded(generatedQueues, genreList, playList, indexList);

            dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }

        private function compareSongLevel(songInfo1:SongInfo, songInfo2:SongInfo):Number
        {
            if (songInfo1.level < songInfo2.level)
                return -1;
            else if (songInfo1.level > songInfo2.level)
                return 1;
            else
                return 0;
        }

        private function playlistLoadError(e:Event = null):void
        {
            removeLoaderListeners();
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
        }

        private function addLoaderListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, playlistLoadComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, playlistLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, playlistLoadError);
        }

        private function removeLoaderListeners():void
        {
            _isLoading = false;
            _loader.removeEventListener(Event.COMPLETE, playlistLoadComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, playlistLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, playlistLoadError);
        }

        public function engineChangeHandler(e:Event):void
        {
            removeEventListener(GlobalVariables.LOAD_COMPLETE, engineChangeHandler);
            removeEventListener(GlobalVariables.LOAD_ERROR, engineChangeHandler);
            switch (e.type)
            {
                case GlobalVariables.LOAD_ERROR:
                    ArcGlobals.instance.configLegacy = null;
                    load();
                    Alert.add(_lang.string("error_loading_playlist"));
                    break;
                case GlobalVariables.LOAD_COMPLETE:
                    _gvars.dispatchEvent(new EngineLoadedEvent());
                    break;
            }
        }

        private function oldOffsets(lvlid:int):int
        {
            switch (lvlid)
            {
                case 87:
                case 88:
                    return -10;
                case 68:
                case 28:
                case 25:
                case 24:
                case 21:
                case 20:
                    return 0;
                case 37:
                    return 6;
                case 23:
                    return -2;
                case 22:
                    return 3;
                case 19:
                    return -4;
                case 17:
                    return 1;
                case 1883:
                    return -21;
                default:
                    return lvlid <= 29 ? -6 : 0;
            }
        }
    }
}
