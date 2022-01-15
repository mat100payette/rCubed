package classes
{

    import com.flashfla.utils.ArrayUtil;

    public class GameMods
    {
        // Game mods
        private var _hidden:Boolean;
        private var _sudden:Boolean;
        private var _blink:Boolean;
        private var _rotating:Boolean;
        private var _rotateCW:Boolean;
        private var _rotateCCW:Boolean;
        private var _wave:Boolean;
        private var _drunk:Boolean;
        private var _dizzy:Boolean;
        private var _tornado:Boolean;
        private var _miniResize:Boolean;
        private var _tapPulse:Boolean;
        private var _random:Boolean;
        private var _scramble:Boolean;
        private var _shuffle:Boolean;
        private var _reverse:Boolean;

        // Visual mods
        private var _mirror:Boolean;
        private var _dark:Boolean;
        private var _hide:Boolean;
        private var _mini:Boolean;
        private var _columnColor:Boolean;
        private var _halftime:Boolean;
        private var _noBackground:Boolean;
        private var _flashlight:Boolean;

        public function GameMods(settings:UserSettings)
        {
            var mods:Array = settings.activeMods;
            var visualMods:Array = settings.activeVisualMods;

            // Game mods
            _hidden = ArrayUtil.containsAny(mods, ["hidden"]);
            _sudden = ArrayUtil.containsAny(mods, ["sudden"]);
            _blink = ArrayUtil.containsAny(mods, ["blink"]);
            _rotating = ArrayUtil.containsAny(mods, ["rotating"]);
            _rotateCW = ArrayUtil.containsAny(mods, ["rotate_cw"]);
            _rotateCCW = ArrayUtil.containsAny(mods, ["rotate_ccw"]);
            _wave = ArrayUtil.containsAny(mods, ["wave"]);
            _drunk = ArrayUtil.containsAny(mods, ["drunk"]);
            _dizzy = ArrayUtil.containsAny(mods, ["dizzy"]);
            _tornado = ArrayUtil.containsAny(mods, ["tornado"]);
            _miniResize = ArrayUtil.containsAny(mods, ["mini_resize"]);
            _tapPulse = ArrayUtil.containsAny(mods, ["tap_pulse"]);
            _random = ArrayUtil.containsAny(mods, ["random"]);
            _scramble = ArrayUtil.containsAny(mods, ["scramble"]);
            _shuffle = ArrayUtil.containsAny(mods, ["shuffle"]);
            _reverse = ArrayUtil.containsAny(mods, ["reverse"]);

            // Visual mods
            _mirror = ArrayUtil.containsAny(visualMods, ["mirror"]);
            _dark = ArrayUtil.containsAny(visualMods, ["dark"]);
            _hide = ArrayUtil.containsAny(visualMods, ["hide"]);
            _mini = ArrayUtil.containsAny(visualMods, ["mini"]);
            _columnColor = ArrayUtil.containsAny(visualMods, ["columncolour"]);
            _halftime = ArrayUtil.containsAny(visualMods, ["halftime"]);
            _noBackground = ArrayUtil.containsAny(visualMods, ["nobackground"]);
            _flashlight = ArrayUtil.containsAny(visualMods, ["flashlight"]);
        }

        public function get hidden():Boolean
        {
            return _hidden;
        }

        public function get sudden():Boolean
        {
            return _sudden;
        }

        public function get blink():Boolean
        {
            return _blink;
        }

        public function get rotating():Boolean
        {
            return _rotating;
        }

        public function get rotateCW():Boolean
        {
            return _rotateCW;
        }

        public function get rotateCCW():Boolean
        {
            return _rotateCCW;
        }

        public function get wave():Boolean
        {
            return _wave;
        }

        public function get drunk():Boolean
        {
            return _drunk;
        }

        public function get dizzy():Boolean
        {
            return _dizzy;
        }

        public function get tornado():Boolean
        {
            return _tornado;
        }

        public function get miniResize():Boolean
        {
            return _miniResize;
        }

        public function get tapPulse():Boolean
        {
            return _tapPulse;
        }

        public function get random():Boolean
        {
            return _random;
        }

        public function get scramble():Boolean
        {
            return _scramble;
        }

        public function get shuffle():Boolean
        {
            return _shuffle;
        }

        public function get reverse():Boolean
        {
            return _reverse;
        }

        public function get mirror():Boolean
        {
            return _mirror;
        }

        public function get dark():Boolean
        {
            return _dark;
        }

        public function get hide():Boolean
        {
            return _hide;
        }

        public function get mini():Boolean
        {
            return _mini;
        }

        public function get columnColor():Boolean
        {
            return _columnColor;
        }

        public function get halftime():Boolean
        {
            return _halftime;
        }

        public function get noBackground():Boolean
        {
            return _noBackground;
        }

        public function get flashlight():Boolean
        {
            return _flashlight;
        }
    }
}
