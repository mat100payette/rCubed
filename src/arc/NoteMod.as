package arc
{
    import classes.chart.Note;
    import classes.chart.Song;
    import classes.UserSettings;
    import classes.GameMods;

    public class NoteMod extends Object
    {
        private const DIRECTIONS:Array = ["L", "D", "U", "R"];
        private const HALF_COLOR:Object = {"red": "red", "blue": "red", "purple": "purple", "yellow": "blue", "pink": "purple", "orange": "yellow", "cyan": "pink", "green": "orange", "white": "white"}

        // TODO: Remove this circular dependency to Song
        private var _song:Song;
        private var _notes:Array;
        private var _shuffle:Array;
        private var _lastChord:Object;

        private var _settings:UserSettings;

        private var _mods:GameMods;

        private var _isIsolation:Boolean;
        private var _isGlobalOffset:Boolean;
        private var _isRate:Boolean;
        private var _isCustomJudgeWindow:Boolean;

        private var _reverseLastFrame:int;
        private var _reverseLastPos:Number;

        public function NoteMod(song:Song, settings:UserSettings)
        {
            _song = song;
            _settings = new UserSettings();
            _settings.update(settings);

            _mods = new GameMods(_settings);

            _isIsolation = _settings.isolationOffset > 0 || _settings.isolationLength > 0;
            _isGlobalOffset = _settings.globalOffset != 0;
            _isRate = _settings.songRate != 1;
            _isCustomJudgeWindow = _settings.judgeWindow != Constant.DEFAULT_JUDGE_WINDOW;

            _reverseLastFrame = -1;
            _reverseLastPos = -1;
        }

        public function get settings():UserSettings
        {
            return _settings;
        }

        public function start():void
        {
            if (_mods.shuffle)
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

        public function required():Boolean
        {
            return _isIsolation || _mods.random || _mods.scramble || _mods.shuffle || _mods.columnColor || _mods.halftime || _mods.mirror || _isGlobalOffset || _isRate;
        }

        public function transformNote(index:int):Note
        {
            if (_isIsolation)
                index += _settings.isolationOffset;

            if (_mods.reverse)
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

            if (_mods.reverse)
            {
                frame = _reverseLastFrame - frame + _song.mp3Frame + 60;
                pos = _reverseLastPos - pos + (_song.mp3Frame + 60) / 30;
            }

            if (_isRate)
            {
                pos /= _settings.songRate;
                frame /= _settings.songRate;
            }

            if (_isGlobalOffset)
            {
                var goffset:int = Math.round(_settings.globalOffset);
                frame += goffset;
                pos += goffset / 30;
            }

            if (_mods.mirror)
                dir = -dir + 3;

            if (_mods.shuffle)
                dir = _shuffle[dir];

            if (_mods.random || _mods.scramble)
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
                    do
                    {
                        dir = int(Math.random() * 4);
                    } while (_lastChord.values.indexOf(dir) != -1);

                    if (_mods.scramble)
                    {
                        for (var i:int = 0; i < 3 && _lastChord.previousValues.indexOf(dir) != -1; i++)
                        {
                            do
                            {
                                dir = int(Math.random() * 4);
                            } while (_lastChord.values.indexOf(dir) != -1);
                        }
                    }

                    _lastChord.values.push(dir);
                    _lastChord.notes.push(note);
                }
            }

            if (_mods.columnColor)
                color = (dir % 3) ? "blue" : "red";

            if (_mods.halftime)
                color = HALF_COLOR[color] || color;

            return new Note(directionOfValue(dir), pos, color, int(frame));
        }

        public function transformTotalNotes():int
        {
            if (!_notes)
                return 0;

            if (_isIsolation)
            {
                if (_settings.isolationLength > 0)
                    return Math.min(_settings.isolationLength, Math.max(1, _notes.length - _settings.isolationOffset));
                else
                    return Math.max(1, _notes.length - _settings.isolationOffset);
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

            if (_isIsolation)
            {

                if (_settings.isolationLength > 0)
                {
                    firstNote = _notes[Math.min(_notes.length - 1, _settings.isolationOffset)];
                    lastNote = _notes[Math.min(_notes.length - 1, _settings.isolationOffset + _settings.isolationLength)];
                    time = lastNote.time - firstNote.time;
                }
                else
                {
                    firstNote = _notes[Math.min(_notes.length - 1, _settings.isolationOffset)];
                    time = lastNote.time - firstNote.time;
                }
            }

            // Rates after everything.
            if (_isRate)
                time /= _settings.songRate;

            return time + 1; // 1 seconds for fade out.
        }
    }
}
