package state
{

    import classes.Playlist;
    import classes.SongInfo;
    import com.flashfla.utils.ArrayUtil;

    public class ContentState extends State implements IState
    {
        private var _altPlaylist:Playlist;
        private var _canonPlaylist:Playlist;
        private var _usingCanon:Boolean;

        // TODO: Type this...
        private var _tokens:Object;
        private var _tokensType:Object;

        private var _totalGenres:int;
        private var _maxCreditsPerPlay:int;
        private var _scorePerCredit:int;
        private var _maxSongDifficulty:int;

        private var _difficultyRanges:Array;
        private var _nonPublicGenres:Array;
        private var _divisionColor:Array;
        private var _divisionTitle:Array;
        private var _divisionLevel:Array;

        private var _healthJudgeAdd:int;
        private var _healthJudgeRemove:int;

        private var _songCache:Array = [];
        private var _songHighscores:Object = {};

        private var _replayHistory:Array = [];

        public function ContentState(frozen:Boolean = false)
        {
            super(frozen);

            _usingCanon = true;
            _altPlaylist = new Playlist();
            _canonPlaylist = new Playlist();

            _totalGenres = 13;
            _maxCreditsPerPlay = 120;
            _scorePerCredit = 50000;
            _maxSongDifficulty = 120;

            _difficultyRanges = [[1, 120]];
            _nonPublicGenres = [];
            _divisionColor = [0xC27BA0, 0x8E7CC3, 0x6D9EEB, 0x93C47D, 0xCEA023, 0xE06666, 0x919C86, 0xD2C7AC, 0xBF0000];
            _divisionTitle = ["Novice", "Intermediate", "Advanced", "Expert", "Master", "Guru", "Legendary", "Godly", "Developer"];
            _divisionLevel = [0, 26, 50, 59, 69, 83, 94, 101, 122];

            _tokens = {};
            _tokensType = {};

            _healthJudgeAdd = 5;
            _healthJudgeRemove = -5;

            _songCache = [];
            _songHighscores = {};

            _replayHistory = [];
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:ContentState = new ContentState(false);

            cloned._usingCanon = _usingCanon;

            cloned._altPlaylist = _altPlaylist.clone();
            cloned._canonPlaylist = _canonPlaylist.clone();

            cloned._totalGenres = _totalGenres;
            cloned._maxCreditsPerPlay = _maxCreditsPerPlay;
            cloned._scorePerCredit = _scorePerCredit;
            cloned._maxSongDifficulty = _maxSongDifficulty;

            // TODO: Cloneable arrays
            cloned._difficultyRanges = _difficultyRanges;
            cloned._nonPublicGenres = _nonPublicGenres;
            cloned._divisionColor = _divisionColor;
            cloned._divisionTitle = _divisionTitle;
            cloned._divisionLevel = _divisionLevel;

            cloned._tokens = _tokens;
            cloned._tokensType = _tokensType;

            cloned._healthJudgeAdd = _healthJudgeAdd;
            cloned._healthJudgeRemove = _healthJudgeRemove;

            cloned._songCache = _songCache;
            cloned._songHighscores = _songHighscores;

            cloned._replayHistory = _replayHistory;

            return cloned;
        }

        public function get altPlaylist():Playlist
        {
            return _altPlaylist;
        }

        public function set altPlaylist(value:Playlist):void
        {
            throwIfFrozen();
            _altPlaylist = value;
        }

        public function get canonPlaylist():Playlist
        {
            return _canonPlaylist;
        }

        public function set canonPlaylist(value:Playlist):void
        {
            throwIfFrozen();
            _canonPlaylist = value;
        }

        public function get currentPlaylist():Playlist
        {
            return _usingCanon ? canonPlaylist : altPlaylist;
        }

        public function get usingCanon():Boolean
        {
            return _usingCanon;
        }

        public function set usingCanon(value:Boolean):void
        {
            throwIfFrozen();
            _usingCanon = value;
        }

        public function get tokens():Object
        {
            return _tokens;
        }

        public function set tokens(value:Object):void
        {
            throwIfFrozen();
            _tokens = value;
        }

        public function get tokensType():Object
        {
            return _tokensType;
        }

        public function set tokensType(value:Object):void
        {
            throwIfFrozen();
            _tokensType = value;
        }

        public function get totalGenres():int
        {
            return _totalGenres;
        }

        public function set totalGenres(value:int):void
        {
            throwIfFrozen();
            _totalGenres = value;
        }

        public function get maxCreditsPerPlay():int
        {
            return _maxCreditsPerPlay;
        }

        public function set maxCreditsPerPlay(value:int):void
        {
            throwIfFrozen();
            _maxCreditsPerPlay = value;
        }

        public function get scorePerCredit():int
        {
            return _scorePerCredit;
        }

        public function set scorePerCredit(value:int):void
        {
            throwIfFrozen();
            _scorePerCredit = value;
        }

        public function get maxSongDifficulty():int
        {
            return _maxSongDifficulty;
        }

        public function set maxSongDifficulty(value:int):void
        {
            throwIfFrozen();
            _maxSongDifficulty = value;
        }

        public function get difficultyRanges():Array
        {
            return _difficultyRanges;
        }

        public function set difficultyRanges(value:Array):void
        {
            throwIfFrozen();
            _difficultyRanges = value;
        }

        public function get nonPublicGenres():Array
        {
            return _nonPublicGenres;
        }

        public function set nonPublicGenres(value:Array):void
        {
            throwIfFrozen();
            _nonPublicGenres = value;
        }

        public function get divisionColor():Array
        {
            return _divisionColor;
        }

        public function set divisionColor(value:Array):void
        {
            throwIfFrozen();
            _divisionColor = value;
        }

        public function get divisionTitle():Array
        {
            return _divisionTitle;
        }

        public function set divisionTitle(value:Array):void
        {
            throwIfFrozen();
            _divisionTitle = value;
        }

        public function get divisionLevel():Array
        {
            return _divisionLevel;
        }

        public function set divisionLevel(value:Array):void
        {
            throwIfFrozen();
            _divisionLevel = value;
        }

        public function get healthJudgeAdd():int
        {
            return _healthJudgeAdd;
        }

        public function set healthJudgeAdd(value:int):void
        {
            throwIfFrozen();
            _healthJudgeAdd = value;
        }

        public function get healthJudgeRemove():int
        {
            return _healthJudgeRemove;
        }

        public function set healthJudgeRemove(value:int):void
        {
            throwIfFrozen();
            _healthJudgeRemove = value;
        }

        public function get songCache():Array
        {
            return _songCache;
        }

        public function set songCache(value:Array):void
        {
            throwIfFrozen();
            _songCache = value;
        }

        public function get songHighscores():Object
        {
            return _songHighscores;
        }

        public function set songHighscores(value:Object):void
        {
            throwIfFrozen();
            _songHighscores = value;
        }

        public function get replayHistory():Array
        {
            return _replayHistory;
        }

        public function set replayHistory(value:Array):void
        {
            throwIfFrozen();
            _replayHistory = value;
        }

        // -----------------------------------------------------------------------

        public function get totalPublicSongs():int
        {
            return currentPlaylist.indexList.filter(function(songInfo:SongInfo, index:int, vec:Vector.<SongInfo>):Boolean
            {
                return !ArrayUtil.containsAny([songInfo.genre], _nonPublicGenres)
            }).length;
        }

        public function getDivisionColor(level:int):int
        {
            return divisionColor[getDivisionNumber(level)];
        }

        public function getDivisionTitle(level:int):String
        {
            return divisionTitle[getDivisionNumber(level)];
        }

        public function getDivisionNumber(level:int):int
        {
            var div:int;
            for (div = divisionLevel.length - 1; div >= 0; --div)
            {
                if (level >= divisionLevel[div])
                    break;
            }
            return div;
        }
    }
}
