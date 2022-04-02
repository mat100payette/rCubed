package state
{

    import classes.StatTracker;
    import classes.filter.EngineLevelFilter;
    import game.GameScoreResult;

    public class GameplayState extends State implements IState
    {
        private var _songStartTime:String;
        private var _songStartHash:String;

        private var _sessionStats:StatTracker;
        private var _songStats:StatTracker;

        private var _songRestarts:int;

        private var _gameIndex:int;

        private var _songResults:Vector.<GameScoreResult>;
        private var _songResultRanks:Array;

        private var _activeFilter:EngineLevelFilter;

        private var _songQueue:Array;
        private var _songQueueIndex:uint;

        public function GameplayState(frozen:Boolean = false)
        {
            super(frozen);

            _songStartTime = "0";
            _songStartHash = "0";

            // TODO: make these trackers suitable for state
            _sessionStats = new StatTracker();
            _songStats = new StatTracker();

            _songRestarts = 0;

            _gameIndex = 0;

            _songResults = new <GameScoreResult>[];
            _songResultRanks = [];

            _activeFilter = null;

            _songQueue = [];
            _songQueueIndex = 0;
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:GameplayState = new GameplayState(false);

            cloned._songStartTime = _songStartTime;
            cloned._songStartHash = _songStartHash;

            cloned._sessionStats = _sessionStats;
            cloned._songStats = _songStats;

            cloned._songRestarts = _songRestarts;

            cloned._gameIndex = _gameIndex;

            // TODO: Properly clone data structures
            cloned._songResults = _songResults;
            cloned._songResultRanks = _songResultRanks;

            cloned._activeFilter = _activeFilter;

            cloned._songQueue = _songQueue;
            cloned._songQueueIndex = _songQueueIndex;

            return cloned;
        }

        public function get songStartTime():String
        {
            return _songStartTime;
        }

        public function set songStartTime(value:String):void
        {
            throwIfFrozen();
            _songStartTime = value;
        }

        public function get songStartHash():String
        {
            return _songStartHash;
        }

        public function set songStartHash(value:String):void
        {
            throwIfFrozen();
            _songStartHash = value;
        }

        public function get sessionStats():StatTracker
        {
            return _sessionStats;
        }

        public function set sessionStats(value:StatTracker):void
        {
            throwIfFrozen();
            _sessionStats = value;
        }

        public function get songStats():StatTracker
        {
            return _songStats;
        }

        public function set songStats(value:StatTracker):void
        {
            throwIfFrozen();
            _songStats = value;
        }

        public function get songRestarts():int
        {
            return _songRestarts;
        }

        public function set songRestarts(value:int):void
        {
            throwIfFrozen();
            _songRestarts = value;
        }

        public function get gameIndex():int
        {
            return _gameIndex;
        }

        public function set gameIndex(value:int):void
        {
            throwIfFrozen();
            _gameIndex = value;
        }

        public function get songResults():Vector.<GameScoreResult>
        {
            return _songResults;
        }

        public function set songResults(value:Vector.<GameScoreResult>):void
        {
            throwIfFrozen();
            _songResults = value;
        }

        public function get songResultRanks():Array
        {
            return _songResultRanks;
        }

        public function set songResultRanks(value:Array):void
        {
            throwIfFrozen();
            _songResultRanks = value;
        }

        public function get activeFilter():EngineLevelFilter
        {
            return _activeFilter;
        }

        public function set activeFilter(value:EngineLevelFilter):void
        {
            throwIfFrozen();
            _activeFilter = value;
        }

        public function get songQueue():Array
        {
            return _songQueue;
        }

        public function set songQueue(value:Array):void
        {
            throwIfFrozen();
            _songQueue = value;
        }

        public function get songQueueIndex():uint
        {
            return _songQueueIndex;
        }

        public function set songQueueIndex(value:uint):void
        {
            throwIfFrozen();
            _songQueueIndex = value;
        }
    }
}
