package state_management
{

    import classes.Playlist;
    import classes.SongInfo;
    import classes.User;
    import events.state.StateEvent;
    import events.state.UpdateSongAccessEvent;
    import flash.events.IEventDispatcher;
    import state.AppState;
    import state.ContentState;
    import events.state.UpdateGameContentFromSiteEvent;

    public class ContentController extends Controller
    {
        private var _target:IEventDispatcher;

        public function ContentController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case UpdateSongAccessEvent.STATE:
                    onUpdateSongAccess(e as UpdateSongAccessEvent);
                    break;
                case UpdateGameContentFromSiteEvent.STATE:
                    updateGameContentFromSite(e as UpdateGameContentFromSiteEvent);
                    break;
            }
        }

        private function onUpdateSongAccess(e:UpdateSongAccessEvent):void
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
    }
}
