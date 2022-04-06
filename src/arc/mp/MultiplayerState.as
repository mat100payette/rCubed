package arc.mp
{
    import arc.mp.MenuMultiplayer;

    import classes.Alert;
    import classes.Gameplay;
    import classes.Language;
    import classes.Playlist;
    import classes.Room;
    import classes.SongInfo;
    import classes.User;
    import classes.chart.Song;
    import classes.replay.Replay;
    import com.flashfla.net.Multiplayer;
    import com.flashfla.net.events.ConnectionEvent;
    import com.flashfla.net.events.ErrorEvent;
    import com.flashfla.net.events.GameResultsEvent;
    import com.flashfla.net.events.GameStartEvent;
    import com.flashfla.net.events.GameUpdateEvent;
    import com.flashfla.net.events.LoginEvent;
    import com.flashfla.net.events.MessageEvent;
    import com.flashfla.net.events.RoomJoinedEvent;
    import com.flashfla.net.events.RoomLeftEvent;
    import com.flashfla.net.events.RoomListEvent;
    import com.flashfla.net.events.RoomUserEvent;
    import com.flashfla.net.events.RoomUserStatusEvent;
    import com.flashfla.utils.sprintf;
    import com.flashfla.utils.StringUtil;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.utils.Timer;
    import game.GameScoreResult;
    import flash.events.EventDispatcher;
    import events.navigation.ChangePanelEvent;
    import game.GameplayDisplay;
    import events.navigation.SpectateGameEvent;
    import events.navigation.StartGameplayEvent;
    import state.AppState;
    import state.ContentState;

    public class MultiplayerState extends EventDispatcher
    {
        private var _lang:Language = Language.instance;

        public var connection:Multiplayer;

        private var _username:String;
        private var _password:String;

        private var _autoJoin:Boolean;

        private var _currentRoom:Room = null;
        private var _currentSongInfo:SongInfo = null;
        private var _currentSongFile:Song = null;
        private var _currentStatus:int = 0;

        private var _panel:MenuMultiplayer = null;

        private static var _instance:MultiplayerState = null;

        public static function get instance():MultiplayerState
        {
            if (_instance == null)
                _instance = new MultiplayerState();
            return _instance;
        }

        public function setUserCredentials(username:String, password:String):void
        {
            _username = username;
            _password = password;
        }

        public static function destroyInstance():void
        {
            if (_instance && _instance.connection && _instance.connection.connected)
                _instance.connection.disconnect();
            _instance = null;
        }

        public function MultiplayerState()
        {
            connection = new Multiplayer();

            connection.addEventListener(Multiplayer.EVENT_ERROR, onError);
            connection.addEventListener(Multiplayer.EVENT_CONNECTION, onConnection);
            connection.addEventListener(Multiplayer.EVENT_LOGIN, onLogin);
            connection.addEventListener(Multiplayer.EVENT_ROOM_LIST, onRoomList);
            connection.addEventListener(Multiplayer.EVENT_ROOM_JOINED, onRoomJoined);
            connection.addEventListener(Multiplayer.EVENT_ROOM_LEFT, onRoomLeft);
            connection.addEventListener(Multiplayer.EVENT_ROOM_USER, onRoomUser);
            connection.addEventListener(Multiplayer.EVENT_ROOM_USER_STATUS, onRoomUserStatus);
            connection.addEventListener(Multiplayer.EVENT_MESSAGE, onMessage);
            connection.addEventListener(Multiplayer.EVENT_GAME_RESULTS, onGameResults);
            connection.addEventListener(Multiplayer.EVENT_GAME_START, onGameStart);
        }

        public function get currentUser():User
        {
            return connection.currentUser;
        }

        private function onError(event:ErrorEvent):void
        {
            Alert.add(_lang.string("mp_error") + event.message);
        }

        private function onConnection(event:ConnectionEvent):void
        {
            if (connection.connected)
            {
                _autoJoin = false;
                connection.login(_username, _password);
            }
        }

        private function onLogin(event:LoginEvent):void
        {
            if (!connection.currentUser.loggedIn)
                connection.disconnect();
        }

        private function onRoomList(event:RoomListEvent):void
        {
            if (!_autoJoin)
                connection.joinLobby();
        }

        private function onRoomJoined(event:RoomJoinedEvent):void
        {
            if (event.room == connection.lobby)
            {
                if (_autoJoin)
                    connection.refreshRooms();

                _autoJoin = true;
            }
            else
                _currentRoom = event.room;
        }

        private function onRoomLeft(event:RoomLeftEvent):void
        {
            _currentRoom = null;
        }

        private function onRoomUser(event:RoomUserEvent):void
        {
            updateRoomUser(event.room, event.user);
        }

        private function onRoomUserStatus(event:RoomUserStatusEvent):void
        {
            updateRoomUser(event.room, event.user);
        }

        private function updateRoomUser(room:Room, user:User):void
        {
            if (user != null && room.isGameRoom && user.id != currentUser.id && room.isPlayer(currentUser) && room.isPlayer(user))
                Alert.add(sprintf(_lang.string("mp_user_joins_room_alert"), {"username": user.name}));
        }

        private function onMessage(event:MessageEvent):void
        {
            if (event.msgType == Multiplayer.MESSAGE_PRIVATE)
                Alert.add("*** " + event.user.name + ": " + event.message);
        }

        private function forEachRoom(func:Function):void
        {
            if (!connection.connected)
                return;

            for each (var room:Room in connection.rooms)
            {
                if (room.isGameRoom)
                    func(room);
            }
        }

        /**
         * Syncs the user's gameplay status with this singleton's state.
         */
        private function updateCurrentUserStatus():void
        {
            var gameplay:Gameplay = currentUser.gameplay;

            if (gameplay == null || _currentStatus == Multiplayer.STATUS_NONE)
            {
                gameplay = new Gameplay();
                currentUser.gameplay = gameplay;
            }

            gameplay.songInfo = _currentSongInfo;

            if (_currentSongFile != null && !_currentSongFile.isLoaded)
                gameplay.statusLoading = _currentSongFile.progress;

            var isNewStatus:Boolean = gameplay.status == _currentStatus;
            gameplay.status = _currentStatus;
            if (_currentStatus == Multiplayer.STATUS_CLEANUP)
            {
                _currentStatus = Multiplayer.STATUS_NONE;
                gameplay.reset();
            }

            propagateCurrentUserStatus();
        }

        /**
         * Propagates the current user's status to other rooms
         */
        private function propagateCurrentUserStatus():void
        {
            for each (var room:Room in connection.rooms)
            {
                if (room.isPlayer(currentUser))
                    connection.sendCurrentUserStatus(room);
            }
        }

        /**
         * Propagates the current user's score to other rooms
         */
        private function propagateCurrentUserScore():void
        {
            for each (var room:Room in connection.rooms)
            {
                if (room.isPlayer(currentUser))
                    connection.sendCurrentUserScore(room);
            }
        }

        public function clearStatus():void
        {
            _currentStatus = Multiplayer.STATUS_NONE;
            updateCurrentUserStatus();
        }

        // Should be called in MenuSongSelection whenever the selection changes.
        public function gameplayPicking(songInfo:SongInfo):void
        {
            _currentSongInfo = songInfo;
            _currentSongFile = null;

            _currentStatus = Multiplayer.STATUS_PICKING;
            updateCurrentUserStatus();
        }

        public function gameplayCanPick():Boolean
        {
            var isPlayer:Boolean = false;
            forEachRoom(function(room:Room):void
            {
                if (room.isPlayer(currentUser))
                    isPlayer = true;
            });
            return isPlayer;
        }

        // Called by MultiplayerPlayer when you click on the song label/name
        public function gameplayPick(songInfo:SongInfo):void
        {
            if (_currentStatus >= Multiplayer.STATUS_PLAYING || songInfo == null)
                return;

            var playlistsState:ContentState = AppState.instance.content;

            var playlistEngineId:Object = playlistsState.usingCanon ? null : playlistsState.altPlaylist.engineId;
            if (playlistEngineId == (songInfo.engine ? songInfo.engine.id : null))
            {
                dispatchEvent(new ChangePanelEvent(Routes.PANEL_SONGSELECTION));

                    // TODO: Redo this
                    //(mmenu._layerSongSelection as MenuSongSelection).multiplayerSelect(songInfo.name, songInfo);
            }
            else
            {
                if (SongInfo.compare(songInfo, _currentSongInfo))
                    gameplayLoading();
                else
                {
                    if (songInfo.engine)
                        gameplayPicking(songInfo);
                    else if (songInfo.checkSongAccess(AppState.instance.auth.user) == SongInfo.SONG_ACCESS_PLAYABLE)
                        gameplayPicking(songInfo);
                }
            }
        }

        // Starts loading the selected song.
        public function gameplayLoading():void
        {
            _currentSongFile = _gvars.getSongFile(_currentSongInfo);

            _currentStatus = Multiplayer.STATUS_LOADING;
            updateCurrentUserStatus();

            if (gameplayLoadingStatus())
            {
                gameplayLoaded();
            }
            else
            {
                var songFile:Song = _currentSongFile;
                songFile.addEventListener(Event.COMPLETE, function(event:Event):void
                {
                    songFile.removeEventListener(Event.COMPLETE, arguments.callee);
                    if (gameplayLoadingStatus() && _currentSongFile == songFile)
                    {
                        gameplayLoaded();
                    }
                });

                var timer:Timer = new Timer(400);
                timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
                {
                    if (_currentStatus != Multiplayer.STATUS_LOADING || gameplayLoadingStatus())
                        timer.stop();
                    else
                    {
                        if (_currentSongFile && _currentSongFile.loadFailed)
                        {
                            _gvars.removeSongFile(_currentSongFile);
                            Alert.add(_currentSongInfo.name + " failed to load");
                            _currentSongFile = null;
                            _currentStatus = Multiplayer.STATUS_PICKING;
                            timer.stop();
                        }
                        updateCurrentUserStatus();
                    }
                });
                timer.start();
            }
        }

        // Used to check if the song is done loading yet
        public function gameplayLoadingStatus():Boolean
        {
            return _currentSongFile != null && _currentSongFile.isLoaded;
        }

        public function gameplayPlayingStatus():Boolean
        {
            return _currentStatus == Multiplayer.STATUS_PLAYING;
        }

        public function gameplayPlayingStatusResults():Boolean
        {
            return _currentStatus == Multiplayer.STATUS_RESULTS;
        }

        public function gameplayHasOpponent():Boolean
        {
            var ret:Boolean = false;
            forEachRoom(function(room:Room):void
            {
                if (room.isPlayer(currentUser) && room.playerCount > 1)
                    ret = true;
            });
            return ret;
        }

        // Should be called once a song is finished loading
        public function gameplayLoaded():void
        {
            _currentStatus = Multiplayer.STATUS_LOADED;
            updateCurrentUserStatus();
        }

        public function isInRoom():Boolean
        {
            return _currentRoom != null;
        }

        private function onGameResults(event:GameResultsEvent):void
        {
            var room:Room = event.room;
            if (room.getPlayerIndex(currentUser) == 1 && room.variables["gameScoreRecorded"] != "y")
                gameplaySubmit(room);

            for each (var player:User in room.players)
            {
                if (player.id == connection.currentUser.id)
                    continue;

                var gameplay:Gameplay = player.gameplay;
                if (gameplay == null || !gameplay.encodedReplay)
                    continue;

                var replay:Replay = new Replay(new Date().getTime());

                replay.parseEncode(gameplay.encodedReplay);
                replay.loadSongInfo();

                if (!replay.isEdited && replay.isValid())
                    dispatchEvent(new PrependReplayEvent(replay));
            }
        }

        private function onGameStart(event:GameStartEvent):void
        {
            var room:Room = event.room;
            gameplayStart(room);
        }

        public function spectateGame(room:Room):void
        {
            _panel.dispatchEvent(new SpectateGameEvent(room));
        }

        public function gameplayStart(room:Room):void
        {
            _currentStatus = Multiplayer.STATUS_PLAYING;

            var mode:int = room.playerCount == 1 ? GameplayDisplay.SOLO : GameplayDisplay.MP;

            _panel.dispatchEvent(new StartGameplayEvent(_currentSongFile, false, mode, room));
        }

        public function gameplayPlaying(play:GameplayDisplay):Boolean
        {
            if (_currentStatus != Multiplayer.STATUS_PLAYING)
                return false;

            play.addEventListener(Multiplayer.EVENT_GAME_UPDATE, onGameUpdate);
            return true;
        }

        private function onGameUpdate(event:GameUpdateEvent):void
        {
            if (_currentStatus != Multiplayer.STATUS_PLAYING)
                return;

            var gameplay:Gameplay = currentUser.gameplay;
            gameplay.score = event.gameScore;
            gameplay.life = event.gameLife;
            gameplay.maxCombo = event.hitMaxCombo;
            gameplay.combo = event.hitCombo;
            gameplay.amazing = event.hitAmazing;
            gameplay.perfect = event.hitPerfect;
            gameplay.good = event.hitGood;
            gameplay.average = event.hitAverage;
            gameplay.miss = event.hitMiss;
            gameplay.boo = event.hitBoo;

            // Propagate the gameplay score only
            propagateCurrentUserScore();
        }

        public function gameplayResults(room:Room, songResults:Vector.<GameScoreResult>):void
        {
            if (!room || !room.isPlayer(currentUser) || _currentStatus != Multiplayer.STATUS_PLAYING)
                return;

            _currentStatus = Multiplayer.STATUS_RESULTS;

            // Update current user gameplay
            var replay:Replay = null;
            var results:GameScoreResult = null;
            for each (var result:GameScoreResult in songResults)
            {
                if (result.songInfo == _currentSongInfo)
                {
                    results = result;
                    break;
                }
            }

            if (results && results.song)
            {
                for each (var r:Replay in _gvars.replayHistory)
                {
                    if (r.level == results.song.songInfo.level && r.score == results.score)
                    {
                        replay = r;
                        break;
                    }
                }
            }

            var gameplay:Gameplay = currentUser.gameplay;
            if (results)
            {
                gameplay.score = results.score;
                gameplay.life = 24;
                gameplay.maxCombo = results.max_combo;
                gameplay.combo = results.combo;
                gameplay.amazing = results.amazing;
                gameplay.perfect = results.perfect;
                gameplay.good = results.good;
                gameplay.average = results.average;
                gameplay.miss = results.miss;
                gameplay.boo = results.boo;
            }

            if (replay)
                gameplay.encodedReplay = replay.getEncode();

            updateCurrentUserStatus();

            // Update rooms
            propagateCurrentUserStatus();

            // Submit score to FFR
            gameplaySubmit(room);
        }

        /**
         * Parses the resulting gameplay of the players in a room and sends it to FFR.
         */
        public function gameplaySubmit(room:Room):void
        {
            var matchSong:SongInfo = _currentSongInfo || room.songInfo;

            if (matchSong != null && matchSong.engine != null)
                return;

            var currentUserIdx:int = room.getPlayerIndex(currentUser);

            var player1:User = room.getPlayer(1);
            var player2:User = room.getPlayer(2);

            if (player1 == null || player2 == null)
                return;

            var resultsP1:Gameplay = player1.gameplay;
            var resultsP2:Gameplay = player2.gameplay;
            var currentOpponent:User = (currentUserIdx == 1 ? player2 : player1);
            var resultsOpponent:Gameplay = (currentUserIdx == 1 ? resultsP2 : resultsP1);

            if (!currentOpponent)
                return;

            var gamestats:Array = [];
            var results:Array = [resultsP1, resultsP2];
            for each (var result:Gameplay in results)
            {
                var hasRes:Boolean = result != null;
                var resultGamestats:Array = [matchSong.name,
                    hasRes ? result.score : 1,
                    hasRes ? result.life : 0,
                    hasRes ? result.maxCombo : 0,
                    hasRes ? result.combo : 0,
                    hasRes ? (result.amazing + result.perfect) : 0,
                    hasRes ? result.good : 0,
                    hasRes ? result.average : 0,
                    hasRes ? result.miss : 0,
                    hasRes ? result.boo : 0];

                gamestats.concat(resultGamestats);
            }

            var data:URLVariables = new URLVariables();
            data.gamestats = StringUtil.join(":", gamestats);

            if (resultsP1.score != resultsP2.score && resultsP1.score > 0 && resultsP2.score > 0)
            {
                data.winner = resultsP1.score > resultsP2.score ? 1 : 2;
                data.loser = resultsP1.score < resultsP2.score ? 1 : 2;
            }
            data["player" + currentUserIdx + "id"] = connection.currentUser.name;
            data["player" + room.getPlayerIndex(currentOpponent) + "id"] = currentOpponent.name;

            var loader:URLLoader = new URLLoader();
            var request:URLRequest = new URLRequest(Constant.MULTIPLAYER_SUBMIT_URL);
            request.method = URLRequestMethod.POST;
            request.data = data;
            loader.load(request);
        }

        // Call after results screen / on main menu
        public function gameplayCleanup():void
        {
            _currentSongInfo = null;
            _currentSongFile = null;
            _currentStatus = Multiplayer.STATUS_CLEANUP;

            updateCurrentUserStatus();
            propagateCurrentUserStatus();
        }
    }
}
