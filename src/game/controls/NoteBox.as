package game.controls
{
    import classes.GameNote;
    import classes.GameReceptor;
    import classes.NoteskinsList;
    import classes.chart.Song;
    import classes.chart.Note;
    import flash.utils.getTimer;
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import com.flashfla.utils.ObjectPool;
    import classes.UserSettings;
    import classes.GameMods;

    public class NoteBox extends Sprite
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _noteskins:NoteskinsList = NoteskinsList.instance;

        private var _song:Song;
        private var _noteskinId:int;
        private var _noteColors:Array;
        private var _judgeColors:Array;
        private var _receptorGap:Number;
        private var _receptorAnimationSpeed:Number;
        private var _displayReceptorAnimations:Boolean;
        private var _scrollDirection:String;
        private var _scrollSpeed:Number;
        private var _noteScale:Number;
        private var _mods:GameMods;

        private var _readahead:Number;
        private var _totalNotes:int;
        private var _noteCount:int;
        private var _notePool:Array;

        private var _leftReceptor:MovieClip;
        private var _downReceptor:MovieClip;
        private var _upReceptor:MovieClip;
        private var _rightReceptor:MovieClip;
        private var _receptorArray:Array;

        private var _isSideScroll:Boolean;
        private var _receptorAlpha:Number;

        public var positionOffsetMax:Object;
        public var notes:Array;

        public function NoteBox(song:Song, settings:UserSettings)
        {
            _song = song;
            _noteskinId = settings.noteskinId;
            _noteColors = settings.noteColors;
            _judgeColors = settings.judgeColors;
            _receptorGap = settings.receptorGap;
            _receptorAnimationSpeed = settings.receptorAnimationSpeed;
            _displayReceptorAnimations = settings.displayReceptorAnimations;
            _scrollDirection = settings.scrollDirection;
            _scrollSpeed = settings.scrollSpeed;
            _noteScale = settings.noteScale;
            _mods = new GameMods(settings);

            // Create Object Pools
            _notePool = [];
            for each (var item:Object in _noteskins.noteskins)
            {
                _notePool[item.id] = {"L": [], "D": [], "U": [], "R": []};
                for each (var direction:String in Constant.NOTE_DIRECTIONS)
                {
                    for each (var color:String in _noteColors)
                        _notePool[item.id][direction][color] = new ObjectPool();
                }
            }

            // Check for invalid Noteskin / Pool
            // TODO: Do something for this check
            if (_notePool[_noteskinId] == null)
                null;

            // Prefill Object Pools for active noteskin.
            var i:int = 0;
            var preLoadCount:int = 4;
            for each (var pre_dir:String in Constant.NOTE_DIRECTIONS)
            {
                for each (var pre_color:String in _noteColors)
                {
                    var pool:ObjectPool = _notePool[_noteskinId][pre_dir][pre_color];

                    for (i = 0; i < preLoadCount; i++)
                    {
                        var gameNote:GameNote = pool.addObject(new GameNote(0, pre_dir, pre_color, 1 * 1000, 0, 0, _noteskinId));
                        gameNote.visible = false;
                        pool.unmarkObject(gameNote);
                        addChild(gameNote);
                    }
                }
            }

            // Setup Receptors
            _leftReceptor = _noteskins.getReceptor(_noteskinId, "L");
            _leftReceptor.KEY = "Left";
            _downReceptor = _noteskins.getReceptor(_noteskinId, "D");
            _downReceptor.KEY = "Down";
            _upReceptor = _noteskins.getReceptor(_noteskinId, "U");
            _upReceptor.KEY = "Up";
            _rightReceptor = _noteskins.getReceptor(_noteskinId, "R");
            _rightReceptor.KEY = "Right";

            if (_leftReceptor is GameReceptor)
            {
                (_leftReceptor as GameReceptor).animationSpeed = _receptorAnimationSpeed;
                (_downReceptor as GameReceptor).animationSpeed = _receptorAnimationSpeed;
                (_upReceptor as GameReceptor).animationSpeed = _receptorAnimationSpeed;
                (_rightReceptor as GameReceptor).animationSpeed = _receptorAnimationSpeed;
            }

            addChildAt(_leftReceptor, 0);
            addChildAt(_downReceptor, 0);
            addChildAt(_upReceptor, 0);
            addChildAt(_rightReceptor, 0);

            // Other Stuff
            _isSideScroll = _scrollDirection == "left" || _scrollDirection == "right";
            _scrollSpeed = _scrollSpeed * (_isSideScroll ? 1.5 : 1);
            _readahead = ((_isSideScroll ? Main.GAME_WIDTH : Main.GAME_HEIGHT) / 300 * 1000 / _scrollSpeed);
            _receptorAlpha = 1.0;
            notes = [];
            _noteCount = 0;
            _totalNotes = song.totalNotes;
        }

        public function noteRealSpawnRotation(dir:String, noteskin:int):Number
        {
            var rot:Number = _noteskins.noteskins[noteskin]["rotation"];
            switch (dir)
            {
                case "D":
                    return 0;
                case "L":
                    return rot;
                case "U":
                    return rot * 2;
                case "R":
                    return rot * -1;
            }
            return rot;
        }

        public function spawnArrow(note:Note, currentPosition:int = 0):GameNote
        {
            var direction:String = note.direction;
            var color:String = options.getNewNoteColor(note.color);
            if (options.disableNotePool)
            {
                var gameNote:GameNote = new GameNote(_noteCount++, direction, color, (note.time + 0.5 / 30) * 1000, note.frame, 0, _noteskinId);
            }
            else
            {
                var spawnPoolRef:ObjectPool = _notePool[_noteskinId][direction][color];
                if (!spawnPoolRef)
                {
                    spawnPoolRef = _notePool[_noteskinId][direction][color] = new ObjectPool();
                }

                gameNote = spawnPoolRef.getObject();
                if (gameNote)
                {
                    gameNote.ID = _noteCount++;
                    gameNote.DIR = direction;
                    gameNote.POSITION = (note.time + 0.5 / 30) * 1000;
                    gameNote.PROGRESS = note.frame;
                    gameNote.alpha = 1;
                }
                else
                {
                    gameNote = spawnPoolRef.addObject(new GameNote(_noteCount++, direction, color, (note.time + 0.5 / 30) * 1000, note.frame, 0, _noteskinId));
                    addChild(gameNote);
                }
            }

            gameNote.SPAWN_PROGRESS = gameNote.POSITION - 1000; // readahead;
            gameNote.rotation = getReceptor(direction).rotation;

            // TODO: Mayyybe re-add this?
            /*
               if (options.modEnabled("_spawn_noteskin_data_rotation"))
               gameNote.rotation = noteRealSpawnRotation(direction, _noteskinId);
             */

            if (_noteScale != 1.0)
                gameNote.scaleX = gameNote.scaleY = _noteScale;
            else if (_mods.mini && !_mods.miniResize && _noteScale == 1.0)
                gameNote.scaleX = gameNote.scaleY = 0.75;
            else
                gameNote.scaleX = gameNote.scaleY = 1;

            if (_mods.dark)
                gameNote.alpha = 0.2;

            gameNote.visible = true;
            notes.push(gameNote);

            updateNotePosition(gameNote, currentPosition);

            return gameNote;
        }

        public function getReceptor(dir:String):MovieClip
        {
            switch (dir)
            {
                case "L":
                    return _leftReceptor;
                case "D":
                    return _downReceptor;
                case "U":
                    return _upReceptor;
                case "R":
                    return _rightReceptor;
            }
            return null;
        }

        public function receptorFeedback(dir:String, score:int):void
        {
            if (!_displayReceptorAnimations)
                return;

            var f:int = 2;
            var c:uint = 0;

            switch (score)
            {
                case 100:
                case 50:
                    f = 2;
                    c = _judgeColors[0];
                    break;
                case 25:
                    f = 7;
                    c = _judgeColors[2];
                    break;
                case 5:
                case -5:
                    f = 12;
                    c = _judgeColors[3];
                    break;
                default:
                    return;
            }

            var recepterFeedbackRef:MovieClip = getReceptor(dir);
            if (recepterFeedbackRef is GameReceptor)
                (recepterFeedbackRef as GameReceptor).playAnimation(c);
            else
                recepterFeedbackRef.gotoAndPlay(f);
        }

        public function get nextNote():Note
        {
            return _noteCount < _totalNotes ? _song.getNote(_noteCount) : null;
        }

        public function spawnNextNote(current_position:int = 0):GameNote
        {
            if (nextNote)
            {
                return spawnArrow(nextNote, current_position);
            }

            return null;
        }

        public function update(position:int):void
        {
            var nextRef:Note = nextNote;
            while (nextRef && (nextRef.time + 0.5 / 30) * 1000 - position < _readahead)
            {
                spawnArrow(nextRef, position);
                nextRef = nextNote;
            }

            if (_mods.wave)
            {
                var waveOffset:int = 0;
                for each (var receptor:MovieClip in _receptorArray)
                {
                    if (receptor.VERTEX == "x")
                    {
                        receptor.y = receptor.ORIG_Y + (Math.sin((getTimer() + waveOffset) / 1000) * 35);
                    }
                    else if (receptor.VERTEX == "y")
                    {
                        receptor.x = receptor.ORIG_X + (Math.sin((getTimer() + waveOffset) / 1000) * 35);
                    }
                    waveOffset += 165;
                }
            }

            if (_mods.drunk)
            {
                var drunkOffset:int = 0;
                for each (receptor in _receptorArray)
                {
                    receptor.rotation = receptor.ORIG_ROT + (Math.sin((getTimer() + drunkOffset) / 1387) * 25);
                    drunkOffset += 165;
                }
            }

            if (_mods.dizzy)
            {
                for each (receptor in _receptorArray)
                    receptor.rotation += 12;
            }

            if (_mods.hide)
            {
                _leftReceptor.alpha = (_leftReceptor.currentFrame == 1) ? 0.0 : _receptorAlpha;
                _downReceptor.alpha = (_downReceptor.currentFrame == 1) ? 0.0 : _receptorAlpha;
                _upReceptor.alpha = (_upReceptor.currentFrame == 1) ? 0.0 : _receptorAlpha;
                _rightReceptor.alpha = (_rightReceptor.currentFrame == 1) ? 0.0 : _receptorAlpha;
            }

            for each (var note:GameNote in notes)
            {
                updateNotePosition(note, position);
            }
        }

        private var updateReceptorRef:MovieClip;
        private var updateOffsetRef:Number;
        private var updateBaseOffsetRef:Number;

        public function updateNotePosition(note:GameNote, position:int):void
        {
            updateReceptorRef = getReceptor(note.DIR);
            updateOffsetRef = (note.POSITION - position) / 1000 * 300 * _scrollSpeed;
            updateBaseOffsetRef = (position - note.SPAWN_PROGRESS) / (note.POSITION - note.SPAWN_PROGRESS);

            if (updateReceptorRef.VERTEX == "x")
            {
                note.x = updateReceptorRef.x - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.y = updateReceptorRef.y;
            }
            else if (updateReceptorRef.VERTEX == "y")
            {
                note.y = updateReceptorRef.y - updateOffsetRef * updateReceptorRef.DIRECTION;
                note.x = updateReceptorRef.x;
            }

            // Position Mods
            if (_mods.tornado)
            {
                var tornadoOffset:Number = Math.sin(updateBaseOffsetRef * Math.PI) * (_receptorGap / 2);
                if (updateReceptorRef.VERTEX == "x")
                    note.y += tornadoOffset;

                if (updateReceptorRef.VERTEX == "y")
                    note.x += tornadoOffset;
            }

            // Rotation Mods
            if (_mods.tornado)
                note.rotation = (updateBaseOffsetRef * 6 * 90) + updateReceptorRef.rotation;

            if (_mods.dizzy)
                note.rotation += 18;

            // Alpha Mods
            // switched hidden and sudden, mods were reversed!
            if (_mods.hidden)
                note.alpha = 1 - updateBaseOffsetRef;

            if (_mods.sudden)
                note.alpha = updateBaseOffsetRef;

            if (_mods.blink)
            {
                var blink_offset:Number = (1 - updateBaseOffsetRef) % 0.4;
                var blink_hidden:Boolean = (blink_offset > 0.2);
                note.alpha = (blink_hidden ? 0 : (note.alpha != 1 && note.alpha != 0 ? note.alpha : 1));
            }

            // Scale Mods
            if (_noteScale == 1 && _mods.miniResize && !_mods.mini)
                note.scaleX = note.scaleY = 1 - (updateBaseOffsetRef * 0.65);

        }

        private var removeNoteIndex:int = 0;
        private var removeNoteRef:GameNote;

        public function removeNote(id:int):void
        {
            for (removeNoteIndex = 0; removeNoteIndex < notes.length; removeNoteIndex++)
            {
                removeNoteRef = notes[removeNoteIndex];
                if (removeNoteRef.ID == id)
                {
                    if (!options.disableNotePool)
                    {
                        _notePool[removeNoteRef.NOTESKIN][removeNoteRef.DIR][removeNoteRef.COLOR].unmarkObject(removeNoteRef);
                        removeNoteRef.visible = false;
                    }
                    else
                    {
                        removeChild(removeNoteRef);
                    }

                    notes.splice(removeNoteIndex, 1);
                    break;
                }
            }
        }

        public function reset():void
        {
            for each (var note:GameNote in notes)
            {
                if (!options.disableNotePool)
                {
                    _notePool[note.NOTESKIN][note.DIR][note.COLOR].unmarkObject(note);
                    note.visible = false;
                }
                else
                {
                    removeChild(note);
                }
            }

            notes = new Array();
            _noteCount = 0;
        }

        public function resetNoteCount(value:int):void
        {
            _noteCount = value;
        }

        public function position():void
        {
            var data:Object = _noteskins.getInfo(_noteskinId);
            var rotation:Number = data.rotation;
            var gap:int = _receptorGap;
            var noteScale:Number = _noteScale;
            var centerOffset:int = 160;

            //if (data.width > 64)
            //gap += data.width - 64;

            // User-defined note scale
            if (noteScale != 1)
            {
                if (noteScale < 0.1)
                    noteScale = 0.1; // min
                else if (noteScale > 2.0)
                    noteScale = 2.0; // max
                gap *= noteScale
            }
            else if (_mods.mini && !_mods.miniResize)
            {
                gap *= 0.75;
            }

            switch (_scrollDirection)
            {
                case "down":
                    _downReceptor.x = int(-gap / 2) + centerOffset;
                    _downReceptor.y = 400;
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "y";
                    _downReceptor.DIRECTION = 1;

                    _leftReceptor.x = _downReceptor.x - gap;
                    _leftReceptor.y = _downReceptor.y;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "y";
                    _leftReceptor.DIRECTION = 1;

                    _upReceptor.x = int(gap / 2) + centerOffset;
                    _upReceptor.y = _downReceptor.y;
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "y";
                    _upReceptor.DIRECTION = 1;

                    _rightReceptor.x = _upReceptor.x + gap;
                    _rightReceptor.y = _downReceptor.y;
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "y";
                    _rightReceptor.DIRECTION = 1;

                    _receptorArray = [_leftReceptor, _downReceptor, _upReceptor, _rightReceptor];
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -150, "max_y": 50};
                    break;
                case "right":
                    centerOffset += 80;
                    _leftReceptor.x = 460;
                    _leftReceptor.y = int(gap / 2) + centerOffset + gap;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "x";
                    _leftReceptor.DIRECTION = 1;

                    _upReceptor.x = _leftReceptor.x;
                    _upReceptor.y = int(-gap / 2) + centerOffset;
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "x";
                    _upReceptor.DIRECTION = 1;

                    _rightReceptor.x = _leftReceptor.x;
                    _rightReceptor.y = int(-gap / 2) + centerOffset - gap
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "x";
                    _rightReceptor.DIRECTION = 1;

                    _downReceptor.x = _leftReceptor.x;
                    _downReceptor.y = int(gap / 2) + centerOffset;
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "x";
                    _downReceptor.DIRECTION = 1;

                    _receptorArray = [_upReceptor, _rightReceptor, _leftReceptor, _downReceptor];
                    positionOffsetMax = {"min_x": -150, "max_x": 50, "min_y": -120, "max_y": 120};
                    break;
                case "left":
                    centerOffset += 80;
                    _leftReceptor.x = -140;
                    _leftReceptor.y = int(gap / 2) + centerOffset + gap;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "x";
                    _leftReceptor.DIRECTION = -1;

                    _upReceptor.x = _leftReceptor.x;
                    _upReceptor.y = int(-gap / 2) + centerOffset;
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "x";
                    _upReceptor.DIRECTION = -1;

                    _rightReceptor.x = _leftReceptor.x;
                    _rightReceptor.y = int(-gap / 2) + centerOffset - gap
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "x";
                    _rightReceptor.DIRECTION = -1;

                    _downReceptor.x = _leftReceptor.x;
                    _downReceptor.y = int(gap / 2) + centerOffset;
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "x";
                    _downReceptor.DIRECTION = -1;

                    _receptorArray = [_upReceptor, _rightReceptor, _leftReceptor, _downReceptor];
                    positionOffsetMax = {"min_x": -50, "max_x": 150, "min_y": -120, "max_y": 120};
                    break;
                case "split":
                    _downReceptor.x = int(-gap / 2) + centerOffset;
                    _downReceptor.y = 400;
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "y";
                    _downReceptor.DIRECTION = 1;

                    _leftReceptor.x = _downReceptor.x - gap;
                    _leftReceptor.y = 90;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "y";
                    _leftReceptor.DIRECTION = -1;

                    _upReceptor.x = int(gap / 2) + centerOffset;
                    _upReceptor.y = 400;
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "y";
                    _upReceptor.DIRECTION = 1;

                    _rightReceptor.x = _upReceptor.x + gap;
                    _rightReceptor.y = 90;
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "y";
                    _rightReceptor.DIRECTION = -1;

                    _receptorArray = [_leftReceptor, _downReceptor, _upReceptor, _rightReceptor];
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -50, "max_y": 50};
                    break;
                case "split_down":
                    _downReceptor.x = int(-gap / 2) + centerOffset;
                    _downReceptor.y = 90;
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "y";
                    _downReceptor.DIRECTION = -1;

                    _leftReceptor.x = _downReceptor.x - gap;
                    _leftReceptor.y = 400;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "y";
                    _leftReceptor.DIRECTION = 1;

                    _upReceptor.x = int(gap / 2) + centerOffset;
                    _upReceptor.y = 90;
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "y";
                    _upReceptor.DIRECTION = -1;

                    _rightReceptor.x = _upReceptor.x + gap;
                    _rightReceptor.y = 400;
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "y";
                    _rightReceptor.DIRECTION = 1;

                    _receptorArray = [_leftReceptor, _downReceptor, _upReceptor, _rightReceptor];
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -50, "max_y": 50};
                    break;
                case "plus":
                    _downReceptor.x = centerOffset;
                    _downReceptor.y = centerOffset + 80 + int(gap / 2);
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "y";
                    _downReceptor.DIRECTION = -1;

                    _leftReceptor.x = centerOffset - int(gap / 2);
                    _leftReceptor.y = centerOffset + 80;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "x";
                    _leftReceptor.DIRECTION = 1;

                    _upReceptor.x = centerOffset;
                    _upReceptor.y = centerOffset + 80 - int(gap / 2);
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "y";
                    _upReceptor.DIRECTION = 1;

                    _rightReceptor.x = centerOffset + int(gap / 2);
                    _rightReceptor.y = centerOffset + 80;
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "x";
                    _rightReceptor.DIRECTION = -1;

                    _receptorArray = [_upReceptor, _rightReceptor, _downReceptor, _leftReceptor];
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -150, "max_y": 150};
                    break;
                default:
                    _downReceptor.x = int(-gap / 2) + centerOffset;
                    _downReceptor.y = 90;
                    _downReceptor.rotation = 0;
                    _downReceptor.VERTEX = "y";
                    _downReceptor.DIRECTION = -1;

                    _leftReceptor.x = _downReceptor.x - gap;
                    _leftReceptor.y = _downReceptor.y;
                    _leftReceptor.rotation = rotation;
                    _leftReceptor.VERTEX = "y";
                    _leftReceptor.DIRECTION = -1;

                    _upReceptor.x = int(gap / 2) + centerOffset;
                    _upReceptor.y = _downReceptor.y;
                    _upReceptor.rotation = rotation * 2;
                    _upReceptor.VERTEX = "y";
                    _upReceptor.DIRECTION = -1;

                    _rightReceptor.x = _upReceptor.x + gap;
                    _rightReceptor.y = _downReceptor.y;
                    _rightReceptor.rotation = rotation * -1;
                    _rightReceptor.VERTEX = "y";
                    _rightReceptor.DIRECTION = -1;

                    _receptorArray = [_leftReceptor, _downReceptor, _upReceptor, _rightReceptor];
                    positionOffsetMax = {"min_x": -150, "max_x": 150, "min_y": -50, "max_y": 150};
                    break;
            }

            for each (var item:MovieClip in _receptorArray)
            {
                item.ORIG_X = item.x;
                item.ORIG_Y = item.y;
                item.ORIG_ROT = item.rotation;
            }

            if (_mods.rotateCW)
            {
                _leftReceptor.rotation += 90;
                _downReceptor.rotation += 90;
                _upReceptor.rotation += 90;
                _rightReceptor.rotation += 90;
            }

            if (_mods.rotateCCW)
            {
                _leftReceptor.rotation -= 90;
                _downReceptor.rotation -= 90;
                _upReceptor.rotation -= 90;
                _rightReceptor.rotation -= 90;
            }

            if (_noteScale != 1.0)
                _downReceptor.scaleX = _downReceptor.scaleY = _leftReceptor.scaleX = _leftReceptor.scaleY = _upReceptor.scaleX = _upReceptor.scaleY = _rightReceptor.scaleX = _rightReceptor.scaleY = _noteScale;

            if (_mods.mini && !_mods.miniResize && _noteScale == 1.0)
                _downReceptor.scaleX = _downReceptor.scaleY = _leftReceptor.scaleX = _leftReceptor.scaleY = _upReceptor.scaleX = _upReceptor.scaleY = _rightReceptor.scaleX = _rightReceptor.scaleY = 0.75;


            if (_mods.miniResize && !_mods.mini && _noteScale == 1.0)
                _downReceptor.scaleX = _downReceptor.scaleY = _leftReceptor.scaleX = _leftReceptor.scaleY = _upReceptor.scaleX = _upReceptor.scaleY = _rightReceptor.scaleX = _rightReceptor.scaleY = 0.5;

            if (_mods.dark)
                _receptorAlpha = 0.3;

            _leftReceptor.alpha = _downReceptor.alpha = _upReceptor.alpha = _rightReceptor.alpha = _receptorAlpha;
        }
    }
}
