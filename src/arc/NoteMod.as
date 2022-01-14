package arc
{
    import classes.chart.Note;
    import classes.chart.Song;
    import game.GameOptions;
    import classes.UserSettings;

    public class NoteMod extends Object
    {
        private const DIRECTIONS:Array = ["L", "D", "U", "R"];
        private const HALF_COLOR:Object = {"red": "red", "blue": "red", "purple": "purple", "yellow": "blue", "pink": "purple", "orange": "yellow", "cyan": "pink", "green": "orange", "white": "white"}

        private var _song:Song;
        private var _notes:Array;
        private var _shuffle:Array;
        private var _lastChord:Object;

        private var _options:GameOptions;
        private var _settings:UserSettings;

        private var _modDark:Boolean;
        private var _modHidden:Boolean;
        private var _modMirror:Boolean;
        private var _modRandom:Boolean;
        private var _modScramble:Boolean;
        private var _modShuffle:Boolean;
        private var _modReverse:Boolean;
        private var _modColumnColor:Boolean;
        private var _modHalfTime:Boolean;
        private var _modNoBackground:Boolean;
        private var _modIsolation:Boolean;
        private var _modOffset:Boolean;
        private var _modRate:Boolean;
        private var _modFPS:Boolean;
        private var _modJudgeWindow:Boolean;

        private var _reverseLastFrame:int;
        private var _reverseLastPos:Number;

        public function NoteMod(song:Song, options:GameOptions)
        {
            _song = song;
            _options = options;
            _settings = new UserSettings();
            _settings.update(options.settings);

            updateMods();
        }

        public function updateMods():void
        {
            _modDark = _options.modEnabled("dark");
            _modHidden = _options.modEnabled("hidden");
            _modMirror = _options.modEnabled("mirror");
            _modRandom = _options.modEnabled("random");
            _modScramble = _options.modEnabled("scramble");
            _modShuffle = _options.modEnabled("shuffle");
            _modReverse = _options.modEnabled("reverse");
            _modColumnColor = _options.modEnabled("columncolor");
            _modHalfTime = _options.modEnabled("halftime");
            _modNoBackground = _options.modEnabled("nobackground");
            _modIsolation = _options.isolation;
            _modOffset = _options.settings.globalOffset != 0;
            _modRate = _options.settings.songRate != 1;
            _modFPS = _options.settings.frameRate > 30;
            _modJudgeWindow = Boolean(_options.judgeWindow);

            _reverseLastFrame = -1;
            _reverseLastPos = -1;
        }

        public function start(options:GameOptions):void
        {
            //this.options = options;

            //updateMods();

            if (_modShuffle)
            {
                _shuffle = new Array();
                for (var i:int = 0; i < 4; i++)
                {
                    var map:int;
                    while (_shuffle.indexOf((map = int(Math.random() * 4))) >= 0)
                    {
                    }
                    _shuffle.push(map);
                }
            }

            _notes = _song.chart.notes;

            _lastChord = {frame: 0, values: [], previousValues: [], _notes: []};
        }

        private function valueOfDirection(direction:String):int
        {
            return DIRECTIONS.indexOf(direction.charAt(0));
        }

        private function directionOfValue(value:int):String
        {
            return DIRECTIONS[value].toString();
        }

        public static function noteModRequired(options:GameOptions):Boolean
        {
            var mod:NoteMod = new NoteMod(null, options);
            return mod.required();
        }

        public function required():Boolean
        {
            return _modIsolation || _modRandom || _modScramble || _modShuffle || _modColumnColor || _modHalfTime || _modMirror || _modOffset || _modRate;
        }

        public function transformNote(index:int):Note
        {
            if (_modIsolation)
                index += _options.isolationOffset;

            if (_modReverse)
            {
                index = _notes.length - 1 - index;
                if (_reverseLastFrame < 0)
                {
                    _reverseLastFrame = _notes[_notes.length - 1].frame - _song.musicDelay * 2;
                    _reverseLastPos = _notes[_notes.length - 1].time - ((_song.musicDelay * 2) / 30);
                }
            }

            var note:Note = _notes[index];
            if (note == null)
                return null;

            var pos:Number = note.time;
            var color:String = note.color;
            var frame:Number = note.frame;
            var dir:int = valueOfDirection(note.direction);

            frame -= _song.musicDelay;
            pos -= (_song.musicDelay / 30);

            if (_modReverse)
            {
                frame = _reverseLastFrame - frame + _song.mp3Frame + 60;
                pos = _reverseLastPos - pos + (_song.mp3Frame + 60) / 30;
            }

            if (_modRate)
            {
                pos /= _settings.songRate;
                frame /= _settings.songRate;
            }

            if (_modOffset)
            {
                var goffset:int = Math.round(_settings.globalOffset);
                frame += goffset;
                pos += goffset / 30;
            }

            if (_modMirror)
                dir = -dir + 3;

            if (_modShuffle)
                dir = _shuffle[dir];

            if (_modRandom || _modScramble)
            {
                if (_lastChord.frame != int(frame))
                {
                    _lastChord.frame = int(frame);
                    _lastChord.previousValues = _lastChord.values;
                    _lastChord.values = [];
                    _lastChord.notes = [];
                }
                var value:Object = _lastChord.values[_lastChord.notes.indexOf(note)];
                if (value != null)
                    dir = int(value);
                else
                {
                    while (_lastChord.values.indexOf(dir = int(Math.random() * 4)) != -1)
                    {
                    }
                    for (var i:int = 0; i < 3 && _modScramble && _lastChord.previousValues.indexOf(dir) != -1; i++)
                        while (_lastChord.values.indexOf(dir = int(Math.random() * 4)) != -1)
                        {
                        }
                    _lastChord.values.push(dir);
                    _lastChord.notes.push(note);
                }
            }

            if (_modColumnColor)
                color = (dir % 3) ? "blue" : "red";

            if (_modHalfTime)
                color = HALF_COLOR[color] || color;

            return new Note(directionOfValue(dir), pos, color, int(frame));
        }

        public function transformTotalNotes():int
        {
            if (!_notes)
                return 0;

            if (_modIsolation)
            {
                if (_options.isolationLength > 0)
                    return Math.min(_options.isolationLength, Math.max(1, _notes.length - _options.isolationOffset));
                else
                    return Math.max(1, _notes.length - _options.isolationOffset);
            }
            return _notes.length;
        }

        public function transformSongLength():Number
        {
            if (!_notes || _notes.length <= 0)
                return 0;

            var firstNote:Note;
            var lastNote:Note = _notes[_notes.length - 1];
            var time:Number = lastNote.time;

            if (_modIsolation)
            {

                if (_options.isolationLength > 0)
                {
                    firstNote = _notes[Math.min(_notes.length - 1, _options.isolationOffset)];
                    lastNote = _notes[Math.min(_notes.length - 1, _options.isolationOffset + _options.isolationLength)];
                    time = lastNote.time - firstNote.time;
                }
                else
                {
                    firstNote = _notes[Math.min(_notes.length - 1, _options.isolationOffset)];
                    time = lastNote.time - firstNote.time;
                }
            }

            // Rates after everything.
            if (_modRate)
                time /= _settings.songRate;

            return time + 1; // 1 seconds for fade out.
        }
    }
}
