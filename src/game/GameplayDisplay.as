package game
{
    import arc.ArcGlobals;
    import arc.mp.MultiplayerState;
    import assets.GameBackgroundColor;
    import assets.gameplay.viewLR;
    import assets.gameplay.viewUD;
    import classes.Alert;
    import classes.GameNote;
    import classes.Gameplay;
    import classes.Language;
    import classes.NoteskinsList;
    import classes.User;
    import classes.chart.LevelScriptRuntime;
    import classes.chart.Note;
    import classes.chart.NoteChart;
    import classes.chart.Song;
    import classes.replay.ReplayBinFrame;
    import classes.replay.ReplayNote;
    import classes.ui.BoxButton;
    import classes.ui.ProgressBar;
    import com.flashfla.net.Multiplayer;
    import com.flashfla.net.events.GameResultsEvent;
    import com.flashfla.net.events.GameUpdateEvent;
    import com.flashfla.utils.Average;
    import com.flashfla.utils.RollingAverage;
    import com.flashfla.utils.TimeUtil;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.ui.Keyboard;
    import flash.ui.Mouse;
    import flash.utils.getTimer;
    import game.controls.AccuracyBar;
    import game.controls.Combo;
    import game.controls.FlashlightOverlay;
    import game.controls.Judge;
    import game.controls.LifeBar;
    import game.controls.MPHeader;
    import game.controls.NoteBox;
    import game.controls.PAWindow;
    import game.controls.Score;
    import game.controls.ScreenCut;
    import game.controls.TextStatic;
    import menu.DisplayLayer;
    import menu.MenuSongSelection;
    import sql.SQLSongUserInfo;
    import flash.text.TextFieldAutoSize;
    import events.navigation.ChangePanelEvent;

    public class GameplayDisplay extends DisplayLayer
    {
        public static const GAME_DISPOSE:int = -1;
        public static const GAME_PLAY:int = 0;
        public static const GAME_END:int = 1;
        public static const GAME_RESTART:int = 2;
        public static const GAME_PAUSE:int = 3;

        public static const LAYOUT_PROGRESS_BAR:String = "progressbar";
        public static const LAYOUT_PROGRESS_TEXT:String = "progresstext";
        public static const LAYOUT_RECEPTORS:String = "receptors";
        public static const LAYOUT_JUDGE:String = "judge";
        public static const LAYOUT_HEALTH:String = "health";
        public static const LAYOUT_SCORE:String = "score";
        public static const LAYOUT_COMBO:String = "combo";
        public static const LAYOUT_COMBO_TOTAL:String = "combototal";
        public static const LAYOUT_COMBO_STATIC:String = "combostatic";
        public static const LAYOUT_COMBO_TOTAL_STATIC:String = "combototalstatic";
        public static const LAYOUT_ACCURACY_BAR:String = "accuracybar";
        public static const LAYOUT_PA:String = "pa";

        private static const LAYOUT_MP_JUDGE:String = "mpjudge";
        private static const LAYOUT_MP_COMBO:String = "mpcombo";
        private static const LAYOUT_MP_PA:String = "mppa";
        private static const LAYOUT_MP_HEADER:String = "mpheader";

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _noteskins:NoteskinsList = NoteskinsList.instance;
        private var _lang:Language = Language.instance;

        private var _loader:URLLoader;

        private var _keys:Array;
        private var _song:Song;
        private var _songBackground:MovieClip;
        private var _legacyMode:Boolean;
        private var _levelScript:LevelScriptRuntime;

        private var _reverseMod:Boolean;
        private var _sideScroll:Boolean;
        private var _defaultLayout:Object;

        private var _displayBlackBG:Sprite;
        private var _gameplayUI:*;
        private var _progressDisplay:ProgressBar;
        private var _progressDisplayText:TextStatic;
        private var _noteBox:NoteBox;
        private var _score:Score;
        private var _comboTotal:Combo;
        private var _comboStatic:TextStatic;
        private var _comboTotalStatic:TextStatic;
        private var _accBar:AccuracyBar;
        private var _screenCut:ScreenCut;
        private var _flashLight:FlashlightOverlay;
        private var _exitEditor:BoxButton;
        private var _resetEditor:BoxButton;

        private var _player1PAWindow:PAWindow;
        private var _player1Combo:Combo;
        private var _player1Life:LifeBar;
        private var _player1Judge:Judge;
        private var _player1JudgeOffset:int;

        private var _mpHeader:Array;
        private var _mpCombo:Array;
        private var _mpJudge:Array;
        private var _mpPA:Array;

        private var _msStartTime:Number = 0;
        private var _absoluteStart:int = 0;
        private var _absolutePosition:int = 0;
        private var _songPausePosition:int = 0;
        private var _songDelay:int = 0;
        private var _songDelayStarted:Boolean = false;
        private var _songOffset:RollingAverage;
        private var _frameRate:RollingAverage;
        private var _gamePosition:int = 0;
        private var _gameProgress:int = 0;
        private var _globalOffset:int = 0;
        private var _globalOffsetRounded:int = 0;
        private var _accuracy:Average;
        private var _judgeOffset:int = 0;
        private var _autoJudgeOffset:Boolean = false;
        private var _judgeSettings:Vector.<JudgeNode>;

        private var _quitDoubleTap:int = -1;

        private var _options:GameOptions;
        private var _mpSpectate:Boolean;

        private var _gameLastNoteFrame:Number;
        private var _gameFirstNoteFrame:Number;
        private var _gameSongFrames:int;

        private var _gameLife:int;
        private var _gameScore:int;
        private var _gameRawGoods:Number;
        private var _gameReplay:Array;

        /** Contains a list of scores or other flags used in replay_hit.
         * The value is either:
         * [100]  Amazing
         * [50]   Perfect
         * [25]   Good
         * [5]    Average
         * [0]    Miss & Boo
         * [-5]   Missed Note After End Game
         * [-10]  End of Replay Hit Tag
         */
        private var _gameReplayHit:Array;

        private var _binReplayNotes:Vector.<ReplayBinFrame>;
        private var _binReplayBoos:Vector.<ReplayBinFrame>;

        private var _replayPressCount:Number = 0;

        private var _hitAmazing:int;
        private var _hitPerfect:int;
        private var _hitGood:int;
        private var _hitAverage:int;
        private var _hitMiss:int;
        private var _hitBoo:int;
        private var _hitCombo:int;
        private var _hitMaxCombo:int;

        private var _noteBoxOffset:Object = {"x": 0, "y": 0};
        private var _noteBoxPositionDefault:Object;

        private var _keyHints:Array;

        private var _GAME_STATE:uint = GAME_PLAY;

        private var _socketSongMessage:Object = {};
        private var _socketScoreMessage:Object = {};

        // Anti-GPU Rampdown Hack
        private var _gpuPixelBitmapData:BitmapData;
        private var _gpuPixelBitmap:Bitmap;

        public function GameplayDisplay(gameOptions:GameOptions)
        {
            _options = gameOptions;
            init();
        }

        public function init():void
        {
            _song = _options.song;
            if (!_options.isEditor && _song.chart.notes.length == 0)
            {
                Alert.add(_lang.string("error_chart_has_no_notes"), 120, Alert.RED);

                var screen:int = _options.settings.startUpScreen;
                if (!_options.user.isGuest && (screen == 0 || screen == 1) && !MultiplayerState.instance.connection.connected)
                {
                    MultiplayerState.instance.connection.connect();
                }

                dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
            }

            // --- Per Song Options
            var perSongOptions:SQLSongUserInfo = SQLQueries.getSongUserInfo(_song.songInfo);
            if (perSongOptions != null && !_options.isEditor && !_options.replay)
            {
                _options.fill(); // Reset

                // Custom Offsets
                if (perSongOptions.set_custom_offsets)
                {
                    _options.settings.judgeOffset = perSongOptions.offset_judge;
                    _options.settings.globalOffset = perSongOptions.offset_music;
                }

                // Invert Mirror Mod
                if (perSongOptions.set_mirror_invert)
                {
                    if (_options.modEnabled("mirror"))
                    {
                        _options.settings.activeMods.removeAt(_options.settings.activeMods.indexOf("mirror"));
                        delete _options.modCache["mirror"];
                    }
                    else
                    {
                        _options.settings.activeMods.push("mirror");
                        _options.modCache["mirror"] = true;
                    }
                }
            }
        }

        override public function stageAdd():void
        {
            if (_gvars.menuMusic)
                _gvars.menuMusic.stop();

            if (MenuSongSelection.previewMusic)
                MenuSongSelection.previewMusic.stop();

            // Create Background
            initBackground();

            // Init Core
            initPlayerVars();
            initCore();

            // Prebuild Websocket Message, this is updated instead of creating a new object every message.
            _socketSongMessage = {"player": {
                        "settings": _options.settings.stringify(),
                        "name": _options.user.name,
                        "userid": _options.user.siteId,
                        "avatar": Constant.USER_AVATAR_URL + "?uid=" + _options.user.siteId,
                        "skill_rating": _options.user.skillRating,
                        "skill_level": _options.user.skillLevel,
                        "game_rank": _options.user.gameRank,
                        "game_played": _options.user.gamesPlayed,
                        "game_grand_total": _options.user.grandTotal
                    },
                    "engine": (_song.songInfo.engine == null ? null : {"id": _song.songInfo.engine.id,
                            "name": _song.songInfo.engine.name,
                            "config": _song.songInfo.engine.config_url,
                            "domain": _song.songInfo.engine.domain})
                    ,
                    "song": {
                        "name": _song.songInfo.name,
                        "level": _song.songInfo.level,
                        "difficulty": _song.songInfo.difficulty,
                        "style": _song.songInfo.style,
                        "author": _song.songInfo.author,
                        "author_url": _song.songInfo.stepauthor_url,
                        "stepauthor": _song.songInfo.stepauthor,
                        "credits": _song.songInfo.credits,
                        "genre": _song.songInfo.genre,
                        "nps_min": _song.songInfo.min_nps,
                        "nps_max": _song.songInfo.max_nps,
                        // TODO: Check these fields
                        //"release_date": song.songInfo.releasedate,
                        //"song_rating": song.songInfo.song_rating,
                        // Trust the chart, not the playlist.
                        "time": _song.chartTimeFormatted,
                        "time_seconds": _song.chartTime,
                        "note_count": _song.totalNotes,
                        "nps_avg": (_song.totalNotes / _song.chartTime)
                    },
                    "best_score": _options.user.getLevelRank(_song.songInfo)};

            _socketScoreMessage = {"amazing": 0,
                    "perfect": 0,
                    "good": 0,
                    "average": 0,
                    "miss": 0,
                    "boo": 0,
                    "score": 0,
                    "combo": 0,
                    "maxcombo": 0,
                    "restarts": 0,
                    "last_hit": null};

            // Set Defaults for Editor Mode
            if (_options.isEditor)
            {
                _socketSongMessage["song"]["name"] = "Editor Mode";
                _socketSongMessage["song"]["author"] = "rCubed Engine";
                _socketSongMessage["song"]["difficulty"] = 0;
                _socketSongMessage["song"]["time"] = "10:00";
                _socketSongMessage["song"]["time_seconds"] = 600;
            }

            // Init Game
            initUI();
            initVars();

            // Preload next Song
            if (_gvars.songQueue.length > 0)
            {
                _gvars.getSongFile(_gvars.songQueue[0]);
            }

            // Setup MP Things
            if (_options.mpRoom)
            {
                MultiplayerState.instance.gameplayPlaying(this);
                if (!_options.isEditor)
                {
                    _options.singleplayer = false; // Back to multiplayer lobby
                    _options.mpRoom.connection.addEventListener(Multiplayer.EVENT_GAME_UPDATE, onMultiplayerUpdate);
                    if (_mpSpectate)
                        _options.mpRoom.connection.addEventListener(Multiplayer.EVENT_GAME_RESULTS, onMultiplayerResults);
                }
            }
            else
            {
                _options.singleplayer = true; // Back to song selection
            }
            stage.focus = this.stage;

            interfaceSetup();

            _gvars.gameMain.disablePopups = true;

            if (!_options.isEditor && !_options.replay && !_mpSpectate)
                Mouse.hide();

            if (_song.songInfo && _song.songInfo.name)
                stage.nativeWindow.title = Constant.AIR_WINDOW_TITLE + " - " + _song.songInfo.name;

            // Add onEnterFrame Listeners
            if (_options.isEditor)
            {
                _options.isAutoplay = true;
                stage.frameRate = _options.settings.frameRate;
                stage.addEventListener(Event.ENTER_FRAME, editorOnEnterFrame, false, int.MAX_VALUE - 10, true);
                stage.addEventListener(KeyboardEvent.KEY_DOWN, editorKeyboardKeyDown, false, int.MAX_VALUE - 10, true);
            }
            else
            {
                stage.frameRate = _song.frameRate;
                stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE - 10, true);
                stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, true, int.MAX_VALUE - 10, true);
                stage.addEventListener(KeyboardEvent.KEY_UP, keyboardKeyUp, true, int.MAX_VALUE - 10, true);
            }
        }

        override public function dispose():void
        {
            stage.frameRate = 60;
            if (_options.isEditor)
            {
                _options.settings.screencutPosition = _options.settings.screencutPosition;
                stage.removeEventListener(Event.ENTER_FRAME, editorOnEnterFrame);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, editorKeyboardKeyDown);
            }
            else
            {
                stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, true);
                stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardKeyUp, true);

                if (_options.mpRoom)
                {
                    _options.mpRoom.connection.removeEventListener(Multiplayer.EVENT_GAME_UPDATE, onMultiplayerUpdate);
                    _options.mpRoom.connection.removeEventListener(Multiplayer.EVENT_GAME_RESULTS, onMultiplayerResults);
                }
            }

            _gvars.gameMain.disablePopups = false;

            // Disable Editor mode when leaving editor.
            _options.isEditor = false;

            Mouse.show();
        }

        /*#########################################################################################*\
         *       _____       _ _   _       _ _
         *       \_   \_ __ (_) |_(_) __ _| (_)_______
         *	     / /\/ '_ \| | __| |/ _` | | |_  / _ \
         *	  /\/ /_ | | | | | |_| | (_| | | |/ /  __/
         *	  \____/ |_| |_|_|\__|_|\__,_|_|_/___\___|
         *
           \*#########################################################################################*/

        private function initCore():void
        {
            // Bound Isolation Note Mod
            if (_options.isolationOffset >= _song.chart.notes.length)
                _options.isolationOffset = _song.chart.notes.length - 1;

            // Song
            _song.updateMusicDelay();
            _legacyMode = (_song.type == NoteChart.FFR || _song.type == NoteChart.FFR_RAW || _song.type == NoteChart.FFR_LEGACY);
            if (_song.music && (_legacyMode || !_options.modEnabled("nobackground")))
            {
                _songBackground = _song.music as MovieClip;
                _gameSongFrames = _songBackground.totalFrames;
                _songBackground.x = 115;
                _songBackground.y = 42.5;
                this.addChild(_songBackground);
                if (_options.modEnabled("nobackground"))
                    setChildIndex(_songBackground, 0);
            }
            _song.start();
            _songDelay = _song.mp3Frame / _options.settings.songRate * 1000 / 30 - _globalOffset;
        }

        private function initBackground():void
        {
            // Anti-GPU Rampdown Hack
            _gpuPixelBitmapData = new BitmapData(1, 1, false, 0x010101);
            _gpuPixelBitmap = new Bitmap(_gpuPixelBitmapData);
            this.addChild(_gpuPixelBitmap);

            stage.color = GameBackgroundColor.BG_STAGE;

            // if (!displayBlackBG)
            // {
            //     displayBlackBG = new Sprite();
            //     displayBlackBG.graphics.beginFill(0x000000);
            //     displayBlackBG.graphics.drawRect(-Main.GAME_WIDTH, -Main.GAME_WIDTH, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);
            //     this.addChild(displayBlackBG);
            // }
        }

        private function initUI():void
        {
            _noteBox = new NoteBox(_song, _options);
            _noteBox.position();
            this.addChild(_noteBox);

            if (!_options.isEditor && MultiplayerState.instance.connection.connected && !MultiplayerState.instance.isInRoom())
            {
                var isInSoloMode:Boolean = true;
                MultiplayerState.instance.connection.disconnect(isInSoloMode);
            }

            /*
               if (false && !_gvars.tempFlags["key_hints"] && !options.multiplayer && !options.isEditor && !options.replay && !mpSpectate) {
               keyHints = [];
               togglePause();
               var aa:Alert;
               for each(var rec:MovieClip in noteBox.receptorArray) {
               aa = new Alert(StringUtil.keyCodeChar(options.settings["key" + rec.KEY]));
               if(rec.VERTEX == "y") {
               aa.x = rec.x - (aa.width / 2);
               aa.y = rec.y - ((rec.height / 2) * rec.DIRECTION) - (10 * rec.DIRECTION);
               if (rec.DIRECTION == 1) aa.y -= aa.height;
               } else {
               aa.x = rec.x - ((rec.width / 2) * rec.DIRECTION) - (10 * rec.DIRECTION);;
               aa.y = rec.y - (aa.height / 2);
               if (rec.DIRECTION == 1) aa.x -= aa.width;
               }
               noteBox.addChild(aa);
               keyHints.push(aa);
               }
               _gvars.tempFlags["key_hints"] = true;
               }
             */

            buildFlashlight();

            buildScreenCut();

            _gameplayUI = (_sideScroll ? new viewLR() : new viewUD());
            this.addChild(_gameplayUI);

            if (!_options.settings.displayGameTopBar)
                _gameplayUI.top_bar.visible = false;

            if (!_options.settings.displayGameBottomBar)
                _gameplayUI.bottom_bar.visible = false;

            if (!_options.settings.displayGameTopBar && !_options.settings.displayGameBottomBar)
                _gameplayUI.visible = false;

            if (_options.settings.displayPACount)
            {
                _player1PAWindow = new PAWindow(_options);
                if (_sideScroll)
                    _player1PAWindow.alternateLayout();
                this.addChild(_player1PAWindow);
            }

            if (_options.settings.displayScore)
            {
                _score = new Score(_options);
                this.addChild(_score);
            }

            if (_options.settings.displayCombo)
            {
                _player1Combo = new Combo(_options);
                if (!_sideScroll)
                    _player1Combo.alignment = TextFieldAutoSize.RIGHT;
                this.addChild(_player1Combo);

                _comboStatic = new TextStatic(_lang.string("game_combo"));
                this.addChild(_comboStatic);
            }

            if (_options.settings.displayTotal)
            {
                _comboTotal = new Combo(_options);
                if (_sideScroll)
                    _comboTotal.alignment = TextFieldAutoSize.RIGHT;
                this.addChild(_comboTotal);

                _comboTotalStatic = new TextStatic(_lang.string("game_combo_total"));
                this.addChild(_comboTotalStatic);
            }

            if (_options.settings.displayAccuracyBar)
            {
                _accBar = new AccuracyBar(_options);
                this.addChild(_accBar);
            }

            if (_options.settings.displaySongProgress || _options.replay)
            {
                _progressDisplay = new ProgressBar(161, 9, 458, 20, 4, 0x545454, 0.1);
                addChild(_progressDisplay);

                if (_options.replay)
                    _progressDisplay.addEventListener(MouseEvent.CLICK, progressMouseClick);
            }
            if (_options.settings.displaySongProgressText)
            {
                _progressDisplayText = new TextStatic("0:00");
                this.addChild(_progressDisplayText);
            }

            if (!_mpSpectate)
            {
                buildJudge();
                buildHealth();
            }

            if (_options.mpRoom)
                buildMultiplayer();

            if (_options.isEditor)
            {
                _gameplayUI.mouseChildren = false;
                _gameplayUI.mouseEnabled = false;

                function closeEditor(e:MouseEvent):void
                {
                    _GAME_STATE = GAME_END;
                    if (!_options.replay)
                    {
                        _options.user.saveSettingsLocally();
                        _options.user.saveSettingsOnline(_gvars.userSession);
                    }
                }

                function resetLayout(e:MouseEvent):void
                {
                    for (var key:String in _options.layout)
                        delete _options.layout[key];
                    _avars.interfaceSave();
                    interfaceSetup();
                }

                _exitEditor = new BoxButton(this, (Main.GAME_WIDTH - 75) / 2, (Main.GAME_HEIGHT - 30) / 2, 75, 30, _lang.string("menu_close"), 12, closeEditor);
                _resetEditor = new BoxButton(this, _exitEditor.x, _exitEditor.y + 35, 75, 30, _lang.string("menu_reset"), 12, resetLayout);
            }
        }

        private function initPlayerVars():void
        {
            // Force no Judge on SongPreviews
            if (_options.replay && _options.replay.isPreview)
            {
                _options.settings.judgeOffset = 0;
                _options.settings.globalOffset = 0;
                _options.isAutoplay = true;
            }

            _reverseMod = _options.modEnabled("reverse");
            _sideScroll = (_options.settings.scrollDirection == "left" || _options.settings.scrollDirection == "right");
            _player1JudgeOffset = Math.round(_options.settings.judgeOffset);
            _globalOffsetRounded = Math.round(_options.settings.globalOffset);
            _globalOffset = (_options.settings.globalOffset - _globalOffsetRounded) * 1000 / 30;

            if (_options.judgeWindow)
                _judgeSettings = buildJudgeNodes(_options.judgeWindow);
            else
                _judgeSettings = buildJudgeNodes(Constant.JUDGE_WINDOW);
            _judgeOffset = _options.settings.judgeOffset * 1000 / 30;
            _autoJudgeOffset = _options.settings.autoJudgeOffset;

            _mpSpectate = (_options.mpRoom && !_options.mpRoom.connection.currentUser.isPlayer);
            if (_mpSpectate)
            {
                _options.settings.displayCombo = false;
                _options.settings.displayTotal = false;
                _options.settings.displayPACount = false;
            }
            else if (_options.mpRoom)
                _options.settings.displayTotal = false;
        }

        private function initVars(postStart:Boolean = true):void
        {
            // Post Start Time
            if (postStart && !_options.user.isGuest && !_options.replay && !_options.isEditor && _song.songInfo.engine == null && !_mpSpectate)
            {
                Logger.debug(this, "Posting Start of level " + _song.id);
                _loader = new URLLoader();
                addLoaderListeners();

                var req:URLRequest = new URLRequest(Constant.SONG_START_URL);
                var requestVars:URLVariables = new URLVariables();
                Constant.addDefaultRequestVariables(requestVars);
                requestVars.session = _gvars.userSession;
                requestVars.id = _song.id;
                requestVars.restarts = _gvars.songRestarts;
                req.data = requestVars;
                req.method = URLRequestMethod.POST;
                _loader.dataFormat = URLLoaderDataFormat.VARIABLES;
                _loader.load(req);
            }

            // Game Vars
            _keys = [];
            _gameLife = 50;
            _gameScore = 0;
            _gameRawGoods = 0;
            _gameReplay = [];
            _gameReplayHit = [];

            _binReplayNotes = new Vector.<ReplayBinFrame>(_song.totalNotes, true);
            _binReplayBoos = new <ReplayBinFrame>[];

            // Prefill Replay
            for (var i:int = _song.totalNotes - 1; i >= 0; i--)
                _binReplayNotes[i] = new ReplayBinFrame(NaN, _song.getNote(i).direction, i);

            _replayPressCount = 0;

            _hitAmazing = 0;
            _hitPerfect = 0;
            _hitGood = 0;
            _hitAverage = 0;
            _hitMiss = 0;
            _hitBoo = 0;
            _hitCombo = 0;
            _hitMaxCombo = 0;

            updateHealth(0);
            if (_song != null && _song.totalNotes > 0)
            {
                _gameLastNoteFrame = _song.getNote(_song.totalNotes - 1).frame;
                _gameFirstNoteFrame = _song.getNote(0).frame;
            }
            if (_comboTotal)
                _comboTotal.update(_song.totalNotes);

            _msStartTime = getTimer();
            _absoluteStart = getTimer();
            _gamePosition = 0;
            _gameProgress = 0;
            _absolutePosition = 0;
            if (_song != null)
            {
                _songOffset = new RollingAverage(_song.frameRate * 4, _avars.configMusicOffset);
                _frameRate = new RollingAverage(_song.frameRate * 4, _song.frameRate);
            }
            _accuracy = new Average();

            _songDelayStarted = false;

            updateFieldVars();

            if (_progressDisplayText)
                _progressDisplayText.update(TimeUtil.convertToHMSS(Math.ceil(_gameLastNoteFrame / 30)));

            if (postStart)
            {
                // Websocket
                if (_gvars.air_useWebsockets)
                {
                    _socketScoreMessage["amazing"] = _hitAmazing;
                    _socketScoreMessage["perfect"] = _hitPerfect;
                    _socketScoreMessage["good"] = _hitGood;
                    _socketScoreMessage["average"] = _hitAverage;
                    _socketScoreMessage["boo"] = _hitBoo;
                    _socketScoreMessage["miss"] = _hitMiss;
                    _socketScoreMessage["combo"] = _hitCombo;
                    _socketScoreMessage["maxcombo"] = _hitMaxCombo;
                    _socketScoreMessage["score"] = _gameScore;
                    _socketScoreMessage["last_hit"] = null;
                    _socketScoreMessage["restarts"] = _gvars.songRestarts;
                    _gvars.websocketSend("NOTE_JUDGE", _socketScoreMessage);
                    _gvars.websocketSend("SONG_START", _socketSongMessage);
                }
            }
        }

        private function siteLoadComplete(e:Event):void
        {
            removeLoaderListeners();
            var data:URLVariables = e.target.data;
            Logger.debug(this, "Post Start Load Success = " + data.result);
            if (data.result == "success")
            {
                _gvars.songStartTime = data.current_date;
                _gvars.songStartHash = data.current_time;
            }
        }

        private function siteLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Post Start Load Failure: " + Logger.event_error(err));
            removeLoaderListeners();
        }

        /*#########################################################################################*\
         *        __                 _
         *       /__\_   _____ _ __ | |_ ___
         *      /_\ \ \ / / _ \ '_ \| __/ __|
         *     //__  \ V /  __/ | | | |_\__ \
         *     \__/   \_/ \___|_| |_|\__|___/
         *
           \*#########################################################################################*/

        private function stopClips(clip:MovieClip, frame:int):void
        {
            if (!clip)
                return;

            if (frame < 2)
                frame = 2;

            switch (clip.currentFrame - frame + 1)
            {
                case 0:
                    clip.nextFrame();
                case 1:
                    break;
                default:
                    clip.gotoAndStop(frame);
                    break;
            }

            for (var i:int = 0; i < clip.numChildren; i++)
                stopClips(clip.getChildAt(i) as MovieClip, frame);
        }

        private function logicTick():void
        {
            _gameProgress++;

            // Anti-GPU Rampdown Hack:
            // By doing a sparse but steady amount of screen updates using a single pixel in the
            // top left, the GPU is kept active on laptops. This fixes the issue when a skip can
            // appear to happen when the GPU re-awakes to begin drawing updates after a break in
            // a song.
            if (_gameProgress % 15 == 0)
            {
                if ((_gameProgress & 1) == 0)
                    _gpuPixelBitmapData.setPixel(0, 0, 0x010101);
                else
                    _gpuPixelBitmapData.setPixel(0, 0, 0x020202);
            }

            if (_levelScript != null)
                _levelScript.doProgressTick(_gameProgress);

            if (_quitDoubleTap > 0)
            {
                _quitDoubleTap--;
            }

            if (_gameProgress >= _gameLastNoteFrame + 20 || _quitDoubleTap == 0)
            {
                _GAME_STATE = GAME_END;
                return;
            }

            // Timer Text
            if (_gameProgress % 30 == 0 && _progressDisplayText != null)
            {
                _progressDisplayText.update(TimeUtil.convertToHMSS(Math.ceil(Math.max(0, (_gameLastNoteFrame - _gameProgress)) / 30)));
            }

            var nextNote:Note = _noteBox.nextNote;
            while (nextNote && nextNote.frame <= _gameProgress + _player1JudgeOffset + 5)
            {
                _noteBox.spawnArrow(nextNote, (_gameProgress + _player1JudgeOffset + 5) / 30 * 1000);
                nextNote = _noteBox.nextNote;
            }

            var notes:Array = _noteBox.notes;
            for (var n:int = 0; n < notes.length; n++)
            {
                var curNote:GameNote = notes[n];

                // Game Bot
                if (_options.isAutoplay && (_gameProgress - curNote.PROGRESS + _player1JudgeOffset) == 0)
                {
                    judgeScore(curNote.DIR, _gameProgress);
                    n--;
                }

                // Remove Old note
                if (_gameProgress - curNote.PROGRESS + _player1JudgeOffset >= 6)
                {
                    commitJudge(curNote.DIR, _gameProgress, -10);
                    _noteBox.removeNote(curNote.ID);
                    n--;
                }
            }

            // Replays
            if (_options.replay && !_options.replay.isPreview)
            {
                var newPress:ReplayNote = _options.replay.getPress(_replayPressCount);
                if (_options.replay.needsBeatboxGeneration)
                {
                    var oldPosition:int = _gamePosition;
                    _gamePosition = (_gameProgress + 0.5) * 1000 / 30;
                    var cutOffReplayNote:uint = _options.replay.generationReplayNotes.length;
                    var readAheadTime:Number = (1 / _frameRate.value) * 1000;
                    // Note Hits
                    for (var rn:int = 0; rn < notes.length; rn++)
                    {
                        var repCurNote:GameNote = notes[rn];

                        // Missed Note
                        if (repCurNote.ID >= cutOffReplayNote || (_options.replay.generationReplayNotes[repCurNote.ID] == null || isNaN(_options.replay.generationReplayNotes[repCurNote.ID].time)))
                        {
                            continue;
                        }

                        var diffValue:int = _options.replay.generationReplayNotes[repCurNote.ID].time + repCurNote.POSITION;
                        if ((_gamePosition + readAheadTime >= diffValue) || _gamePosition >= diffValue)
                        {
                            judgeScorePosition(repCurNote.DIR, diffValue);
                            rn--;
                        }
                    }

                    // Boo Handling
                    while (newPress != null && _gamePosition >= newPress.time)
                    {
                        if (newPress.frame == -2)
                        {
                            commitJudge(newPress.direction, _gameProgress, -5);
                            _binReplayBoos[_binReplayBoos.length] = new ReplayBinFrame(newPress.time, newPress.direction, _binReplayBoos.length);
                        }
                        _replayPressCount++;
                        newPress = _options.replay.getPress(_replayPressCount);
                    }
                    _gamePosition = oldPosition;
                }
                else
                {
                    while (newPress != null && newPress.frame == _gameProgress)
                    {
                        judgeScore(newPress.direction, newPress.frame);

                        _replayPressCount++;
                        newPress = _options.replay.getPress(_replayPressCount);
                    }
                }
            }
        }

        private var mpLowIndex:int = 0;
        private var mpLowProgress:int = 0;
        private var mpLowProgressTime:int = 0;
        private var mpHighIndex:int = 0;
        private var mpHighProgress:int = 0;
        private var mpHighProgressTime:int = 0;

        private function spectateSync():void
        {
            var lowIndex:int = 0;
            var highIndex:int = 0;
            for each (var user:User in _options.mpRoom.players)
            {
                var gameplay:Gameplay = user.gameplay;
                var index:int = gameplay.amazing + gameplay.perfect + gameplay.good + gameplay.average + gameplay.miss;
                if (!lowIndex || (index && index < lowIndex))
                    lowIndex = index;
                if (!highIndex || (index && index > highIndex))
                    highIndex = index;
            }

            if (!_song.getNote(lowIndex) || !_song.getNote(highIndex))
                return;

            var lowProgress:int = _song.getNote(lowIndex).frame;
            var highProgress:int = _song.getNote(highIndex).frame;

            var currentTime:int = getTimer();
            if (lowIndex > mpLowProgress)
            {
                mpLowIndex = lowIndex;
                mpLowProgress = lowProgress;
                mpLowProgressTime = currentTime;
            }
            if (highIndex > mpHighProgress)
            {
                mpHighIndex = highIndex;
                mpHighProgress = highProgress;
                mpHighProgressTime = currentTime;
            }

            lowIndex = mpLowProgressTime ? (mpLowProgress + (currentTime - mpLowProgressTime) * 30 / 1000) : 0;
            highIndex = mpHighProgressTime ? (mpHighProgress + (currentTime - mpHighProgressTime) * 30 / 1000) : 0;

            if (_gameProgress < lowIndex - 30)
            {
                if (highIndex - lowIndex < 60)
                    lowIndex = lowIndex + (highIndex - lowIndex) / 2;
                else
                    lowIndex += 15;
                _absoluteStart = currentTime;
                _songOffset.reset(lowIndex * 1000 / 30);
                _song.start(lowIndex * 1000 / 30);
                _noteBox.resetNoteCount(mpLowIndex);
                while (_gameProgress < lowIndex)
                    logicTick();
            }
            else if (_gameProgress > highIndex + 30 || (!lowIndex && !highIndex))
            {
                if (highIndex - lowIndex < 60)
                    highIndex = lowIndex + (highIndex - lowIndex) / 2;
                else if (highIndex > 15)
                    highIndex -= 15;
                _absoluteStart = currentTime;
                _songOffset.reset(highIndex * 1000 / 30);
                _song.start(highIndex * 1000 / 30);
                _noteBox.resetNoteCount(mpHighIndex);
            }
        }

        private function onEnterFrame(e:Event):void
        {
            // XXX: HACK HACK HACK
            if (_legacyMode)
            {
                var songFrame:int = _songBackground.currentFrame;
                if (songFrame == _gameSongFrames - 1)
                    _song.stop();
            }

            // UI Updates
            if (_options.settings.displayMPJudge && _options.mpRoom)
            {
                for each (var mpJudgeComponent:Judge in _mpJudge)
                {
                    mpJudgeComponent.updateJudge(e);
                }
            }
            else if (_options.settings.displayJudge && _player1Judge != null)
            {
                _player1Judge.updateJudge(e);
            }


            // Gameplay Logic
            switch (_GAME_STATE)
            {
                case GAME_PLAY:
                    if (_legacyMode)
                    {
                        logicTick();
                        _gamePosition = (_gameProgress + 0.5) * 1000 / 30;

                        if (_mpSpectate)
                            spectateSync();
                    }
                    else
                    {
                        var lastAbsolutePosition:int = _absolutePosition;
                        _absolutePosition = getTimer() - _absoluteStart;

                        if (!_songDelayStarted)
                        {
                            if (_absolutePosition < _songDelay)
                            {
                                _song.stop();
                            }
                            else
                            {
                                _songDelayStarted = true;
                                _song.start();
                            }
                        }

                        var songPosition:int = _song.getPosition() + _songDelay;
                        if (_song.musicIsPlaying && songPosition > 100)
                            _songOffset.addValue(songPosition - _absolutePosition);

                        _frameRate.addValue(1000 / (_absolutePosition - lastAbsolutePosition));

                        _gamePosition = Math.round(_absolutePosition + _songOffset.value);
                        if (_gamePosition < 0)
                            _gamePosition = 0;

                        var targetProgress:int = Math.round(_gamePosition * 30 / 1000 - 0.5);
                        var threshold:int = Math.round(1 / (_frameRate.value / 60));
                        if (threshold < 1)
                            threshold = 1;
                        if (_options.replay)
                            threshold = 0x7fffffff;

                        //Logger.debug("GP", "lAP: " + lastAbsolutePosition + " | aP: " + absolutePosition + " | sDS: " + songDelayStarted + " | sD: " + songDelay + " | sOv: " + songOffset.value + " | sGP: " + song.getPosition() + " | sP: " + songPosition + " | gP: " + gamePosition + " | tP: " + targetProgress + " | t: " + threshold);

                        while (_gameProgress < targetProgress && threshold-- > 0)
                            logicTick();

                        if (_mpSpectate)
                            spectateSync();

                        if (_reverseMod)
                            stopClips(_songBackground, 2 + _song.musicDelay - _globalOffsetRounded + _gameProgress * _options.settings.songRate);
                        else
                            stopClips(_songBackground, 2 + _song.musicDelay - _globalOffsetRounded + _gameProgress * _options.settings.songRate);
                    }

                    if (_options.modEnabled("tap_pulse"))
                    {
                        _noteBoxOffset.x = Math.max(Math.min(Math.abs(_noteBoxOffset.x) < 0.5 ? 0 : (_noteBoxOffset.x * 0.992), _noteBox.positionOffsetMax.max_x), _noteBox.positionOffsetMax.min_x);
                        _noteBoxOffset.y = Math.max(Math.min(Math.abs(_noteBoxOffset.y) < 0.5 ? 0 : (_noteBoxOffset.y * 0.992), _noteBox.positionOffsetMax.max_y), _noteBox.positionOffsetMax.min_y);

                        _noteBox.x = _noteBoxPositionDefault.x + _noteBoxOffset.x;
                        _noteBox.y = _noteBoxPositionDefault.y + _noteBoxOffset.y;
                    }

                    _noteBox.update(_gamePosition);

                    if (_progressDisplay)
                        _progressDisplay.update(_gameProgress / _gameLastNoteFrame, false);
                    break;
                case GAME_END:
                    endGame();
                    break;
                case GAME_RESTART:
                    restartGame();
                    break;
            }

            e.stopImmediatePropagation();
        }

        private function keyboardKeyUp(e:KeyboardEvent):void
        {
            var keyCode:int = e.keyCode;

            // Set Key as used.
            _keys[keyCode] = false;

            e.stopImmediatePropagation();
        }

        private function keyboardKeyDown(e:KeyboardEvent):void
        {
            var keyCode:int = e.keyCode;

            // Don't allow key presses unless the key is up.
            if (_keys[keyCode])
            {
                return;
            }

            // Set Key as used.
            _keys[keyCode] = true;

            // Handle judgement of key presses.
            if (_gameLife > 0)
            {
                if (!_options.replay)
                {
                    var dir:String = null;
                    switch (keyCode)
                    {
                        case _options.settings.keyLeft:
                            //case Keyboard.NUMPAD_4:
                            dir = "L";
                            break;

                        case _options.settings.keyRight:
                            //case Keyboard.NUMPAD_6:
                            dir = "R";
                            break;

                        case _options.settings.keyUp:
                            //case Keyboard.NUMPAD_8:
                            dir = "U";
                            break;

                        case _options.settings.keyDown:
                            //case Keyboard.NUMPAD_2:
                            dir = "D";
                            break;
                    }
                    if (dir)
                    {
                        if (_legacyMode)
                            judgeScore(dir, _gameProgress);
                        else
                            judgeScorePosition(dir, Math.round(getTimer() - _absoluteStart + _songOffset.value));
                    }
                }
            }

            // Game Restart
            if (keyCode == _gvars.playerUser.settings.keyRestart && !_options.mpRoom)
            {
                _GAME_STATE = GAME_RESTART;
            }

            // Quit
            else if (keyCode == _gvars.playerUser.settings.keyQuit)
            {
                if (_gvars.songQueue.length > 0)
                {
                    if (_quitDoubleTap > 0)
                    {
                        _gvars.songQueue = [];
                        _GAME_STATE = GAME_END;
                    }
                    else
                    {
                        _quitDoubleTap = _options.settings.frameRate / 4;
                    }
                }
                else
                {
                    _GAME_STATE = GAME_END;
                }
            }

            // Pause
            else if (keyCode == 19 && (CONFIG::debug || _gvars.playerUser.isAdmin || _gvars.playerUser.isDeveloper || _options.replay))
            {
                togglePause();
            }

            // Auto-Play
            else if (keyCode == Keyboard.F8 && (CONFIG::debug || _gvars.playerUser.isDeveloper || _gvars.playerUser.isAdmin))
            {
                _options.isAutoplay = !_options.isAutoplay;
                Alert.add("Bot Play: " + _options.isAutoplay, 60);
            }

            e.stopImmediatePropagation();
        }

        private function progressMouseClick(e:MouseEvent):void
        {
            var seek:int = (e.localX / e.target.width) * _gameLastNoteFrame;
            if (seek < _gameProgress)
                restartGame();
            _absoluteStart = getTimer();
            _songOffset.reset(seek * 1000 / 30);
            _song.start(seek * 1000 / 30);
            while (_gameProgress < seek)
                logicTick();
            _songDelayStarted = true;
        }

        private function editorOnEnterFrame(e:Event):void
        {
            // State 0 = Gameplay
            if (_GAME_STATE == GAME_PLAY)
            {
                _gamePosition = getTimer() - _absoluteStart;
                var targetProgress:int = Math.round(_gamePosition * 30 / 1000);

                // Update Notes
                while (_gameProgress < targetProgress)
                {
                    logicTick();
                }

                _noteBox.update(_gamePosition);
            }
            // State 1 = End Game
            else if (_GAME_STATE == GAME_END)
            {
                endGame();
                return;
            }
        }

        private function editorKeyboardKeyDown(e:KeyboardEvent):void
        {
            if (_noteBox == null)
                return;

            var keyCode:int = e.keyCode;
            var dir:String = "";

            if (keyCode == _gvars.playerUser.settings.keyQuit)
            {
                _GAME_STATE = GAME_END;
            }

            switch (keyCode)
            {
                case _gvars.playerUser.settings.keyLeft:
                    //case Keyboard.NUMPAD_4:
                    dir = "L";
                    break;

                case _gvars.playerUser.settings.keyRight:
                    //case Keyboard.NUMPAD_6:
                    dir = "R";
                    break;

                case _gvars.playerUser.settings.keyUp:
                    //case Keyboard.NUMPAD_8:
                    dir = "U";
                    break;

                case _gvars.playerUser.settings.keyDown:
                    //case Keyboard.NUMPAD_2:
                    dir = "D";
                    break;
            }

            if (dir != "")
            {
                _noteBox.spawnArrow(new Note(dir, (_gameProgress + 31) / 30, "red", _gameProgress + 31), (_gameProgress + _player1JudgeOffset + 5) / 30 * 1000);
            }
        }

        /*#########################################################################################*\
         *	   ___                         ___                 _   _
         *	  / _ \__ _ _ __ ___   ___    / __\   _ _ __   ___| |_(_) ___  _ __  ___
         *	 / /_\/ _` | '_ ` _ \ / _ \  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
         *	/ /_\\ (_| | | | | | |  __/ / /  | |_| | | | | (__| |_| | (_) | | | \__ \
         *	\____/\__,_|_| |_| |_|\___| \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
         *
           \*#########################################################################################*/

        public function togglePause():void
        {
            if (_GAME_STATE == GAME_PLAY)
            {
                _GAME_STATE = GAME_PAUSE;
                _songPausePosition = getTimer();
                _song.pause();

                if (_gvars.air_useWebsockets)
                {
                    _gvars.websocketSend("SONG_PAUSE", _socketSongMessage);
                }
            }
            else if (_GAME_STATE == GAME_PAUSE)
            {
                _GAME_STATE = GAME_PLAY;
                _absoluteStart += (getTimer() - _songPausePosition);
                _song.resume();

                if (_gvars.air_useWebsockets)
                {
                    _gvars.websocketSend("SONG_RESUME", _socketSongMessage);
                }
            }
        }

        private function endGame():void
        {
            if (_levelScript)
                _levelScript.destroy();

            // Stop Music Play
            if (_song)
                _song.stop();

            // Play through to the end of a replay
            if (_options.replay)
            {
                _GAME_STATE = GAME_PLAY;
                while (_gameLife > 0 && _GAME_STATE == GAME_PLAY)
                    logicTick();
                _GAME_STATE = GAME_END;
            }

            // Fill missing notes from replay.
            if (_gameReplayHit.length > 0)
            { // fix crash when spectating game ends
                while (_gameReplayHit.length < _song.totalNotes)
                {
                    _gameReplayHit.push(-5);
                }
            }
            _gameReplayHit.push(-10);
            _gameReplay.sort(ReplayNote.sortFunction)

            var noteCount:int = _hitAmazing + _hitPerfect + _hitGood + _hitAverage + _hitMiss;

            // Save results for display
            if (!_mpSpectate && !_options.isEditor)
            {
                var newGameResults:GameScoreResult = new GameScoreResult();
                newGameResults.game_index = _gvars.gameIndex++;
                newGameResults.level = _song.id;
                newGameResults.song = _song;
                newGameResults.songInfo = _song.songInfo;
                newGameResults.note_count = _song.totalNotes;
                newGameResults.amazing = _hitAmazing;
                newGameResults.perfect = _hitPerfect;
                newGameResults.good = _hitGood;
                newGameResults.average = _hitAverage;
                newGameResults.boo = _hitBoo;
                newGameResults.miss = _hitMiss;
                newGameResults.combo = _hitCombo;
                newGameResults.max_combo = _hitMaxCombo;
                newGameResults.score = _gameScore;
                newGameResults.last_note = noteCount < _song.totalNotes ? noteCount : 0;
                newGameResults.accuracy = _accuracy.value;
                newGameResults.accuracy_deviation = _accuracy.deviation;
                newGameResults.options = _options;
                newGameResults.restart_stats = _gvars.songStats.data;
                newGameResults.replayData = _gameReplay.concat();
                newGameResults.replay_hit = _gameReplayHit.concat();
                newGameResults.replay_bin_notes = _binReplayNotes;
                newGameResults.replay_bin_boos = _binReplayBoos;
                newGameResults.user = _options.replay ? _options.replay.user : _options.user;
                newGameResults.restarts = _options.replay ? 0 : _gvars.songRestarts;
                newGameResults.start_time = _gvars.songStartTime;
                newGameResults.start_hash = _gvars.songStartHash;
                newGameResults.end_time = _options.replay ? TimeUtil.getFormattedDate(new Date(_options.replay.timestamp * 1000)) : TimeUtil.getCurrentDate();
                newGameResults.song_progress = (_gameProgress / _gameLastNoteFrame);
                newGameResults.playtime_secs = ((getTimer() - _msStartTime) / 1000);

                // Set Note Counts for Preview Songs
                if (_options.replay && _options.replay.isPreview)
                {
                    newGameResults.is_preview = true;
                    newGameResults.score = _song.totalNotes * 50;
                    newGameResults.amazing = _song.totalNotes;
                    newGameResults.max_combo = _song.totalNotes;
                }

                newGameResults.update(_gvars);
                _gvars.songResults.push(newGameResults);
            }

            _gvars.sessionStats.addFromStats(_gvars.songStats);
            _gvars.songStats.reset();

            if (!_legacyMode && !_options.replay && !_options.isEditor && !_mpSpectate)
            {
                _avars.configMusicOffset = (_avars.configMusicOffset * 0.85) + _songOffset.value * 0.15;

                // Cap between 5 seconds for sanity.
                if (Math.abs(_avars.configMusicOffset) >= 5000)
                {
                    _avars.configMusicOffset = Math.max(-5000, Math.min(5000, _avars.configMusicOffset));
                }

                _avars.musicOffsetSave();
            }

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                _socketScoreMessage["amazing"] = _hitAmazing;
                _socketScoreMessage["perfect"] = _hitPerfect;
                _socketScoreMessage["good"] = _hitGood;
                _socketScoreMessage["average"] = _hitAverage;
                _socketScoreMessage["boo"] = _hitBoo;
                _socketScoreMessage["miss"] = _hitMiss;
                _socketScoreMessage["combo"] = _hitCombo;
                _socketScoreMessage["maxcombo"] = _hitMaxCombo;
                _socketScoreMessage["score"] = _gameScore;
                _socketScoreMessage["last_hit"] = null;
                _gvars.websocketSend("NOTE_JUDGE", _socketScoreMessage);
                _gvars.websocketSend("SONG_END", _socketSongMessage);
            }

            // Cleanup
            initVars(false);

            if (_song != null)
                _song.stop();

            _song = null;

            if (_songBackground)
            {
                this.removeChild(_songBackground);
                _songBackground = null;
            }

            // Remove Notes
            if (_noteBox != null)
            {
                _noteBox.reset();
            }

            // Remove UI
            if (_gpuPixelBitmap)
            {
                this.removeChild(_gpuPixelBitmap);
                _gpuPixelBitmap = null;
                _gpuPixelBitmapData = null;
            }
            if (_displayBlackBG)
            {
                this.removeChild(_displayBlackBG);
                _displayBlackBG = null;
            }
            if (_progressDisplay)
            {
                this.removeChild(_progressDisplay);
                _progressDisplay = null;
            }
            if (_player1Life)
            {
                this.removeChild(_player1Life);
                _player1Life = null;
            }
            if (_player1Judge)
            {
                this.removeChild(_player1Judge);
                _player1Judge = null;
            }
            if (_gameplayUI)
            {
                this.removeChild(_gameplayUI);
                _gameplayUI = null;
            }
            if (_noteBox)
            {
                this.removeChild(_noteBox);
                _noteBox = null;
            }
            if (_displayBlackBG)
            {
                this.removeChild(_displayBlackBG);
                _displayBlackBG = null;
            }
            if (_flashLight)
            {
                this.removeChild(_flashLight);
                _flashLight = null;
            }
            if (_screenCut)
            {
                this.removeChild(_screenCut);
                _screenCut = null;
            }
            if (_exitEditor)
            {
                _exitEditor.dispose();
                this.removeChild(_exitEditor);
                _exitEditor = null;
            }

            _GAME_STATE = GAME_DISPOSE;

            var screen:int = _options.settings.startUpScreen;
            if (!_options.user.isGuest && (screen == 0 || screen == 1) && !MultiplayerState.instance.connection.connected)
            {
                MultiplayerState.instance.connection.connect();
            }

            // Go to results
            if (_options.isEditor || _mpSpectate)
                dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
            else
                dispatchEvent(new ChangePanelEvent(Routes.GAME_RESULTS));
        }

        private function restartGame():void
        {
            // Remove Notes
            _noteBox.reset();

            if (_player1PAWindow)
                _player1PAWindow.reset();

            if (_accBar)
                _accBar.onResetSignal();

            _noteBoxOffset = {"x": 0, "y": 0};

            // Track
            var tempGT:Number = ((_hitAmazing + _hitPerfect) * 500) + (_hitGood * 250) + (_hitAverage * 50) + (_hitCombo * 1000) - (_hitMiss * 300) - (_hitBoo * 15) + _gameScore;
            _gvars.songStats.amazing += _hitAmazing;
            _gvars.songStats.perfect += _hitPerfect;
            _gvars.songStats.good += _hitGood;
            _gvars.songStats.average += _hitAverage;
            _gvars.songStats.miss += _hitMiss;
            _gvars.songStats.boo += _hitBoo;
            _gvars.songStats.raw_score += _gameScore;
            _gvars.songStats.amazing += _hitAmazing;
            _gvars.songStats.grandtotal += tempGT;
            _gvars.songStats.credits += Math.round(tempGT / _gvars.SCORE_PER_CREDIT);
            _gvars.songStats.restarts++;

            // Restart
            _song.reset();
            _GAME_STATE = GAME_PLAY;
            initPlayerVars();
            initVars();
            if (_player1Judge)
                _player1Judge.hideJudge();
            _gvars.songRestarts++;

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                _socketScoreMessage["restarts"] = _gvars.songRestarts;
                _gvars.websocketSend("NOTE_JUDGE", _socketScoreMessage);
                _gvars.websocketSend("SONG_RESTART", _socketSongMessage);
            }
        }

        /*#########################################################################################*\
         *			_____     ___               _   _
         *	 /\ /\  \_   \   / __\ __ ___  __ _| |_(_) ___  _ __
         *	/ / \ \  / /\/  / / | '__/ _ \/ _` | __| |/ _ \| '_ \
         *	\ \_/ /\/ /_   / /__| | |  __/ (_| | |_| | (_) | | | |
         *	 \___/\____/   \____/_|  \___|\__,_|\__|_|\___/|_| |_|
         *
           \*#########################################################################################*/
        private function buildFlashlight():void
        {
            if (_options.modEnabled("flashlight"))
            {
                if (_flashLight == null)
                    _flashLight = new FlashlightOverlay();

                if (!contains(_flashLight))
                    addChild(_flashLight);
            }
            else if (_flashLight != null && this.contains(_flashLight))
            {
                removeChild(_flashLight);
            }
        }

        private function buildScreenCut():void
        {
            if (!_options.settings.displayScreencut)
                return;

            if (_screenCut)
            {
                if (this.contains(_screenCut))
                    this.removeChild(_screenCut);
                _screenCut = null;
            }
            _screenCut = new ScreenCut(_options);
            this.addChild(_screenCut);
        }

        private function buildJudge():void
        {
            if (!_options.settings.displayJudge)
                return;

            _player1Judge = new Judge(_options);
            addChild(_player1Judge);
            if (_options.isEditor)
                _player1Judge.showJudge(100, true);
        }

        private function buildHealth():void
        {
            if (!_options.settings.displayHealth)
                return;

            _player1Life = new LifeBar();
            _player1Life.x = Main.GAME_WIDTH - 37;
            _player1Life.y = 71.5;
            addChild(_player1Life);
        }

        private function buildMultiplayer():void
        {
            _mpJudge = [];
            _mpPA = [];
            _mpCombo = [];
            _mpHeader = [];

            if (!_options.settings.displayMPUI && !_mpSpectate)
                return;

            for each (var user:User in _options.mpRoom.players)
            {
                if (user.id == _options.mpRoom.connection.currentUser.id)
                {
                    if (_player1PAWindow)
                        _mpPA[user.playerIdx] = _player1PAWindow;
                    if (_player1Combo)
                        _mpCombo[user.playerIdx] = _player1Combo;
                    if (_player1Judge)
                        _mpJudge[user.playerIdx] = _player1Judge;
                    continue;
                }

                if (_options.settings.displayMPPA)
                {
                    var pa:PAWindow = new PAWindow(_options);
                    addChild(pa);
                    _mpPA[user.playerIdx] = pa;
                }

                if (_mpSpectate)
                {
                    var header:MPHeader = new MPHeader(user);
                    if (_options.settings.displayMPPA)
                        _mpPA[user.playerIdx].addChild(header);
                    else
                        addChild(header);
                    _mpHeader[user.playerIdx] = header;
                }

                if (_options.settings.displayMPCombo)
                {
                    var combo:Combo = new Combo(_options);
                    addChild(combo);
                    _mpCombo[user.playerIdx] = combo;
                }

                if (_options.settings.displayMPJudge)
                {
                    var judge:Judge = new Judge(_options);
                    addChild(judge);
                    _mpJudge[user.playerIdx] = judge;
                    if (_options.isEditor)
                        judge.showJudge(100, true);
                }
            }
        }

        private function interfaceLayout(key:String, defaults:Boolean = true):Object
        {
            if (defaults)
            {
                var ret:Object = {};
                var def:Object = _defaultLayout[key];
                for (var i:String in def)
                    ret[i] = def[i];
                var layout:Object = _options.layout[key];
                for (i in layout)
                    ret[i] = layout[i];
                return ret;
            }
            else if (!_options.layout[key])
                _options.layout[key] = {};
            return _options.layout[key];
        }

        private function interfaceSetup():void
        {
            _defaultLayout = {};
            _defaultLayout[LAYOUT_PROGRESS_BAR] = {x: 161, y: 9};
            _defaultLayout[LAYOUT_PROGRESS_TEXT] = {x: 768, y: 5, properties: {alignment: "right"}};
            _defaultLayout[LAYOUT_JUDGE] = {x: 392, y: 228};
            _defaultLayout[LAYOUT_ACCURACY_BAR] = {x: (Main.GAME_WIDTH / 2), y: 328};
            _defaultLayout[LAYOUT_HEALTH] = {x: Main.GAME_WIDTH - 37, y: 71.5};
            _defaultLayout[LAYOUT_RECEPTORS] = {x: 230, y: 0};
            if (_sideScroll)
            {
                _defaultLayout[LAYOUT_PA] = {x: 16, y: 418};
                _defaultLayout[LAYOUT_SCORE] = {x: 392, y: 24};
                _defaultLayout[LAYOUT_COMBO] = {x: 508, y: 388};
                _defaultLayout[LAYOUT_COMBO_TOTAL] = {x: 770, y: 420, properties: {alignment: "right"}};
                _defaultLayout[LAYOUT_COMBO_STATIC] = {x: 512, y: 438};
                _defaultLayout[LAYOUT_COMBO_TOTAL_STATIC] = {x: 734, y: 414};
            }
            else
            {
                _defaultLayout[LAYOUT_PA] = {x: 6, y: 96};
                _defaultLayout[LAYOUT_SCORE] = {x: 392, y: 440};
                _defaultLayout[LAYOUT_COMBO] = {x: 222, y: 402, properties: {alignment: "right"}};
                _defaultLayout[LAYOUT_COMBO_TOTAL] = {x: 544, y: 402};
                _defaultLayout[LAYOUT_COMBO_STATIC] = {x: 228, y: 436};
                _defaultLayout[LAYOUT_COMBO_TOTAL_STATIC] = {x: 502, y: 436};
            }

            // Multiplayer
            _defaultLayout[LAYOUT_MP_COMBO + "1"] = _defaultLayout[LAYOUT_COMBO];
            _defaultLayout[LAYOUT_MP_JUDGE + "1"] = {x: 208, y: 102};
            _defaultLayout[LAYOUT_MP_PA + "1"] = {x: 6, y: 96};
            if (_options.settings.displayMPPA)
                _defaultLayout[LAYOUT_MP_HEADER + "1"] = {x: 0, y: -35};
            else
                _defaultLayout[LAYOUT_MP_HEADER + "1"] = {x: 6, y: 190};

            _defaultLayout[LAYOUT_MP_COMBO + "2"] = _defaultLayout[LAYOUT_COMBO_TOTAL];
            _defaultLayout[LAYOUT_MP_JUDGE + "2"] = {x: 568, y: 102};
            _defaultLayout[LAYOUT_MP_PA + "2"] = {x: 645, y: 96, properties: {alignment: "right"}};
            if (_options.settings.displayMPPA)
                _defaultLayout[LAYOUT_MP_HEADER + "2"] = {x: 25, y: -35, properties: {alignment: MPHeader.ALIGN_RIGHT}};
            else
                _defaultLayout[LAYOUT_MP_HEADER + "2"] = {x: 690, y: 190, properties: {alignment: MPHeader.ALIGN_RIGHT}};

            if (_mpSpectate)
            {
                _defaultLayout[LAYOUT_MP_PA + "1"]["y"] += 84;
                _defaultLayout[LAYOUT_MP_PA + "2"]["y"] += 84;
            }

            _noteBoxPositionDefault = interfaceLayout(LAYOUT_RECEPTORS);

            // Position
            interfacePosition(_progressDisplay, interfaceLayout(LAYOUT_PROGRESS_BAR));
            interfacePosition(_progressDisplayText, interfaceLayout(LAYOUT_PROGRESS_TEXT));
            interfacePosition(_noteBox, interfaceLayout(LAYOUT_RECEPTORS));
            interfacePosition(_accBar, interfaceLayout(LAYOUT_ACCURACY_BAR));
            interfacePosition(_player1Life, interfaceLayout(LAYOUT_HEALTH));
            interfacePosition(_score, interfaceLayout(LAYOUT_SCORE));
            interfacePosition(_comboTotal, interfaceLayout(LAYOUT_COMBO_TOTAL));
            interfacePosition(_comboStatic, interfaceLayout(LAYOUT_COMBO_STATIC));
            interfacePosition(_comboTotalStatic, interfaceLayout(LAYOUT_COMBO_TOTAL_STATIC));

            if (!_options.mpRoom)
            {
                interfacePosition(_player1PAWindow, interfaceLayout(LAYOUT_PA));
                interfacePosition(_player1Combo, interfaceLayout(LAYOUT_COMBO));
                interfacePosition(_player1Judge, interfaceLayout(LAYOUT_JUDGE));
            }

            // Editor Mode
            if (_options.isEditor)
            {
                interfaceEditor(_progressDisplay, interfaceLayout(LAYOUT_PROGRESS_BAR, false));
                interfaceEditor(_progressDisplayText, interfaceLayout(LAYOUT_PROGRESS_TEXT, false));
                interfaceEditor(_noteBox, interfaceLayout(LAYOUT_RECEPTORS, false));
                interfaceEditor(_accBar, interfaceLayout(LAYOUT_ACCURACY_BAR, false));
                interfaceEditor(_player1Life, interfaceLayout(LAYOUT_HEALTH, false));
                interfaceEditor(_score, interfaceLayout(LAYOUT_SCORE, false));
                interfaceEditor(_comboTotal, interfaceLayout(LAYOUT_COMBO_TOTAL, false));
                interfaceEditor(_comboStatic, interfaceLayout(LAYOUT_COMBO_STATIC, false));
                interfaceEditor(_comboTotalStatic, interfaceLayout(LAYOUT_COMBO_TOTAL_STATIC, false));

                if (!_options.mpRoom)
                {
                    interfaceEditor(_player1PAWindow, interfaceLayout(LAYOUT_PA, false));
                    interfaceEditor(_player1Combo, interfaceLayout(LAYOUT_COMBO, false));
                    interfaceEditor(_player1Judge, interfaceLayout(LAYOUT_JUDGE, false));
                }
            }

            // Multiplayer
            if (_options.mpRoom)
            {
                for each (var user:User in _options.mpRoom.players)
                {
                    interfacePosition(_mpJudge[user.playerIdx], interfaceLayout(LAYOUT_MP_JUDGE + user.playerIdx));
                    interfacePosition(_mpCombo[user.playerIdx], interfaceLayout(LAYOUT_MP_COMBO + user.playerIdx));
                    interfacePosition(_mpPA[user.playerIdx], interfaceLayout(LAYOUT_MP_PA + user.playerIdx));
                    interfacePosition(_mpHeader[user.playerIdx], interfaceLayout(LAYOUT_MP_HEADER + user.playerIdx));

                    // Multiplayer - Editor
                    if (_options.isEditor)
                    {
                        interfaceEditor(_mpJudge[user.playerIdx], interfaceLayout(LAYOUT_MP_JUDGE + user.playerIdx, false));
                        interfaceEditor(_mpCombo[user.playerIdx], interfaceLayout(LAYOUT_MP_COMBO + user.playerIdx, false));
                        interfaceEditor(_mpPA[user.playerIdx], interfaceLayout(LAYOUT_MP_PA + user.playerIdx, false));
                        interfaceEditor(_mpHeader[user.playerIdx], interfaceLayout(LAYOUT_MP_HEADER + user.playerIdx, false));
                    }
                }
            }
        }

        private function interfacePosition(sprite:Sprite, layout:Object):void
        {
            if (!sprite)
                return;

            if ("x" in layout)
                sprite.x = layout["x"];
            if ("y" in layout)
                sprite.y = layout["y"];
            if ("rotation" in layout)
                sprite.rotation = layout["rotation"];
            if ("visible" in layout)
                sprite.visible = layout["visible"];
            for (var p:String in layout.properties)
                sprite[p] = layout.properties[p];
        }

        private function interfaceEditor(sprite:Sprite, layout:Object):void
        {
            if (!sprite)
                return;

            sprite.mouseChildren = false;
            sprite.buttonMode = true;
            sprite.useHandCursor = true;

            sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
            {
                sprite.startDrag(false);
            });
            sprite.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
            {
                sprite.stopDrag();
                layout["x"] = sprite.x;
                layout["y"] = sprite.y;
                _avars.interfaceSave();
            });
        }

        /*#########################################################################################*\
         *	   ___                           _
         *	  / _ \__ _ _ __ ___   ___ _ __ | | __ _ _   _
         *	 / /_\/ _` | '_ ` _ \ / _ \ '_ \| |/ _` | | | |
         *	/ /_\\ (_| | | | | | |  __/ |_) | | (_| | |_| |
         *	\____/\__,_|_| |_| |_|\___| .__/|_|\__,_|\__, |
         *							  |_|            |___/
           \*#########################################################################################*/

        private function buildJudgeNodes(src:Array):Vector.<JudgeNode>
        {
            var out:Vector.<JudgeNode> = new Vector.<JudgeNode>(src.length, true);
            for (var i:int = 0; i < src.length; i++)
            {
                out[i] = new JudgeNode(src[i].t, src[i].s, src[i].f);
            }
            return out;
        }

        /**
         * Judge a note score based on the current song position in ms.
         * @param dir Note Direction
         * @param position Time in MS.
         * @return
         */
        private function judgeScorePosition(dir:String, position:int):Boolean
        {
            if (position < 0)
                position = 0;
            var positionJudged:int = position + _judgeOffset;

            var score:int = 0;
            var frame:int = 0;
            var booConflict:Boolean = false;
            for each (var note:GameNote in _noteBox.notes)
            {
                if (note.DIR != dir)
                    continue;

                var acc:Number = note.POSITION - position;
                var diff:Number = positionJudged - note.POSITION;
                var lastJudge:JudgeNode = null;
                for each (var j:JudgeNode in _judgeSettings)
                {
                    if (diff > j.time)
                        lastJudge = j;
                }
                score = lastJudge ? lastJudge.score : 0;
                if (score)
                    frame = lastJudge.frame;
                if (!_avars.configJudge && !score)
                {
                    var pdiff:int = _gameProgress - note.PROGRESS + _player1JudgeOffset;
                    if (pdiff >= -3 && pdiff <= 3)
                        booConflict = true;
                }
                if (score > 0)
                    break;
                else if (diff <= _judgeSettings[0].time)
                    break;
            }
            if (score)
            {
                commitJudge(dir, frame + note.PROGRESS - _player1JudgeOffset, score);
                _noteBox.removeNote(note.ID);
                _accuracy.addValue(acc);
                _binReplayNotes[note.ID].time = diff;

                if (_accBar != null)
                    _accBar.onScoreSignal(score, diff);
            }
            else
            {
                var booFrame:int = _gameProgress;
                if (booConflict)
                {
                    var noteIndex:int = 0;
                    note = _noteBox.notes[noteIndex++] || _noteBox.spawnNextNote();
                    while (note)
                    {
                        if (booFrame + _player1JudgeOffset < note.PROGRESS - 3)
                            break;
                        if (note.DIR == dir)
                            booFrame = note.PROGRESS + 4 - _player1JudgeOffset;

                        note = _noteBox.notes[noteIndex++] || _noteBox.spawnNextNote();
                    }
                }

                if (booFrame >= _gameFirstNoteFrame)
                    _binReplayBoos[_binReplayBoos.length] = new ReplayBinFrame(position, dir, _binReplayBoos.length);

                commitJudge(dir, booFrame, -5);
            }

            if (_options.modEnabled("tap_pulse"))
            {
                if (dir == "L")
                    _noteBoxOffset.x -= Math.abs(_options.settings.receptorGap * 0.20);
                if (dir == "R")
                    _noteBoxOffset.x += Math.abs(_options.settings.receptorGap * 0.20);
                if (dir == "U")
                    _noteBoxOffset.y -= Math.abs(_options.settings.receptorGap * 0.15);
                if (dir == "D")
                    _noteBoxOffset.y += Math.abs(_options.settings.receptorGap * 0.15);
            }

            return Boolean(score);
        }

        private function judgeScore(dir:String, frame:int):Boolean
        {
            var score:int = 0;
            for each (var note:GameNote in _noteBox.notes)
            {
                if (note.DIR != dir)
                    continue;

                var diff:int = frame + _player1JudgeOffset - note.PROGRESS;
                switch (diff)
                {
                    case -3:
                        score = 5;
                        break;
                    case -2:
                        score = 25;
                        break;
                    case -1:
                        score = 50;
                        break;
                    case 0:
                        score = 100;
                        break;
                    case 1:
                        score = 50;
                        break;
                    case 2:
                    case 3:
                        score = 25;
                        break;
                    default:
                        score = 0;
                        break;
                }

                if (score > 0)
                    break;
                else if (diff < -3)
                    break;
            }

            if (_options.modEnabled("tap_pulse"))
            {
                if (dir == "L")
                    _noteBoxOffset.x -= Math.abs(_options.settings.receptorGap * 0.20);
                if (dir == "R")
                    _noteBoxOffset.x += Math.abs(_options.settings.receptorGap * 0.20);
                if (dir == "U")
                    _noteBoxOffset.y -= Math.abs(_options.settings.receptorGap * 0.15);
                if (dir == "D")
                    _noteBoxOffset.y += Math.abs(_options.settings.receptorGap * 0.15);
            }

            if (score)
            {
                commitJudge(dir, frame, score);
                _noteBox.removeNote(note.ID);
                _accuracy.addValue((note.PROGRESS - frame) * 1000 / 30);

                if (_accBar != null)
                    _accBar.onScoreSignal(score, diff * 33.3333 - 1);
            }
            else
                commitJudge(dir, frame, -5);

            return Boolean(score);
        }

        private function commitJudge(dir:String, frame:int, score:int):void
        {
            var health:int = 0;
            var jscore:int = score;
            _noteBox.receptorFeedback(dir, score);
            switch (score)
            {
                case 100:
                    _hitAmazing++;
                    _hitCombo++;
                    _gameScore += 50;
                    health = 1;
                    if (_options.settings.displayAmazing)
                    {
                        checkAutofail(_options.settings.autofail[0], _hitAmazing);
                    }
                    else
                    {
                        jscore = 50;
                        checkAutofail(_options.settings.autofail[0] + _options.settings.autofail[1], _hitAmazing + _hitPerfect);
                    }
                    checkAutofail(_options.settings.autofail[6], _gameRawGoods);
                    break;
                case 50:
                    _hitPerfect++;
                    _hitCombo++;
                    _gameScore += 50;
                    health = 1;
                    checkAutofail(_options.settings.autofail[1], _hitPerfect);
                    checkAutofail(_options.settings.autofail[6], _gameRawGoods);
                    break;
                case 25:
                    _hitGood++;
                    _hitCombo++;
                    _gameScore += 25;
                    _gameRawGoods += 1;
                    health = 1;
                    checkAutofail(_options.settings.autofail[2], _hitGood);
                    checkAutofail(_options.settings.autofail[6], _gameRawGoods);
                    break;
                case 5:
                    _hitAverage++;
                    _hitCombo++;
                    _gameScore += 5;
                    _gameRawGoods += 1.8;
                    health = 1;
                    checkAutofail(_options.settings.autofail[3], _hitAverage);
                    checkAutofail(_options.settings.autofail[6], _gameRawGoods);
                    break;
                case -5:
                    if (frame < _gameFirstNoteFrame)
                        return;
                    _hitBoo++;
                    _gameScore -= 5;
                    _gameRawGoods += 0.2;
                    health = -1;
                    checkAutofail(_options.settings.autofail[5], _hitBoo);
                    checkAutofail(_options.settings.autofail[6], _gameRawGoods);
                    break;
                case -10:
                    _hitMiss++;
                    _hitCombo = 0;
                    _gameScore -= 10;
                    _gameRawGoods += 2.4;
                    health = -1;
                    checkAutofail(_options.settings.autofail[4], _hitMiss);
                    checkAutofail(_options.settings.autofail[6], _gameRawGoods);
                    break;
            }

            if (_options.isAutoplay)
            {
                _gameScore = 0;
                _hitAmazing = 0;
                _hitPerfect = 0;
                _hitGood = 0;
                _hitAverage = 0;
            }

            if (_player1Judge && !_options.isEditor)
                _player1Judge.showJudge(jscore);

            updateHealth(health > 0 ? _gvars.HEALTH_JUDGE_ADD : _gvars.HEALTH_JUDGE_REMOVE);

            if (_hitCombo > _hitMaxCombo)
                _hitMaxCombo = _hitCombo;

            if (score == -10)
                _gameReplayHit.push(0);
            else if (score == -5)
                score = 0;

            if (score > 0)
                _gameReplayHit.push(score);

            if (score >= 0)
                _gameReplay.push(new ReplayNote(dir, frame, (getTimer() - _msStartTime), score));

            updateFieldVars();

            if (_options.mpRoom)
            {
                dispatchEvent(new GameUpdateEvent({_gameScore: _gameScore,
                        _gameLife: _gameLife,
                        _hitMaxCombo: _hitMaxCombo,
                        _hitCombo: _hitCombo,
                        _hitAmazing: _hitAmazing,
                        _hitPerfect: _hitPerfect,
                        _hitGood: _hitGood,
                        _hitAverage: _hitAverage,
                        _hitMiss: _hitMiss,
                        _hitBoo: _hitBoo}));
            }

            // Websocket
            if (_gvars.air_useWebsockets)
            {
                _socketScoreMessage["amazing"] = _hitAmazing;
                _socketScoreMessage["perfect"] = _hitPerfect;
                _socketScoreMessage["good"] = _hitGood;
                _socketScoreMessage["average"] = _hitAverage;
                _socketScoreMessage["boo"] = _hitBoo;
                _socketScoreMessage["miss"] = _hitMiss;
                _socketScoreMessage["combo"] = _hitCombo;
                _socketScoreMessage["maxcombo"] = _hitMaxCombo;
                _socketScoreMessage["score"] = _gameScore;
                _socketScoreMessage["last_hit"] = score;
                _gvars.websocketSend("NOTE_JUDGE", _socketScoreMessage);
            }
        }

        private function checkAutofail(autofail:Number, hit:Number):void
        {
            if (autofail > 0 && hit >= autofail)
                _GAME_STATE = GAME_END;
        }

        /*#########################################################################################*\
         *		   _                 _                   _       _
         *	/\   /(_)___ _   _  __ _| |  /\ /\ _ __   __| | __ _| |_ ___  ___
         *	\ \ / / / __| | | |/ _` | | / / \ \ '_ \ / _` |/ _` | __/ _ \/ __|
         *	 \ V /| \__ \ |_| | (_| | | \ \_/ / |_) | (_| | (_| | ||  __/\__ \
         *	  \_/ |_|___/\__,_|\__,_|_|  \___/| .__/ \__,_|\__,_|\__\___||___/
         *									  |_|
           \*#########################################################################################*/

        private function updateHealth(val:int):void
        {
            _gameLife += val;
            if (_gameLife <= 0)
            {
                _GAME_STATE = GAME_END;
            }
            else if (_gameLife > 100)
            {
                _gameLife = 100;
            }
            if (_player1Life)
                _player1Life.health = _gameLife;
        }

        private function updateFieldVars():void
        {
            //gameplayUI.sDisplay_score.text = gameScore.toString();

            if (_player1PAWindow)
                _player1PAWindow.update(_hitAmazing, _hitPerfect, _hitGood, _hitAverage, _hitMiss, _hitBoo);

            if (_score)
                _score.update(_gameScore);

            if (_player1Combo)
                _player1Combo.update(_hitCombo, _hitAmazing, _hitPerfect, _hitGood, _hitAverage, _hitMiss, _hitBoo, _gameRawGoods);
        }

        private var previousDiffs:Array = new Array();

        private function multiplayerDiff(id:int, data:Object):Object
        {
            var previousDiff:Object = previousDiffs[id];
            if (!previousDiff)
                previousDiff = (previousDiffs[id] = {amazing: 0, perfect: 0, good: 0, average: 0, miss: 0, boo: 0});

            var diff:Object = {amazing: data.amazing - previousDiff.amazing,
                    perfect: data.perfect - previousDiff.perfect,
                    good: data.good - previousDiff.good,
                    average: data.average - previousDiff.average,
                    miss: data.miss - previousDiff.miss,
                    boo: data.boo - previousDiff.boo};

            previousDiff.amazing = data.amazing;
            previousDiff.perfect = data.perfect;
            previousDiff.good = data.good;
            previousDiff.average = data.average;
            previousDiff.miss = data.miss;
            previousDiff.boo = data.boo;

            return diff;
        }

        private var multiplayerResults:Array = [];

        public function onMultiplayerUpdate(event:GameUpdateEvent):void
        {
            var user:User = event.user;
            var gameplay:Gameplay = user.gameplay;

            if (!gameplay || !_options.mpRoom.isPlayer(user) || user.id == _options.mpRoom.connection.currentUser.id)
                return;

            var diff:Object = multiplayerDiff(user.id, gameplay);

            var combo:Combo = _mpCombo[user.playerIdx];
            if (combo)
                combo.update(gameplay.combo, gameplay.amazing, gameplay.perfect, gameplay.good, gameplay.average, gameplay.miss, gameplay.boo);

            var pa:PAWindow = _mpPA[user.playerIdx];
            if (pa)
                pa.update(gameplay.amazing, gameplay.perfect, gameplay.good, gameplay.average, gameplay.miss, gameplay.boo);

            var judge:Judge = _mpJudge[user.playerIdx];
            if (judge)
            {
                var value:int = 0;
                if (diff.miss > 0)
                    value = -10;
                else if (diff.boo > 0)
                    value = -5;
                else if (diff.average > 0)
                    value = 5;
                else if (diff.good > 0)
                    value = 25;
                else if (diff.amazing > 0)
                    value = 100;
                else if (diff.perfect > 0)
                    value = 50;

                if (value != 0)
                    judge.showJudge(value);
            }

            if (gameplay.status == Multiplayer.STATUS_RESULTS && !multiplayerResults[user.playerIdx])
            {
                multiplayerResults[user.playerIdx] = true;
                Alert.add(user.name + " finished playing the song", 240, Alert.RED);
            }
        }

        public function onMultiplayerResults(event:GameResultsEvent):void
        {
            if (event.room == _options.mpRoom)
                _GAME_STATE = GAME_END;
        }

        private function addLoaderListeners():void
        {
            _loader.addEventListener(Event.COMPLETE, siteLoadComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
        }

        private function removeLoaderListeners():void
        {
            _loader.removeEventListener(Event.COMPLETE, siteLoadComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, siteLoadError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, siteLoadError);
        }

        public function getScriptVariable(key:String):*
        {
            return this[key];
        }

        public function setScriptVariable(key:String, val:*):void
        {
            this[key] = val;
        }
    }
}

internal class JudgeNode
{
    public var time:Number;
    public var frame:Number;
    public var score:Number;

    public function JudgeNode(time:Number, score:Number, frame:Number = -1)
    {
        this.time = time;
        this.score = score;
        this.frame = frame;
    }
}
