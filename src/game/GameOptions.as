package game
{
    import arc.ArcGlobals;
    import classes.Room;
    import classes.User;
    import classes.chart.Song;
    import classes.replay.Replay;
    import classes.UserSettings;

    public class GameOptions extends Object
    {
        public static const NOTE_DIRECTIONS:Array = ["D", "L", "U", "R"];

        private var _user:User;
        private var _settings:UserSettings;

        public var disableNotePool:Boolean = false;

        public var noteSwapColors:Object = {"red": "red", "blue": "blue", "purple": "purple", "yellow": "yellow", "pink": "pink", "orange": "orange", "cyan": "cyan", "green": "green", "white": "white"};

        public var layout:Object = {};

        public var judgeWindow:Array = null;
        public var modCache:Object = null;
        public var song:Song = null;
        public var replay:Replay = null;
        public var loadPreview:Boolean = false;
        public var isEditor:Boolean = false;
        public var isAutoplay:Boolean = false;
        public var mpRoom:Room = null;
        public var singleplayer:Boolean = false;

        public var isolationOffset:int = 0;
        public var isolationLength:int = 0;

        public function GameOptions(user:User):void
        {
            _user = user;
            _settings = user === null ? new UserSettings() : user.settings;
        }

        public function get settings():UserSettings
        {
            return _settings;
        }

        public function get isolation():Boolean
        {
            return isolationOffset > 0 || isolationLength > 0;
        }

        public function set isolation(value:Boolean):void
        {
            if (!value)
                isolationOffset = isolationLength = 0;
        }

        public function fillFromArcGlobals():void
        {
            var avars:ArcGlobals = ArcGlobals.instance;

            isolationOffset = avars.configIsolationStart;
            isolationLength = avars.configIsolationLength;

            var layoutKey:String = mpRoom ? (mpRoom.connection.currentUser.isPlayer ? "mp" : "mpspec") : "sp";
            if (!avars.configInterface[layoutKey])
                avars.configInterface[layoutKey] = {};
            layout = avars.configInterface[layoutKey];
            layoutKey = _settings.scrollDirection;
            if (!layout[layoutKey])
                layout[layoutKey] = {};
            layout = layout[layoutKey];

            judgeWindow = avars.configJudge;
        }

        public function fillFromReplay():void
        {
            if (replay == null)
                return;

            _settings = replay.user.settings;
            modCache = null;
        }

        public function fill():void
        {
            fillFromArcGlobals();
        }

        public function modEnabled(mod:String):Boolean
        {
            if (!modCache)
            {
                modCache = {};
                for each (var gameMod:String in _settings.activeMods)
                    modCache[gameMod] = true;
            }
            return mod in modCache;
        }

        public function isScoreValid(score:Boolean = true, replay:Boolean = true):Boolean
        {
            var ret:Boolean = false;
            ret ||= score && (isAutoplay ||
                //modEnabled("shuffle") ||
                //modEnabled("random") ||
                //modEnabled("scramble") ||
                judgeWindow);
            ret ||= replay && ( //songRate != 1 ||
                modEnabled("reverse") ||
                //modEnabled("nobackground") ||
                isolation);
            return !ret;
        }

        public function isScoreUpdated(score:Boolean = true, replay:Boolean = true):Boolean
        {
            var ret:Boolean = false;
            ret ||= score && (isAutoplay || modEnabled("shuffle") || modEnabled("random") || modEnabled("scramble") || judgeWindow);
            ret ||= replay && (_settings.songRate != 1 || modEnabled("reverse") //||
                //modEnabled("nobackground") ||
                //isolation
                );
            return !ret;
        }

        public function getNewNoteColor(color:String):String
        {
            return noteSwapColors[color];
        }
    }
}
