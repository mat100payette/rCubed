package state
{

    import classes.Playlist;

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

            _tokens = {};
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:ContentState = new ContentState(false);

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
    }
}
