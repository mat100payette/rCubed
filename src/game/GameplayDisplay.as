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
    import classes.UserSettings;
    import classes.replay.Replay;
    import com.flashfla.utils.VectorUtil;
    import classes.Room;
    import events.navigation.ShowGameResultsEvent;
    import events.navigation.StartGameplayEvent;
    import state.AppState;
    import events.state.SetPopupsEnabledEvent;
    import events.SendWebsocketMessageEvent;
    import state.ContentState;

    public class GameplayDisplay extends DisplayLayer
    {
        public static const GAME_DISPOSE:int = -1;
        public static const GAME_PLAY:int = 0;
        public static const GAME_END:int = 1;
        public static const GAME_RESTART:int = 2;
        public static const GAME_PAUSE:int = 3;

        public static const SOLO:int = 0;
        public static const MP:int = 1;
        public static const SPECTATOR:int = 2;

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

        private var _avars:ArcGlobals = ArcGlobals.instance;
        private var _noteskins:NoteskinsList = NoteskinsList.instance;
        private var _lang:Language = Language.instance;

        private var _loader:URLLoader;

        private var _mode:int;
        private var _isEditor:Boolean;
        private var _isAutoplay:Boolean;
        private var _replay:Replay;

        private var _keys:Array;
        private var _song:Song;
        private var _user:User;
        private var _settings:UserSettings;
        private var _songBackground:MovieClip;
        private var _legacyMode:Boolean;

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

        private var _mpRoom:Room;
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

        private var _gameState:uint = GAME_PLAY;

        private var _socketSongMessage:Object = {};
        private var _socketScoreMessage:Object = {};

        // Anti-GPU Rampdown Hack
        private var _gpuPixelBitmapData:BitmapData;
        private var _gpuPixelBitmap:Bitmap;

        public function GameplayDisplay(song:Song, user:User, mode:int, isEditor:Boolean, isAutoplay:Boolean, replay:Replay, mpRoom:Room)
        {
            //if (mpRoom && mode == SOLO)
            //    throw new Error("Cannot provide both an MP room and SOLO mode.");

            _user = replay ? replay.user : user;
            _settings = new UserSettings();
            _settings.update(_user.settings);

            if (replay && !song)
                _song = _gvars.getSongFile(replay.songInfo, _settings);
            else if (mpRoom)
                _song = song != null ? song : _gvars.getSongFile(mpRoom.songInfo, _settings);
            else
                _song = song;

            _mode = mode;
            _isEditor = isEditor;
            _isAutoplay = isAutoplay;
            _replay = replay;
            _mpRoom = mpRoom;

            init();
        }

        public function init():void
        {
            if (!_isEditor && _song.chart.notes.length == 0)
            {
                Alert.add(_lang.string("error_chart_has_no_notes"), 120, Alert.RED);

                var screen:int = _user.settings.startUpScreen;
                if (!_user.isGuest && (screen == 0 || screen == 1) && !MultiplayerState.instance.connection.connected)
                {
                    MultiplayerState.instance.connection.connect();
                }

                dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
            }

            // --- Per Song Options
            var perSongOptions:SQLSongUserInfo = SQLQueries.getSongUserInfo(_song.songInfo);
            if (perSongOptions != null && !_isEditor && !_replay)
            {
                // Custom Offsets
                if (perSongOptions.set_custom_offsets)
                {
                    _user.settings.judgeOffset = perSongOptions.offset_judge;
                    _user.settings.globalOffset = perSongOptions.offset_music;
                }

                // Invert Mirror Mod
                if (perSongOptions.set_mirror_invert)
                {
                    if (_settings.mods.mirror)
                        _settings.activeMods.removeAt(_settings.activeMods.indexOf("mirror"));
                    else
                        _settings.activeMods.push("mirror");
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
                        "settings": _settings.stringify(),
                        "name": _user.name,
                        "userid": _user.siteId,
                        "avatar": Constant.USER_AVATAR_URL + "?uid=" + _user.siteId,
                        "skill_rating": _user.skillRating,
                        "skill_level": _user.skillLevel,
                        "game_rank": _user.gameRank,
                        "game_played": _user.gamesPlayed,
                        "game_grand_total": _user.grandTotal
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
                        "author_url": _song.songInfo.stepauthorUrl,
                        "stepauthor": _song.songInfo.stepauthor,
                        "credits": _song.songInfo.credits,
                        "genre": _song.songInfo.genre,
                        "nps_min": _song.songInfo.minNps,
                        "nps_max": _song.songInfo.maxNps,
                        // TODO: Check these fields
                        //"release_date": song.songInfo.releasedate,
                        //"song_rating": song.songInfo.song_rating,
                        // Trust the chart, not the playlist.
                        "time": _song.chartTimeFormatted,
                        "time_seconds": _song.chartTime,
                        "note_count": _song.totalNotes,
                        "nps_avg": (_song.totalNotes / _song.chartTime)
                    },
                    "best_score": _user.getLevelRank(_song.songInfo)};

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
            if (_isEditor)
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
            if (_gvars.songQueueIndex + 1 < _gvars.songQueue.length)
                _gvars.getSongFile(_gvars.songQueue[_gvars.songQueueIndex + 1], _settings);


            // Setup MP Things
            if (_mpRoom)
            {
                MultiplayerState.instance.gameplayPlaying(this);
                if (!_isEditor)
                {
                    _mpRoom.connection.addEventListener(Multiplayer.EVENT_GAME_UPDATE, onMultiplayerUpdate);
                    if (_mpSpectate)
                        _mpRoom.connection.addEventListener(Multiplayer.EVENT_GAME_RESULTS, onMultiplayerResults);
                }
            }

            stage.focus = stage;

            interfaceSetup();

            // TODO: dispatch action to state manager
            dispatchEvent(new SetPopupsEnabledEvent(false));
            AppState.instance.menu.disablePopups = true;

            if (!_isEditor && !_replay && !_mpSpectate)
                Mouse.hide();

            if (_song.songInfo && _song.songInfo.name)
                stage.nativeWindow.title = Constant.AIR_WINDOW_TITLE + " - " + _song.songInfo.name;

            // Add onEnterFrame Listeners
            if (_isEditor)
            {
                _isAutoplay = true;
                stage.frameRate = _settings.frameRate;
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
            if (_isEditor)
            {
                stage.removeEventListener(Event.ENTER_FRAME, editorOnEnterFrame);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, editorKeyboardKeyDown);
            }
            else
            {
                stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardKeyDown, true);
                stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardKeyUp, true);

                if (_mpRoom)
                {
                    _mpRoom.connection.removeEventListener(Multiplayer.EVENT_GAME_UPDATE, onMultiplayerUpdate);
                    _mpRoom.connection.removeEventListener(Multiplayer.EVENT_GAME_RESULTS, onMultiplayerResults);
                }
            }

            // TODO: dispatch action to state manager
            AppState.instance.menu.disablePopups = false;

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
            if (_settings.isolationOffset >= _song.chart.notes.length)
                _settings.isolationOffset = _song.chart.notes.length - 1;

            // Song
            _song.updateMusicDelay();
            _legacyMode = (_song.type == NoteChart.FFR || _song.type == NoteChart.FFR_RAW || _song.type == NoteChart.FFR_LEGACY);

            if (_song.clip && (_legacyMode || !_settings.mods.noBackground))
            {
                _songBackground = _song.clip;
                _gameSongFrames = _songBackground.totalFrames;
                _songBackground.x = 115;
                _songBackground.y = 42.5;
                addChild(_songBackground);

                if (_settings.mods.noBackground)
                    setChildIndex(_songBackground, 0);
            }

            _song.start();
            _songDelay = _song.mp3Frame / _settings.songRate * 1000 / 30 - _globalOffset;
        }

        private function initBackground():void
        {
            // Anti-GPU Rampdown Hack
            _gpuPixelBitmapData = new BitmapData(1, 1, false, 0x010101);
            _gpuPixelBitmap = new Bitmap(_gpuPixelBitmapData);
            addChild(_gpuPixelBitmap);

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
            _noteBox = new NoteBox(_song, _settings);
            _noteBox.position();
            addChild(_noteBox);

            if (!_isEditor && MultiplayerState.instance.connection.connected && !MultiplayerState.instance.isInRoom())
            {
                var isInSoloMode:Boolean = true;
                MultiplayerState.instance.connection.disconnect(isInSoloMode);
            }

            /*
               if (false && !_gvars.tempFlags["key_hints"] && !options.multiplayer && !options._isEditor && !options.replay && !mpSpectate) {
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
            addChild(_gameplayUI);

            if (!_settings.displayGameTopBar)
                _gameplayUI.top_bar.visible = false;

            if (!_settings.displayGameBottomBar)
                _gameplayUI.bottom_bar.visible = false;

            if (!_settings.displayGameTopBar && !_settings.displayGameBottomBar)
                _gameplayUI.visible = false;

            if (_settings.displayPACount)
            {
                _player1PAWindow = new PAWindow(_settings.displayAmazing, _settings.judgeColors);
                if (_sideScroll)
                    _player1PAWindow.alternateLayout();
                addChild(_player1PAWindow);
            }

            if (_settings.displayScore)
            {
                _score = new Score();
                addChild(_score);
            }

            if (_settings.displayCombo)
            {
                _player1Combo = new Combo(_settings.comboColors, VectorUtil.toArray(_settings.enableComboColors), _isAutoplay, _settings.rawGoodTracker);
                if (!_sideScroll)
                    _player1Combo.alignment = TextFieldAutoSize.RIGHT;
                addChild(_player1Combo);

                _comboStatic = new TextStatic(_lang.string("game_combo"));
                addChild(_comboStatic);
            }

            if (_settings.displayTotal)
            {
                _comboTotal = new Combo(_settings.comboColors, VectorUtil.toArray(_settings.enableComboColors), _isAutoplay, _settings.rawGoodTracker);
                if (_sideScroll)
                    _comboTotal.alignment = TextFieldAutoSize.RIGHT;
                addChild(_comboTotal);

                _comboTotalStatic = new TextStatic(_lang.string("game_combo_total"));
                addChild(_comboTotalStatic);
            }

            if (_settings.displayAccuracyBar)
            {
                _accBar = new AccuracyBar(_settings.judgeColors, _settings.judgeWindow);
                addChild(_accBar);
            }

            if (_settings.displaySongProgress || _replay)
            {
                _progressDisplay = new ProgressBar(161, 9, 458, 20, 4, 0x545454, 0.1);
                addChild(_progressDisplay);

                if (_replay)
                    _progressDisplay.addEventListener(MouseEvent.CLICK, progressMouseClick);
            }

            if (_settings.displaySongProgressText)
            {
                _progressDisplayText = new TextStatic("0:00");
                addChild(_progressDisplayText);
            }

            if (!_mpSpectate || _mode == SOLO || _mode == MP)
            {
                buildJudge();
                buildHealth();
            }

            if (_mpRoom || _mode == MP || _mode == SPECTATOR)
                buildMultiplayer();

            if (_isEditor)
            {
                _gameplayUI.mouseChildren = false;
                _gameplayUI.mouseEnabled = false;

                _exitEditor = new BoxButton(this, (Main.GAME_WIDTH - 75) / 2, (Main.GAME_HEIGHT - 30) / 2, 75, 30, _lang.string("menu_close"), 12, onCloseEditorClicked);
                _resetEditor = new BoxButton(this, _exitEditor.x, _exitEditor.y + 35, 75, 30, _lang.string("menu_reset"), 12, onResetLayoutClicked);
            }
        }

        private function onCloseEditorClicked(e:MouseEvent):void
        {
            _gameState = GAME_END;
            if (!_replay)
            {
                _user.saveSettingsLocally();
                _user.saveSettingsOnline(_gvars.userSession);
            }
        }

        private function onResetLayoutClicked(e:MouseEvent):void
        {
            for (var key:String in _settings.layout[layoutKey])
                delete _settings.layout[layoutKey][key];

            interfaceSetup();
        }

        private function initPlayerVars():void
        {
            // Force no Judge on SongPreviews
            if (_replay && _replay.isPreview)
            {
                _settings.judgeOffset = 0;
                _settings.globalOffset = 0;
                _isAutoplay = true;
            }

            _reverseMod = _settings.mods.reverse;
            _sideScroll = (_settings.scrollDirection == "left" || _settings.scrollDirection == "right");
            _player1JudgeOffset = Math.round(_settings.judgeOffset);
            _globalOffsetRounded = Math.round(_settings.globalOffset);
            _globalOffset = (_settings.globalOffset - _globalOffsetRounded) * 1000 / 30;

            if (_settings.judgeWindow)
                _judgeSettings = buildJudgeNodes(_settings.judgeWindow);

            _judgeOffset = _settings.judgeOffset * 1000 / 30;
            _autoJudgeOffset = _settings.autoJudgeOffset;

            _mpSpectate = (_mpRoom && !_mpRoom.connection.currentUser.isPlayer);
            if (_mpSpectate)
            {
                _settings.displayCombo = false;
                _settings.displayTotal = false;
                _settings.displayPACount = false;
            }
            else if (_mpRoom)
                _settings.displayTotal = false;
        }

        private function initVars(postStart:Boolean = true):void
        {
            // Post Start Time
            if (postStart && !_user.isGuest && !_replay && !_isEditor && _song.songInfo.engine == null && !_mpSpectate)
            {
                Logger.debug(this, "Posting Start of level " + _song.songInfo.level);
                _loader = new URLLoader();
                addLoaderListeners();

                var req:URLRequest = new URLRequest(Constant.SONG_START_URL);
                var requestVars:URLVariables = new URLVariables();
                Constant.addDefaultRequestVariables(requestVars);
                requestVars.session = AppState.instance.auth.userSession;
                requestVars.id = _song.songInfo.level;
                requestVars.restarts = AppState.instance.gameplay.songRestarts;
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
                if (AppState.instance.air.useWebsockets)
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

                    dispatchEvent(new SendWebsocketMessageEvent("NOTE_JUDGE", _socketScoreMessage));
                    dispatchEvent(new SendWebsocketMessageEvent("SONG_START", _socketSongMessage));
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

            if (_quitDoubleTap > 0)
            {
                _quitDoubleTap--;
            }

            if (_gameProgress >= _gameLastNoteFrame + 20 || _quitDoubleTap == 0)
            {
                _gameState = GAME_END;
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
                if (_isAutoplay && (_gameProgress - curNote.PROGRESS + _player1JudgeOffset) == 0)
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
            if (_replay && !_replay.isPreview)
            {
                var newPress:ReplayNote = _replay.getPress(_replayPressCount);
                if (_replay.needsBeatboxGeneration)
                {
                    var oldPosition:int = _gamePosition;
                    _gamePosition = (_gameProgress + 0.5) * 1000 / 30;
                    var cutOffReplayNote:uint = _replay.generationReplayNotes.length;
                    var readAheadTime:Number = (1 / _frameRate.value) * 1000;
                    // Note Hits
                    for (var rn:int = 0; rn < notes.length; rn++)
                    {
                        var repCurNote:GameNote = notes[rn];

                        // Missed Note
                        if (repCurNote.ID >= cutOffReplayNote || (_replay.generationReplayNotes[repCurNote.ID] == null || isNaN(_replay.generationReplayNotes[repCurNote.ID].time)))
                        {
                            continue;
                        }

                        var diffValue:int = _replay.generationReplayNotes[repCurNote.ID].time + repCurNote.POSITION;
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
                        newPress = _replay.getPress(_replayPressCount);
                    }
                    _gamePosition = oldPosition;
                }
                else
                {
                    while (newPress != null && newPress.frame == _gameProgress)
                    {
                        judgeScore(newPress.direction, newPress.frame);

                        _replayPressCount++;
                        newPress = _replay.getPress(_replayPressCount);
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
            for each (var user:User in _mpRoom.players)
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
            if (_settings.displayMPJudge && _mpRoom)
            {
                for each (var mpJudgeComponent:Judge in _mpJudge)
                {
                    mpJudgeComponent.updateJudge(e);
                }
            }
            else if (_settings.displayJudge && _player1Judge != null)
            {
                _player1Judge.updateJudge(e);
            }


            // Gameplay Logic
            switch (_gameState)
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
                        if (_replay)
                            threshold = 0x7fffffff;

                        //Logger.debug("GP", "lAP: " + lastAbsolutePosition + " | aP: " + absolutePosition + " | sDS: " + songDelayStarted + " | sD: " + songDelay + " | sOv: " + songOffset.value + " | sGP: " + song.getPosition() + " | sP: " + songPosition + " | gP: " + gamePosition + " | tP: " + targetProgress + " | t: " + threshold);

                        while (_gameProgress < targetProgress && threshold-- > 0)
                            logicTick();

                        if (_mpSpectate)
                            spectateSync();

                        if (_reverseMod)
                            stopClips(_songBackground, 2 + _song.musicDelay - _globalOffsetRounded + _gameProgress * _settings.songRate);
                        else
                            stopClips(_songBackground, 2 + _song.musicDelay - _globalOffsetRounded + _gameProgress * _settings.songRate);
                    }

                    if (_settings.mods.tapPulse)
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
                if (!_replay)
                {
                    var dir:String = null;
                    switch (keyCode)
                    {
                        case _settings.keyLeft:
                            //case Keyboard.NUMPAD_4:
                            dir = "L";
                            break;

                        case _settings.keyRight:
                            //case Keyboard.NUMPAD_6:
                            dir = "R";
                            break;

                        case _settings.keyUp:
                            //case Keyboard.NUMPAD_8:
                            dir = "U";
                            break;

                        case _settings.keyDown:
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

            var user:User = AppState.instance.auth.user;

            // Game Restart
            if (keyCode == user.settings.keyRestart && !_mpRoom)
            {
                _gameState = GAME_RESTART;
            }

            // Quit
            else if (keyCode == user.settings.keyQuit)
            {
                if (_gvars.songQueue.length > 0)
                {
                    if (_quitDoubleTap > 0)
                    {
                        _gvars.songQueue = [];
                        _gameState = GAME_END;
                    }
                    else
                        _quitDoubleTap = _settings.frameRate / 4;
                }
                else
                    _gameState = GAME_END;
            }

            // Pause
            else if (keyCode == 19 && (CONFIG::debug || user.isAdmin || user.isDeveloper || _replay))
            {
                togglePause();
            }

            // Auto-Play
            else if (keyCode == Keyboard.F8 && (CONFIG::debug || user.isDeveloper || user.isAdmin))
            {
                _isAutoplay = !_isAutoplay;
                Alert.add("Bot Play: " + _isAutoplay, 60);
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
            if (_gameState == GAME_PLAY)
            {
                _gamePosition = getTimer() - _absoluteStart;
                var targetProgress:int = Math.round(_gamePosition * 30 / 1000);

                // Update Notes
                while (_gameProgress < targetProgress)
                    logicTick();

                _noteBox.update(_gamePosition);
            }
            // State 1 = End Game
            else if (_gameState == GAME_END)
                endGame();
        }

        private function editorKeyboardKeyDown(e:KeyboardEvent):void
        {
            if (_noteBox == null)
                return;

            var keyCode:int = e.keyCode;
            var dir:String = "";

            if (keyCode == _settings.keyQuit)
                _gameState = GAME_END;

            switch (keyCode)
            {
                case _settings.keyLeft:
                    dir = "L";
                    break;

                case _settings.keyRight:
                    dir = "R";
                    break;

                case _settings.keyUp:
                    dir = "U";
                    break;

                case _settings.keyDown:
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
            if (_gameState == GAME_PLAY)
            {
                _gameState = GAME_PAUSE;
                _songPausePosition = getTimer();
                _song.pause();

                if (AppState.instance.air.useWebsockets)
                    dispatchEvent(new SendWebsocketMessageEvent("SONG_PAUSE", _socketSongMessage));
            }
            else if (_gameState == GAME_PAUSE)
            {
                _gameState = GAME_PLAY;
                _absoluteStart += (getTimer() - _songPausePosition);
                _song.resume();

                if (AppState.instance.air.useWebsockets)
                    dispatchEvent(new SendWebsocketMessageEvent("SONG_RESUME", _socketSongMessage));
            }
        }

        private function endGame():void
        {
            // Stop Music Play
            if (_song)
                _song.stop();

            // Play through to the end of a replay
            if (_replay)
            {
                _gameState = GAME_PLAY;
                while (_gameLife > 0 && _gameState == GAME_PLAY)
                    logicTick();
                _gameState = GAME_END;
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
            if (!_mpSpectate && !_isEditor)
            {
                var newGameResults:GameScoreResult = new GameScoreResult();
                newGameResults.gameIndex = _gvars.gameIndex++;
                newGameResults.song = _song;
                newGameResults.noteCount = _song.totalNotes;
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
                newGameResults.restart_stats = _gvars.songStats.data;
                newGameResults.replayData = _gameReplay.concat();
                newGameResults.replay_hit = _gameReplayHit.concat();
                newGameResults.replay_bin_notes = _binReplayNotes;
                newGameResults.replay_bin_boos = _binReplayBoos;
                newGameResults.user = _replay ? _replay.user : _user;
                newGameResults.restarts = _replay ? 0 : _gvars.songRestarts;
                newGameResults.start_time = AppState.instance.gameplay.songStartTime;
                newGameResults.start_hash = AppState.instance.gameplay.songStartHash;
                newGameResults.end_time = _replay ? TimeUtil.getFormattedDate(new Date(_replay.timestamp * 1000)) : TimeUtil.getCurrentDate();
                newGameResults.song_progress = (_gameProgress / _gameLastNoteFrame);
                newGameResults.playtime_secs = ((getTimer() - _msStartTime) / 1000);

                // Set Note Counts for Preview Songs
                if (_replay)
                {
                    _gvars.songResults = new Vector.<GameScoreResult>();

                    if (_replay.isPreview)
                    {
                        newGameResults.isPreview = true;
                        newGameResults.score = _song.totalNotes * 50;
                        newGameResults.amazing = _song.totalNotes;
                        newGameResults.max_combo = _song.totalNotes;
                    }
                }

                newGameResults.update(_gvars);
                _gvars.songResults.push(newGameResults);
            }

            _gvars.sessionStats.addFromStats(_gvars.songStats);
            _gvars.songStats.reset();

            if (!_legacyMode && !_replay && !_isEditor && !_mpSpectate)
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
            if (AppState.instance.air.useWebsockets)
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

                dispatchEvent(new SendWebsocketMessageEvent("NOTE_JUDGE", _socketScoreMessage));
                dispatchEvent(new SendWebsocketMessageEvent("SONG_END", _socketSongMessage));
            }

            // Cleanup
            initVars(false);

            if (_song != null)
                _song.stop();

            if (_songBackground)
            {
                removeChild(_songBackground);
                _songBackground = null;
            }

            // Remove Notes
            if (_noteBox != null)
                _noteBox.reset();

            // Remove UI
            if (_gpuPixelBitmap)
            {
                removeChild(_gpuPixelBitmap);
                _gpuPixelBitmap = null;
                _gpuPixelBitmapData = null;
            }

            if (_displayBlackBG)
            {
                removeChild(_displayBlackBG);
                _displayBlackBG = null;
            }

            if (_progressDisplay)
            {
                removeChild(_progressDisplay);
                _progressDisplay = null;
            }

            if (_player1Life)
            {
                removeChild(_player1Life);
                _player1Life = null;
            }

            if (_player1Judge)
            {
                removeChild(_player1Judge);
                _player1Judge = null;
            }

            if (_gameplayUI)
            {
                removeChild(_gameplayUI);
                _gameplayUI = null;
            }

            if (_noteBox)
            {
                removeChild(_noteBox);
                _noteBox = null;
            }

            if (_displayBlackBG)
            {
                removeChild(_displayBlackBG);
                _displayBlackBG = null;
            }

            if (_flashLight)
            {
                removeChild(_flashLight);
                _flashLight = null;
            }

            if (_screenCut)
            {
                removeChild(_screenCut);
                _screenCut = null;
            }

            if (_exitEditor)
            {
                _exitEditor.dispose();
                removeChild(_exitEditor);
                _exitEditor = null;
            }

            _gameState = GAME_DISPOSE;

            var screen:int = _settings.startUpScreen;
            if (!_user.isGuest && (screen == 0 || screen == 1) && !MultiplayerState.instance.connection.connected)
            {
                MultiplayerState.instance.connection.connect();
            }

            // Go to results
            if (_isEditor || _mpSpectate)
                dispatchEvent(new ChangePanelEvent(Routes.PANEL_MAIN_MENU));
            else
            {
                _gvars.songQueueIndex++;
                // More songs to play, jump to gameplay or loading.
                if (_gvars.songQueueIndex < _gvars.songQueue.length)
                {
                    var nextSong:Song = _gvars.getSongFile(_gvars.songQueue[_gvars.songQueueIndex]);
                    dispatchEvent(new StartGameplayEvent(nextSong, _isAutoplay, GameplayDisplay.SOLO, _mpRoom));
                }
                else
                {
                    dispatchEvent(new ShowGameResultsEvent(_song, _isAutoplay, _replay, _mpRoom));
                    _gvars.songResults.length = 0;
                }
            }

            _song = null;
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
            _gvars.songStats.credits += Math.round(tempGT / AppState.instance.content.scorePerCredit);
            _gvars.songStats.restarts++;

            // Restart
            _song.reset();
            _gameState = GAME_PLAY;
            initPlayerVars();
            initVars();
            if (_player1Judge)
                _player1Judge.hideJudge();
            _gvars.songRestarts++;

            // Websocket
            if (AppState.instance.air.useWebsockets)
            {
                _socketScoreMessage["restarts"] = _gvars.songRestarts;

                dispatchEvent(new SendWebsocketMessageEvent("NOTE_JUDGE", _socketScoreMessage));
                dispatchEvent(new SendWebsocketMessageEvent("SONG_RESTART", _socketSongMessage));
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
            if (_settings.mods.flashlight)
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
            if (!_settings.displayScreencut)
                return;

            if (_screenCut)
            {
                if (contains(_screenCut))
                    removeChild(_screenCut);
                _screenCut = null;
            }

            _screenCut = new ScreenCut(_isEditor, _settings.scrollDirection, _settings.screencutPosition);
            addChild(_screenCut);
        }

        private function buildJudge():void
        {
            if (!_settings.displayJudge)
                return;

            _player1Judge = new Judge(_settings.displayPerfect, _settings.displayJudgeAnimations, _settings.judgeSpeed, _settings.judgeColors, _isEditor);
            addChild(_player1Judge);

            if (_isEditor)
                _player1Judge.showJudge(100, true);
        }

        private function buildHealth():void
        {
            if (!_settings.displayHealth)
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

            if (!_settings.displayMPUI && !_mpSpectate)
                return;

            var players:Vector.<User>;
            if (_mpRoom)
                players = _mpRoom.players;
            else if (_mode == MP || _mode == SPECTATOR)
            {
                players = new Vector.<User>();
                players.push(_user, _user);
            }

            function setStuff(user:User, playerIdx:int):void
            {
                if (!_mpRoom && playerIdx == 1 || _mpRoom && user.id == _mpRoom.connection.currentUser.id)
                {
                    if (_player1PAWindow)
                        _mpPA[playerIdx] = _player1PAWindow;
                    if (_player1Combo)
                        _mpCombo[playerIdx] = _player1Combo;
                    if (_player1Judge)
                        _mpJudge[playerIdx] = _player1Judge;
                    return;
                }

                if (_settings.displayMPPA)
                {
                    var pa:PAWindow = new PAWindow(_settings.displayAmazing, _settings.judgeColors);
                    addChild(pa);
                    _mpPA[playerIdx] = pa;
                }

                if (_mpSpectate || _mode == SPECTATOR)
                {
                    var header:MPHeader = new MPHeader(user);
                    if (_settings.displayMPPA)
                        _mpPA[playerIdx].addChild(header);
                    else
                        addChild(header);
                    _mpHeader[playerIdx] = header;
                }

                if (_settings.displayMPCombo)
                {
                    var combo:Combo = new Combo(_settings.comboColors, VectorUtil.toArray(_settings.enableComboColors), _isAutoplay, _settings.rawGoodTracker);
                    addChild(combo);
                    _mpCombo[playerIdx] = combo;
                }

                if (_settings.displayMPJudge)
                {
                    var judge:Judge = new Judge(_settings.displayPerfect, _settings.displayJudgeAnimations, _settings.judgeSpeed, _settings.judgeColors, _isEditor);
                    addChild(judge);
                    _mpJudge[playerIdx] = judge;
                    if (_isEditor)
                        judge.showJudge(100, true);
                }
            }

            if (_mpRoom)
            {
                for each (var user:User in players)
                    setStuff(user, user.playerIdx);
            }
            else
            {
                for (var i:int = 1; i <= 2; i++)
                    setStuff(_user, i);
            }
        }

        private function interfaceLayout(key:String, defaults:Boolean = true):Object
        {
            var i:String;

            if (!_settings.layout[layoutKey])
                _settings.layout[layoutKey] = {};

            if (!_settings.layout[layoutKey][_settings.scrollDirection])
                _settings.layout[layoutKey][_settings.scrollDirection] = {};

            if (!_settings.layout[layoutKey][_settings.scrollDirection][key] || _settings.layout[layoutKey][_settings.scrollDirection][key] is Array)
            {
                var settingsLayout:Object = _settings.layout[layoutKey][_settings.scrollDirection][key] = {};

                if (defaults)
                {
                    for (i in _defaultLayout[key])
                        settingsLayout[i] = _defaultLayout[key][i];
                }
            }

            return _settings.layout[layoutKey][_settings.scrollDirection][key];
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
            if (_settings.displayMPPA)
                _defaultLayout[LAYOUT_MP_HEADER + "1"] = {x: 0, y: -35};
            else
                _defaultLayout[LAYOUT_MP_HEADER + "1"] = {x: 6, y: 190};

            _defaultLayout[LAYOUT_MP_COMBO + "2"] = _defaultLayout[LAYOUT_COMBO_TOTAL];
            _defaultLayout[LAYOUT_MP_JUDGE + "2"] = {x: 568, y: 102};
            _defaultLayout[LAYOUT_MP_PA + "2"] = {x: 645, y: 96, properties: {alignment: "right"}};
            if (_settings.displayMPPA)
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

            if (_mode == SOLO)
            {
                interfacePosition(_player1PAWindow, interfaceLayout(LAYOUT_PA));
                interfacePosition(_player1Combo, interfaceLayout(LAYOUT_COMBO));
                interfacePosition(_player1Judge, interfaceLayout(LAYOUT_JUDGE));
            }
            else
            {
                // Multiplayer
                if (!_mpRoom)
                {
                    for (var i:int = 1; i <= 2; i++)
                    {
                        interfacePosition(_mpJudge[i], interfaceLayout(LAYOUT_MP_JUDGE + i));
                        interfacePosition(_mpCombo[i], interfaceLayout(LAYOUT_MP_COMBO + i));
                        interfacePosition(_mpPA[i], interfaceLayout(LAYOUT_MP_PA + i));
                        interfacePosition(_mpHeader[i], interfaceLayout(LAYOUT_MP_HEADER + i));
                    }
                }
                else
                {
                    for each (var user:User in _mpRoom.players)
                    {
                        i = user.playerIdx;
                        interfacePosition(_mpJudge[i], interfaceLayout(LAYOUT_MP_JUDGE + i));
                        interfacePosition(_mpCombo[i], interfaceLayout(LAYOUT_MP_COMBO + i));
                        interfacePosition(_mpPA[i], interfaceLayout(LAYOUT_MP_PA + i));
                        interfacePosition(_mpHeader[i], interfaceLayout(LAYOUT_MP_HEADER + i));
                    }
                }
            }

            // Editor Mode
            if (_isEditor)
            {
                interfaceEditor(LAYOUT_PROGRESS_BAR, _progressDisplay, interfaceLayout(LAYOUT_PROGRESS_BAR, false));
                interfaceEditor(LAYOUT_PROGRESS_TEXT, _progressDisplayText, interfaceLayout(LAYOUT_PROGRESS_TEXT, false));
                interfaceEditor(LAYOUT_RECEPTORS, _noteBox, interfaceLayout(LAYOUT_RECEPTORS, false));
                interfaceEditor(LAYOUT_ACCURACY_BAR, _accBar, interfaceLayout(LAYOUT_ACCURACY_BAR, false));
                interfaceEditor(LAYOUT_HEALTH, _player1Life, interfaceLayout(LAYOUT_HEALTH, false));
                interfaceEditor(LAYOUT_SCORE, _score, interfaceLayout(LAYOUT_SCORE, false));
                interfaceEditor(LAYOUT_COMBO_TOTAL, _comboTotal, interfaceLayout(LAYOUT_COMBO_TOTAL, false));
                interfaceEditor(LAYOUT_COMBO_STATIC, _comboStatic, interfaceLayout(LAYOUT_COMBO_STATIC, false));
                interfaceEditor(LAYOUT_COMBO_TOTAL_STATIC, _comboTotalStatic, interfaceLayout(LAYOUT_COMBO_TOTAL_STATIC, false));

                if (_mode == SOLO)
                {
                    interfaceEditor(LAYOUT_PA, _player1PAWindow, interfaceLayout(LAYOUT_PA, false));
                    interfaceEditor(LAYOUT_COMBO, _player1Combo, interfaceLayout(LAYOUT_COMBO, false));
                    interfaceEditor(LAYOUT_JUDGE, _player1Judge, interfaceLayout(LAYOUT_JUDGE, false));
                }
                else if (_mode == MP || _mode == SPECTATOR)
                {
                    for (i = 1; i <= 2; i++)
                    {
                        interfaceEditor(LAYOUT_MP_JUDGE + i, _mpJudge[i], interfaceLayout(LAYOUT_MP_JUDGE + i, false));
                        interfaceEditor(LAYOUT_MP_COMBO + i, _mpCombo[i], interfaceLayout(LAYOUT_MP_COMBO + i, false));
                        interfaceEditor(LAYOUT_MP_PA + i, _mpPA[i], interfaceLayout(LAYOUT_MP_PA + i, false));
                        interfaceEditor(LAYOUT_MP_HEADER + i, _mpHeader[i], interfaceLayout(LAYOUT_MP_HEADER + i, false));
                    }
                }
            }
        }

        private function interfacePosition(sprite:Sprite, layoutElement:Object):void
        {
            if (!sprite)
                return;

            if ("x" in layoutElement)
                sprite.x = layoutElement["x"];
            if ("y" in layoutElement)
                sprite.y = layoutElement["y"];
            if ("rotation" in layoutElement)
                sprite.rotation = layoutElement["rotation"];
            if ("visible" in layoutElement)
                sprite.visible = layoutElement["visible"];
            if ("properties" in layoutElement)
            {
                if ("alignment" in layoutElement.properties)
                    sprite["alignment"] = layoutElement.properties.alignment;
            }
        }

        private function interfaceEditor(key:String, sprite:Sprite, layout:Object):void
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
                onSpriteMouseUp(key, sprite, layout);
            });
        }

        private function get layoutKey():String
        {
            if (_mode == SOLO)
                return "sp";
            else if (_mode == MP)
                return "mp";
            else if (_mode == SPECTATOR)
                return "mpspec";

            return "";
        }

        private function onSpriteMouseUp(key:String, sprite:Sprite, layout:Object):void
        {
            sprite.stopDrag();

            if (!_settings.layout[layoutKey])
                _settings.layout[layoutKey] = {};
            var layoutElement:Object = _settings.layout[layoutKey];

            var layoutKeyDir:String = _settings.scrollDirection;
            if (!layoutElement[layoutKeyDir])
                layoutElement[layoutKeyDir] = {};

            var layoutSetting:Object = _settings.layout[layoutKey][layoutKeyDir][key] = {};
            layoutSetting["x"] = sprite.x;
            layoutSetting["y"] = sprite.y;
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
            if (!_noteBox)
                return false;


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

            if (_settings.mods.tapPulse)
            {
                if (dir == "L")
                    _noteBoxOffset.x -= Math.abs(_settings.receptorGap * 0.20);
                if (dir == "R")
                    _noteBoxOffset.x += Math.abs(_settings.receptorGap * 0.20);
                if (dir == "U")
                    _noteBoxOffset.y -= Math.abs(_settings.receptorGap * 0.15);
                if (dir == "D")
                    _noteBoxOffset.y += Math.abs(_settings.receptorGap * 0.15);
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

            if (_settings.mods.tapPulse)
            {
                if (dir == "L")
                    _noteBoxOffset.x -= Math.abs(_settings.receptorGap * 0.20);
                if (dir == "R")
                    _noteBoxOffset.x += Math.abs(_settings.receptorGap * 0.20);
                if (dir == "U")
                    _noteBoxOffset.y -= Math.abs(_settings.receptorGap * 0.15);
                if (dir == "D")
                    _noteBoxOffset.y += Math.abs(_settings.receptorGap * 0.15);
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
                    if (_settings.displayAmazing)
                    {
                        checkAutofail(_settings.autofail[0], _hitAmazing);
                    }
                    else
                    {
                        jscore = 50;
                        checkAutofail(_settings.autofail[0] + _settings.autofail[1], _hitAmazing + _hitPerfect);
                    }
                    checkAutofail(_settings.autofail[6], _gameRawGoods);
                    break;
                case 50:
                    _hitPerfect++;
                    _hitCombo++;
                    _gameScore += 50;
                    health = 1;
                    checkAutofail(_settings.autofail[1], _hitPerfect);
                    checkAutofail(_settings.autofail[6], _gameRawGoods);
                    break;
                case 25:
                    _hitGood++;
                    _hitCombo++;
                    _gameScore += 25;
                    _gameRawGoods += 1;
                    health = 1;
                    checkAutofail(_settings.autofail[2], _hitGood);
                    checkAutofail(_settings.autofail[6], _gameRawGoods);
                    break;
                case 5:
                    _hitAverage++;
                    _hitCombo++;
                    _gameScore += 5;
                    _gameRawGoods += 1.8;
                    health = 1;
                    checkAutofail(_settings.autofail[3], _hitAverage);
                    checkAutofail(_settings.autofail[6], _gameRawGoods);
                    break;
                case -5:
                    if (frame < _gameFirstNoteFrame)
                        return;
                    _hitBoo++;
                    _gameScore -= 5;
                    _gameRawGoods += 0.2;
                    health = -1;
                    checkAutofail(_settings.autofail[5], _hitBoo);
                    checkAutofail(_settings.autofail[6], _gameRawGoods);
                    break;
                case -10:
                    _hitMiss++;
                    _hitCombo = 0;
                    _gameScore -= 10;
                    _gameRawGoods += 2.4;
                    health = -1;
                    checkAutofail(_settings.autofail[4], _hitMiss);
                    checkAutofail(_settings.autofail[6], _gameRawGoods);
                    break;
            }

            if (_isAutoplay)
            {
                _gameScore = 0;
                _hitAmazing = 0;
                _hitPerfect = 0;
                _hitGood = 0;
                _hitAverage = 0;
            }

            if (_player1Judge && !_isEditor)
                _player1Judge.showJudge(jscore);

            var contentState:ContentState = AppState.instance.content;
            updateHealth(health > 0 ? contentState.healthJudgeAdd : contentState.healthJudgeRemove);

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

            if (_mpRoom)
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
            if (AppState.instance.air.useWebsockets)
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

                dispatchEvent(new SendWebsocketMessageEvent("NOTE_JUDGE", _socketScoreMessage));
            }
        }

        private function checkAutofail(autofail:Number, hit:Number):void
        {
            if (autofail > 0 && hit >= autofail)
                _gameState = GAME_END;
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
                _gameState = GAME_END;
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

        private var previousDiffs:Array = [];

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

            if (!gameplay || !_mpRoom.isPlayer(user) || user.id == _mpRoom.connection.currentUser.id)
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
            if (event.room == _mpRoom)
                _gameState = GAME_END;
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
