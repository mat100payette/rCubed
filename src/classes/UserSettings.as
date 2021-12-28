package classes
{
    import arc.ArcGlobals;
    import assets.GameBackgroundColor;
    import classes.filter.EngineLevelFilter;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.ui.Keyboard;

    // TODO: Refactor all occurences of `.settings[...]`

    public class UserSettings
    {
        // TODO: Explain in comment what this flag entails
        private var _isLiteUser:Boolean;

        private var _compatSettings:Object = {};

        public var language:String = "us";

        public var startUpScreen:int = 0; // 0 = MP Connect + MP Screen   |   1 = MP Connect + Song List   |   2 = Song List

        public var DISPLAY_LEGACY_SONGS:Boolean = false;
        public var DISPLAY_GENRE_FLAG:Boolean = true;
        public var DISPLAY_SONG_FLAG:Boolean = true;
        public var DISPLAY_SONG_NOTE:Boolean = true;

        //- Game Data
        public var GLOBAL_OFFSET:Number = 0;
        public var JUDGE_OFFSET:Number = 0;
        public var AUTO_JUDGE_OFFSET:Boolean = false;
        public var DISPLAY_JUDGE:Boolean = true;
        public var DISPLAY_JUDGE_ANIMATIONS:Boolean = true;
        public var DISPLAY_RECEPTOR_ANIMATIONS:Boolean = true;
        public var DISPLAY_HEALTH:Boolean = true;
        public var DISPLAY_GAME_TOP_BAR:Boolean = true;
        public var DISPLAY_GAME_BOTTOM_BAR:Boolean = true;
        public var DISPLAY_SCORE:Boolean = true;
        public var DISPLAY_COMBO:Boolean = true;
        public var DISPLAY_PACOUNT:Boolean = true;
        public var DISPLAY_ACCURACY_BAR:Boolean = true;
        public var DISPLAY_AMAZING:Boolean = true;
        public var DISPLAY_PERFECT:Boolean = true;
        public var DISPLAY_TOTAL:Boolean = true;
        public var DISPLAY_SCREENCUT:Boolean = false;
        public var DISPLAY_SONGPROGRESS:Boolean = true;
        public var DISPLAY_SONGPROGRESS_TEXT:Boolean = false;

        public var DISPLAY_MP_UI:Boolean = true;
        public var DISPLAY_MP_PA:Boolean = true;
        public var DISPLAY_MP_JUDGE:Boolean = true;
        public var DISPLAY_MP_COMBO:Boolean = true;

        public var DISPLAY_MP_TIMESTAMP:Boolean = false;
        public var judgeColors:Array = [0x78ef29, 0x12e006, 0x01aa0f, 0xf99800, 0xfe0000, 0x804100];
        public var comboColors:Array = [0x0099CC, 0x00AD00, 0xFCC200, 0xC7FB30, 0x6C6C6C, 0xF99800, 0xB06100, 0x990000, 0xDC00C2]; // Normal, FC, AAA, SDG, BlackFlag, AvFlag, BooFlag, MissFlag, RawGood
        public var enableComboColors:Vector.<Boolean> = new <Boolean>[true, true, true, false, false, false, false, false, false];
        public var gameColors:Array = [0x1495BD, 0x033242, 0x0C6A88, 0x074B62, 0x000000];
        public var noteColors:Array = ["red", "blue", "purple", "yellow", "pink", "orange", "cyan", "green", "white"];
        public var rawGoodTracker:Number = 0;

        public var autofailAmazing:int = 0;
        public var autofailPerfect:int = 0;
        public var autofailGood:int = 0;
        public var autofailAverage:int = 0;
        public var autofailMiss:int = 0;
        public var autofailBoo:int = 0;
        public var autofailRawGoods:Number = 0;

        public var keyLeft:int = Keyboard.LEFT;
        public var keyDown:int = Keyboard.DOWN;
        public var keyUp:int = Keyboard.UP;
        public var keyRight:int = Keyboard.RIGHT;
        public var keyRestart:int = Keyboard.SLASH;
        public var keyQuit:int = Keyboard.CONTROL;
        public var keyOptions:int = 145; // Scrolllock

        public var activeNoteskin:int = 1;
        public var activeMods:Array = [];
        public var activeVisualMods:Array = [];
        public var scrollDirection:String = "up";
        public var judgeSpeed:Number = 1;
        public var scrollSpeed:Number = 1.5;
        public var receptorGap:Number = 80;
        public var receptorAnimationSpeed:Number = 1;
        public var noteScale:Number = 1;
        public var gameVolume:Number = 1;
        public var screencutPosition:Number = 0.5;
        public var frameRate:int = 60;
        public var forceNewJudge:Boolean = false;
        public var songRate:Number = 1;

        public var songQueues:Vector.<Object> = new <Object>[];
        public var filters:Vector.<EngineLevelFilter> = new <EngineLevelFilter>[];

        public function UserSettings(isLiteUser:Boolean = false)
        {
            this._isLiteUser = isLiteUser;
        }

        // This replacer manages the filters to avoid circular dependencies
        public static function replacer(settings:UserSettings):Function
        {
            return function _replacer(name:String, val:*):Object
            {
                if (val === settings.filters)
                    return settings.exportFilters();

                // No need to expose internal state
                if (name == 'isLiteUser' || name == '_compatSettings')
                    return undefined;

                return val;
            };
        }

        public function get isLiteUser():Boolean
        {
            return _isLiteUser;
        }

        /**
         * Returns a JSON stringified version of this settings object.
         */
        public function stringify():String
        {
            var stringified:String = JSON.stringify(this, replacer(this));
            return stringified;
        }

        public function get autofail():Array
        {
            return [autofailAmazing,
                autofailPerfect,
                autofailGood,
                autofailAverage,
                autofailMiss,
                autofailBoo,
                autofailRawGoods];
        }

        public function update(settings:Object):void
        {
            if (settings == null)
                return;

            // For backwards compatibility
            for (var key:String in settings)
            {
                var isCompatSetting:Boolean = this._compatSettings[key] !== undefined;
                var isKeyNotFound:Boolean = false;

                try
                {
                    isKeyNotFound = this[key] === undefined;
                }
                catch (_)
                {
                }

                if (isCompatSetting || isKeyNotFound)
                {
                    this[key] = settings[key];
                    this._compatSettings[key] = true;
                }
            }

            if (settings.language != null)
                this.language = settings.language;

            if (settings.GLOBAL_OFFSET != null)
                this.GLOBAL_OFFSET = settings.GLOBAL_OFFSET;

            if (settings.JUDGE_OFFSET != null)
                this.JUDGE_OFFSET = settings.JUDGE_OFFSET;

            if (settings.AUTO_JUDGE_OFFSET != null)
                this.AUTO_JUDGE_OFFSET = settings.AUTO_JUDGE_OFFSET;

            if (settings.DISPLAY_SONG_FLAG != null)
                this.DISPLAY_SONG_FLAG = settings.DISPLAY_SONG_FLAG;

            if (settings.DISPLAY_GENRE_FLAG != null)
                this.DISPLAY_GENRE_FLAG = settings.DISPLAY_GENRE_FLAG;

            if (settings.DISPLAY_SONG_NOTE != null)
                this.DISPLAY_SONG_NOTE = settings.DISPLAY_SONG_NOTE;

            if (settings.DISPLAY_JUDGE != null)
                this.DISPLAY_JUDGE = settings.DISPLAY_JUDGE;

            if (settings.DISPLAY_JUDGE_ANIMATIONS != null)
                this.DISPLAY_JUDGE_ANIMATIONS = settings.DISPLAY_JUDGE_ANIMATIONS;

            if (settings.DISPLAY_RECEPTOR_ANIMATIONS != null)
                this.DISPLAY_RECEPTOR_ANIMATIONS = settings.DISPLAY_RECEPTOR_ANIMATIONS;

            if (settings.DISPLAY_HEALTH != null)
                this.DISPLAY_HEALTH = settings.DISPLAY_HEALTH;

            if (settings.DISPLAY_GAME_TOP_BAR != null)
                this.DISPLAY_GAME_TOP_BAR = settings.DISPLAY_GAME_TOP_BAR;

            if (settings.DISPLAY_GAME_BOTTOM_BAR != null)
                this.DISPLAY_GAME_BOTTOM_BAR = settings.DISPLAY_GAME_BOTTOM_BAR;

            if (settings.DISPLAY_SCORE != null)
                this.DISPLAY_SCORE = settings.DISPLAY_SCORE;

            if (settings.DISPLAY_COMBO != null)
                this.DISPLAY_COMBO = settings.DISPLAY_COMBO;

            if (settings.DISPLAY_PACOUNT != null)
                this.DISPLAY_PACOUNT = settings.DISPLAY_PACOUNT;

            if (settings.DISPLAY_ACCURACY_BAR != null)
                this.DISPLAY_ACCURACY_BAR = settings.DISPLAY_ACCURACY_BAR;

            if (settings.DISPLAY_AMAZING != null)
                this.DISPLAY_AMAZING = settings.DISPLAY_AMAZING;

            if (settings.DISPLAY_PERFECT != null)
                this.DISPLAY_PERFECT = settings.DISPLAY_PERFECT;

            if (settings.DISPLAY_TOTAL != null)
                this.DISPLAY_TOTAL = settings.DISPLAY_TOTAL;

            if (settings.DISPLAY_SCREENCUT != null)
                this.DISPLAY_SCREENCUT = settings.DISPLAY_SCREENCUT;

            if (settings.DISPLAY_SONGPROGRESS != null)
                this.DISPLAY_SONGPROGRESS = settings.DISPLAY_SONGPROGRESS;

            if (settings.DISPLAY_SONGPROGRESS_TEXT != null)
                this.DISPLAY_SONGPROGRESS_TEXT = settings.DISPLAY_SONGPROGRESS_TEXT;

            if (settings.DISPLAY_MP_UI != null)
                this.DISPLAY_MP_UI = settings.DISPLAY_MP_UI;

            if (settings.DISPLAY_MP_PA != null)
                this.DISPLAY_MP_PA = settings.DISPLAY_MP_PA;

            if (settings.DISPLAY_MP_COMBO != null)
                this.DISPLAY_MP_COMBO = settings.DISPLAY_MP_COMBO;

            if (settings.DISPLAY_MP_JUDGE != null)
                this.DISPLAY_MP_JUDGE = settings.DISPLAY_MP_JUDGE;

            if (settings.DISPLAY_MP_TIMESTAMP != null)
                this.DISPLAY_MP_TIMESTAMP = settings.DISPLAY_MP_TIMESTAMP;

            if (settings.DISPLAY_LEGACY_SONGS != null)
                this.DISPLAY_LEGACY_SONGS = settings.DISPLAY_LEGACY_SONGS;

            if (settings.keyLeft != null)
                this.keyLeft = settings.keyLeft;

            if (settings.keyDown != null)
                this.keyDown = settings.keyDown;

            if (settings.keyUp != null)
                this.keyUp = settings.keyUp;

            if (settings.keyRight != null)
                this.keyRight = settings.keyRight;

            if (settings.keyRestart != null)
                this.keyRestart = settings.keyRestart;

            if (settings.keyQuit != null)
                this.keyQuit = settings.keyQuit;

            if (settings.keyOptions != null)
                this.keyOptions = settings.keyOptions;

            if (settings.activeNoteskin != null)
                this.activeNoteskin = settings.activeNoteskin;

            if (settings.scrollDirection != null)
                this.scrollDirection = settings.scrollDirection;

            if (settings.scrollSpeed != null)
                this.scrollSpeed = settings.scrollSpeed;

            if (settings.judgeSpeed != null)
                this.judgeSpeed = settings.judgeSpeed;

            if (settings.receptorGap != null)
                this.receptorGap = settings.receptorGap;

            if (settings.noteScale != null)
                this.noteScale = settings.noteScale;

            if (settings.screencutPosition != null)
                this.screencutPosition = settings.screencutPosition;

            if (settings.frameRate != null)
                this.frameRate = settings.frameRate;

            if (settings.songRate != null)
                this.songRate = settings.songRate;

            if (settings.forceNewJudge != null)
                this.forceNewJudge = settings.forceNewJudge;

            if (settings.activeVisualMods != null)
                this.activeVisualMods = settings.activeVisualMods;

            if (settings.judgeColors != null)
                mergeIntoArray(this.judgeColors, settings.judgeColors);

            if (settings.comboColors != null)
                mergeIntoArray(this.comboColors, settings.comboColors);

            if (settings.enableComboColors != null)
                mergeIntoArray(this.enableComboColors, settings.enableComboColors);

            if (settings.gameColors != null)
                mergeIntoArray(this.gameColors, settings.gameColors);

            if (settings.noteColors != null)
                mergeIntoArray(this.noteColors, settings.noteColors);

            if (settings.rawGoodTracker != null)
                this.rawGoodTracker = settings.rawGoodTracker;

            if (settings.gameVolume != null)
                this.gameVolume = settings.gameVolume;

            if (settings.isolationOffset != null)
                ArcGlobals.instance.configIsolationStart = settings.isolationOffset;

            if (settings.isolationLength != null)
                ArcGlobals.instance.configIsolationLength = settings.isolationLength;

            if (settings.startUpScreen != null)
                this.startUpScreen = Math.max(0, Math.min(2, settings.startUpScreen));

            if (settings.filters != null)
                this.filters = importFilters(settings.filters);

            if (settings.songQueues != null)
            {
                this.songQueues = new <Object>[];
                for each (var queueItem:Object in settings.songQueues)
                {
                    this.songQueues.push(new SongQueueItem(queueItem.name, queueItem.items));
                }
            }

            if (!_isLiteUser)
            {
                SoundMixer.soundTransform = new SoundTransform(this.gameVolume);

                // Setup Background Colors
                GameBackgroundColor.BG_LIGHT = gameColors[0];
                GameBackgroundColor.BG_DARK = gameColors[1];
                GameBackgroundColor.BG_STATIC = gameColors[2];
                GameBackgroundColor.BG_POPUP = gameColors[3];
                GameBackgroundColor.BG_STAGE = gameColors[4];
                (GlobalVariables.instance.gameMain.getChildAt(0) as GameBackgroundColor).redraw();
            }

            function mergeIntoArray(arr1:*, arr2:*):void
            {
                var minArrLen:int = Math.min(arr1.length, arr2.length);
                for (var i:int = 0; i < minArrLen; i++)
                {
                    arr1[i] = arr2[i];
                }
            }
        }

        /**
         * Imports user filters from a save object.
         * @param	filtersIn Array of Filter objects.
         * @return Array of EngineLevelFilters.
         */
        public function importFilters(filtersIn:Array):Vector.<EngineLevelFilter>
        {
            if (!_isLiteUser)
                GlobalVariables.instance.activeFilter = null;

            var newFilters:Vector.<EngineLevelFilter> = new <EngineLevelFilter>[];
            var filter:EngineLevelFilter;
            for each (var item:Object in filtersIn)
            {
                filter = new EngineLevelFilter();
                filter.setup(item);
                newFilters.push(filter);

                if (filter.is_default)
                {
                    if (GlobalVariables.instance.activeFilter == null && !_isLiteUser)
                        GlobalVariables.instance.activeFilter = filter;
                    else
                        filter.is_default = false;
                }
            }
            return newFilters;
        }

        /**
         * Exports the user filters into an array of filter objects.
         * @return	Array of Filter Object.
         */
        public function exportFilters():Array
        {
            var filters:Array = [];
            for each (var item:EngineLevelFilter in this.filters)
            {
                var filter:Object = item.toJSON();
                if (filter)
                    filters.push(filter);
            }
            return filters;
        }
    }
}
