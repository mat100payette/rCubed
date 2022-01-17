package classes
{
    import assets.GameBackgroundColor;
    import classes.filter.EngineLevelFilter;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.ui.Keyboard;
    import com.flashfla.utils.VectorUtil;
    import compat.UserSettingsCompat;

    public class UserSettings
    {
        // TODO: Explain in comment what this flag entails
        private var _isLiteUser:Boolean;

        private var _compatSettings:Object = {};

        public var language:String = "us";

        public var startUpScreen:int = 0; // 0 = MP Connect + MP Screen   |   1 = MP Connect + Song List   |   2 = Song List

        public var displayLegacySongs:Boolean = false;
        public var displayGenreFlag:Boolean = true;
        public var displaySongFlag:Boolean = true;
        public var displaySongNote:Boolean = true;

        //- Game Data
        public var globalOffset:Number = 0;
        public var judgeOffset:Number = 0;
        public var autoJudgeOffset:Boolean = false;
        public var displayJudge:Boolean = true;
        public var displayJudgeAnimations:Boolean = true;
        public var displayReceptorAnimations:Boolean = true;
        public var displayHealth:Boolean = true;
        public var displayGameTopBar:Boolean = true;
        public var displayGameBottomBar:Boolean = true;
        public var displayScore:Boolean = true;
        public var displayCombo:Boolean = true;
        public var displayPACount:Boolean = true;
        public var displayAccuracyBar:Boolean = true;
        public var displayAmazing:Boolean = true;
        public var displayPerfect:Boolean = true;
        public var displayTotal:Boolean = true;
        public var displayScreencut:Boolean = false;
        public var displaySongProgress:Boolean = true;
        public var displaySongProgressText:Boolean = false;

        public var displayMPUI:Boolean = true;
        public var displayMPPA:Boolean = true;
        public var displayMPJudge:Boolean = true;
        public var displayMPCombo:Boolean = true;

        public var displayMPTimestamp:Boolean = false;
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

        public var noteskinId:int = 1;
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
        public var isolationOffset:int = 0;
        public var isolationLength:int = 0;
        public var judgeWindow:Array = Constant.DEFAULT_JUDGE_WINDOW.concat();
        public var layout:Object = {};

        public var songQueues:Vector.<Object> = new <Object>[];
        public var filters:Vector.<EngineLevelFilter> = new <EngineLevelFilter>[];

        public function UserSettings(isLiteUser:Boolean = false)
        {
            _isLiteUser = isLiteUser;
        }

        // This replacer manages the filters to avoid circular dependencies
        public static function replacer(settings:UserSettings):Function
        {
            return function _replacer(name:String, val:*):Object
            {
                if (val === settings.filters)
                    return settings.exportFilters();

                // No need to expose internal state
                if (name == "isLiteUser" || name == "_compatSettings")
                    return undefined;

                return val;
            };
        }

        public function get isLiteUser():Boolean
        {
            return _isLiteUser;
        }

        public function get mods():GameMods
        {
            return new GameMods(this);
        }

        /**
         * Returns a JSON stringified version of this settings object.
         */
        public function stringify():String
        {
            var preStringified:String = JSON.stringify(this, replacer(this));
            var json:Object = JSON.parse(preStringified);

            for (var key:String in _compatSettings)
                json[key] = _compatSettings[key];

            var stringified:String = JSON.stringify(json);

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

        public function update(settings:Object, versionFlag:String = null):void
        {
            if (settings == null)
                return;

            if (versionFlag != null)
                UserSettingsCompat.update(this, settings, versionFlag);

            // For backwards compatibility
            for (var key:String in settings)
            {
                var isCompatSetting:Boolean = _compatSettings[key] !== undefined;
                var isKeyNotFound:Boolean = false;

                try
                {
                    var _:* = this[key];
                }
                catch (_)
                {
                    isKeyNotFound = true;
                }

                if (isCompatSetting || isKeyNotFound)
                    _compatSettings[key] = settings[key];
            }

            if (settings.language != null)
                language = settings.language;

            if (settings.globalOffset != null)
                globalOffset = settings.globalOffset;

            if (settings.judgeOffset != null)
                judgeOffset = settings.judgeOffset;

            if (settings.autoJudgeOffset != null)
                autoJudgeOffset = settings.autoJudgeOffset;

            if (settings.displaySongFlag != null)
                displaySongFlag = settings.displaySongFlag;

            if (settings.displayGenreFlag != null)
                displayGenreFlag = settings.displayGenreFlag;

            if (settings.displaySongNote != null)
                displaySongNote = settings.displaySongNote;

            if (settings.displayJudge != null)
                displayJudge = settings.displayJudge;

            if (settings.displayJudgeAnimations != null)
                displayJudgeAnimations = settings.displayJudgeAnimations;

            if (settings.displayReceptorAnimations != null)
                displayReceptorAnimations = settings.displayReceptorAnimations;

            if (settings.displayHealth != null)
                displayHealth = settings.displayHealth;

            if (settings.displayGameTopBar != null)
                displayGameTopBar = settings.displayGameTopBar;

            if (settings.displayGameBottomBar != null)
                displayGameBottomBar = settings.displayGameBottomBar;

            if (settings.displayScore != null)
                displayScore = settings.displayScore;

            if (settings.displayCombo != null)
                displayCombo = settings.displayCombo;

            if (settings.displayPACount != null)
                displayPACount = settings.displayPACount;

            if (settings.displayAccuracyBar != null)
                displayAccuracyBar = settings.displayAccuracyBar;

            if (settings.displayAmazing != null)
                displayAmazing = settings.displayAmazing;

            if (settings.displayPerfect != null)
                displayPerfect = settings.displayPerfect;

            if (settings.displayTotal != null)
                displayTotal = settings.displayTotal;

            if (settings.displayScreencut != null)
                displayScreencut = settings.displayScreencut;

            if (settings.displaySongProgress != null)
                displaySongProgress = settings.displaySongProgress;

            if (settings.displaySongProgressText != null)
                displaySongProgressText = settings.displaySongProgressText;

            if (settings.displayMPUI != null)
                displayMPUI = settings.displayMPUI;

            if (settings.displayMPPA != null)
                displayMPPA = settings.displayMPPA;

            if (settings.displayMPCombo != null)
                displayMPCombo = settings.displayMPCombo;

            if (settings.displayMPJudge != null)
                displayMPJudge = settings.displayMPJudge;

            if (settings.displayMPTimestamp != null)
                displayMPTimestamp = settings.displayMPTimestamp;

            if (settings.displayLegacySongs != null)
                displayLegacySongs = settings.displayLegacySongs;

            if (settings.keyLeft != null)
                keyLeft = settings.keyLeft;

            if (settings.keyDown != null)
                keyDown = settings.keyDown;

            if (settings.keyUp != null)
                keyUp = settings.keyUp;

            if (settings.keyRight != null)
                keyRight = settings.keyRight;

            if (settings.keyRestart != null)
                keyRestart = settings.keyRestart;

            if (settings.keyQuit != null)
                keyQuit = settings.keyQuit;

            if (settings.keyOptions != null)
                keyOptions = settings.keyOptions;

            if (settings.noteskinId != null)
                noteskinId = settings.noteskinId;

            if (settings.scrollDirection != null)
                scrollDirection = settings.scrollDirection;

            if (settings.scrollSpeed != null)
                scrollSpeed = settings.scrollSpeed;

            if (settings.judgeSpeed != null)
                judgeSpeed = settings.judgeSpeed;

            if (settings.receptorGap != null)
                receptorGap = settings.receptorGap;

            if (settings.noteScale != null)
                noteScale = settings.noteScale;

            if (settings.screencutPosition != null)
                screencutPosition = settings.screencutPosition;

            if (settings.frameRate != null)
                frameRate = settings.frameRate;

            if (settings.songRate != null)
                songRate = settings.songRate;

            if (settings.forceNewJudge != null)
                forceNewJudge = settings.forceNewJudge;

            if (settings.activeVisualMods != null)
                activeVisualMods = settings.activeVisualMods;

            if (settings.judgeColors != null)
                mergeIntoArray(judgeColors, settings.judgeColors);

            if (settings.comboColors != null)
                mergeIntoArray(comboColors, settings.comboColors);

            if (settings.enableComboColors != null)
                mergeIntoArray(enableComboColors, settings.enableComboColors);

            if (settings.gameColors != null)
                mergeIntoArray(gameColors, settings.gameColors);

            if (settings.noteColors != null)
                mergeIntoArray(noteColors, settings.noteColors);

            if (settings.rawGoodTracker != null)
                rawGoodTracker = settings.rawGoodTracker;

            if (settings.gameVolume != null)
                gameVolume = settings.gameVolume;

            if (settings.isolationOffset != null)
                isolationOffset = settings.isolationOffset;

            if (settings.isolationLength != null)
                isolationLength = settings.isolationLength;

            if (settings.layout != null)
                layout = settings.layout;

            if (settings.judgeWindow != null)
                judgeWindow = settings.judgeWindow;

            if (settings.startUpScreen != null)
                startUpScreen = Math.max(0, Math.min(2, settings.startUpScreen));

            if (settings.filters != null)
                if (settings.filters is Vector.<*>)
                    filters = importFilters(settings.filters);
                else
                    filters = importFilters(VectorUtil.fromArray(settings.filters));

            if (settings.songQueues != null)
            {
                songQueues = new <Object>[];
                for each (var queueItem:Object in settings.songQueues)
                {
                    songQueues.push(new SongQueueItem(queueItem.name, queueItem.items));
                }
            }

            if (!_isLiteUser)
            {
                SoundMixer.soundTransform = new SoundTransform(gameVolume);

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
        public function importFilters(filtersIn:Vector.<*>):Vector.<EngineLevelFilter>
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
                var filter:Object = item.toJSON(null);
                if (filter)
                    filters.push(filter);
            }
            return filters;
        }
    }
}
