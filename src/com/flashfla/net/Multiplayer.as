package com.flashfla.net
{
    import flash.events.EventDispatcher;
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;
    import flash.xml.XMLNodeType;

    import arc.ArcGlobals;
    import classes.Playlist;
    import classes.Room
    import classes.User;

    import it.gotoandplay.smartfoxserver.SFSEvents.AdminMessageSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.ExtensionResponseSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.DebugMessageSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.CreateRoomErrorSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.LogoutSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.ModerationMessageSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.PlayerSwitchedSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.SpectatorSwitchedSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.PrivateMessageSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.PublicMessageSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.RoomListUpdateSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.RoomVariablesUpdateSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.RoomAddedSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.RoomDeletedSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.LeftRoomSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.JoinedRoomSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.JoinRoomErrorSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.UserCountChangeSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.UserEnterRoomSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.UserLeftRoomSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.UserVariablesUpdateSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.ConnectionSFSEvent;
    import it.gotoandplay.smartfoxserver.SFSEvents.ConnectionLostSFSEvent;
    import it.gotoandplay.smartfoxserver.SmartFoxClient;
    import it.gotoandplay.smartfoxserver.SFSEvent;
    import com.flashfla.net.events.ConnectionEvent;
    import com.flashfla.net.events.LoginEvent;
    import com.flashfla.net.events.ErrorEvent;
    import com.flashfla.net.events.ServerMessageEvent;
    import com.flashfla.net.events.MessageEvent;
    import com.flashfla.net.events.RoomUserEvent;
    import com.flashfla.net.events.RoomJoinedEvent;
    import com.flashfla.net.events.RoomLeftEvent;
    import com.flashfla.net.events.RoomUpdateEvent;
    import com.flashfla.net.events.RoomListEvent;
    import com.flashfla.net.events.UserUpdateEvent;
    import com.flashfla.net.events.GameStartEvent;
    import com.flashfla.net.events.GameUpdateEvent;
    import com.flashfla.net.events.GameResultsEvent;
    import com.flashfla.net.events.ExtensionResponseEvent;
    import com.flashfla.net.events.RoomUserStatusEvent;

    public class Multiplayer extends EventDispatcher
    {
        private static const serverAddress:String = "flashflashrevolution.com";
        private static const serverPort:int = 8082;

        public static const EVENT_ERROR:String = "ARC_EVENT_ERROR";
        public static const EVENT_CONNECTION:String = "ARC_EVENT_CONNECTION";
        public static const EVENT_LOGIN:String = "ARC_EVENT_LOGIN";
        public static const EVENT_XT_RESPONSE:String = "ARC_EVENT_XT_RESPONSE";
        public static const EVENT_SERVER_MESSAGE:String = "ARC_EVENT_SERVER_MESSAGE";
        public static const EVENT_MESSAGE:String = "ARC_EVENT_MESSAGE";
        public static const EVENT_ROOM_LIST:String = "ARC_EVENT_ROOM_LIST";
        public static const EVENT_ROOM_USER_STATUS:String = "ARC_EVENT_ROOM_USER_STATUS";
        public static const EVENT_ROOM_USER:String = "ARC_EVENT_ROOM_USER";
        public static const EVENT_ROOM_UPDATE:String = "ARC_EVENT_ROOM_UPDATE";
        public static const EVENT_ROOM_JOINED:String = "ARC_EVENT_ROOM_JOINED";
        public static const EVENT_ROOM_LEFT:String = "ARC_EVENT_ROOM_LEFT";
        public static const EVENT_USER_UPDATE:String = "ARC_EVENT_USER_UPDATE";
        public static const EVENT_GAME_START:String = "ARC_EVENT_GAME_START";
        public static const EVENT_GAME_UPDATE:String = "ARC_EVENT_GAME_UPDATE";
        public static const EVENT_GAME_RESULTS:String = "ARC_EVENT_GAME_RESULTS";

        public static const MESSAGE_PUBLIC:int = 0;
        public static const MESSAGE_PRIVATE:int = 1;

        public static const CLASS_ADMIN:int = 1;
        public static const CLASS_BAND:int = 2;
        public static const CLASS_FORUM_MOD:int = 3;
        public static const CLASS_CHAT_MOD:int = 4; // Chat Mod + Profile Mod
        public static const CLASS_MP_MOD:int = 5;
        public static const CLASS_LEGEND:int = 6;
        public static const CLASS_AUTHOR:int = 7; // R1 Music Producer, R1 Simfile Author
        public static const CLASS_VETERAN:int = 8;
        public static const CLASS_USER:int = 9;
        public static const CLASS_BANNED:int = 10;
        public static const CLASS_ANONYMOUS:int = 11;

        public static const COLOURS:Array = [0x000000, 0xFF0000, 0x000000, 0x91FF00, 0x91FF00, 0x91FF00, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000];
        public static const CLASS_LEGACY:Array = [0, CLASS_ADMIN, CLASS_BAND, CLASS_FORUM_MOD, CLASS_CHAT_MOD, CLASS_MP_MOD, CLASS_AUTHOR, CLASS_VETERAN, CLASS_USER, CLASS_BANNED, CLASS_ANONYMOUS];

        public static const STATUS_NONE:int = 0;
        public static const STATUS_CLEANUP:int = 1;
        public static const STATUS_PICKING:int = 2;
        public static const STATUS_LOADING:int = 3;
        public static const STATUS_LOADED:int = 4;
        public static const STATUS_PLAYING:int = 5;
        public static const STATUS_RESULTS:int = 6;

        public static const STATUS_VELOCITY:Array = [STATUS_NONE, STATUS_CLEANUP, STATUS_PICKING, STATUS_LOADING, STATUS_LOADED, STATUS_PLAYING, STATUS_RESULTS];
        public static const STATUS_LEGACY:Array = [STATUS_NONE, STATUS_PLAYING, STATUS_PICKING, STATUS_LOADING, STATUS_RESULTS, STATUS_LOADED];

        public static const GAME_UNKNOWN:int = -1;
        public static const GAME_LEGACY:int = 1;
        public static const GAME_VELOCITY:int = 2;
        public static const GAME_R3:int = 3;

        public static const MODE_NORMAL:int = 0;
        public static const MODE_BATTLE:int = 1;
        public static const MODE_SCORE_RAW:int = 0;
        public static const MODE_SCORE_COMBO:int = 1;

        public static const GAME_VERSIONS:Vector.<String> = new <String>["Prochat", "Legacy", "Velocity", "R^3"];
        public static const SERVER_ZONES:Vector.<String> = new <String>["ffr_embedd", "ffr_mp", "ffr_mp_velocity", "ffr_multiplayer"];
        public static const SERVER_EXTENSIONS:Vector.<String> = new <String>["ffr_embeddZoneExt", "ffr_MPZoneExt", "ffr_MPZoneExtVelo", "FFR_EXT"];

        private var server:SmartFoxClient;

        private var _rooms:Object;
        private var _lobby:Room;

        public var connected:Boolean;
        public var currentUser:User;

        public var ghostRooms:Vector.<Room>;

        public var inSolo:Boolean;

        public var mode:int;

        public function Multiplayer(_mode:int = GAME_R3)
        {
            _rooms = {};
            currentUser = new User(false, true);
            ghostRooms = new <Room>[];
            mode = _mode;

            server = new SmartFoxClient(true); // CONFIG::debug);

            CONFIG::debug
            {
                server.addEventListener(SFSEvent.onDebugMessage, onDebugMessage);
            }
            server.addEventListener(SFSEvent.onConnection, onConnection);
            server.addEventListener(SFSEvent.onConnectionLost, onConnectionLost);
            server.addEventListener(SFSEvent.onCreateRoomError, onCreateRoomError);
            server.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponse);
            server.addEventListener(SFSEvent.onLogout, onLogout);
            server.addEventListener(SFSEvent.onAdminMessage, onAdminMessage);
            server.addEventListener(SFSEvent.onModeratorMessage, onModeratorMessage);
            server.addEventListener(SFSEvent.onPlayerSwitched, onPlayerSwitched);
            server.addEventListener(SFSEvent.onSpectatorSwitched, onSpectatorSwitched);
            server.addEventListener(SFSEvent.onPublicMessage, onPublicMessage);
            server.addEventListener(SFSEvent.onPrivateMessage, onPrivateMessage);
            server.addEventListener(SFSEvent.onRoomListUpdate, onRoomListUpdate);
            server.addEventListener(SFSEvent.onRoomVariablesUpdate, onRoomVariablesUpdate);
            server.addEventListener(SFSEvent.onRoomAdded, onRoomAdded);
            server.addEventListener(SFSEvent.onRoomDeleted, onRoomDeleted);
            server.addEventListener(SFSEvent.onRoomLeft, onLeftRoom);
            server.addEventListener(SFSEvent.onJoinRoom, onJoinedRoom);
            server.addEventListener(SFSEvent.onJoinRoomError, onJoinRoomError);
            server.addEventListener(SFSEvent.onUserCountChange, onUserCountChange);
            server.addEventListener(SFSEvent.onUserEnterRoom, onUserEnterRoom);
            server.addEventListener(SFSEvent.onUserLeaveRoom, onUserLeftRoom);
            server.addEventListener(SFSEvent.onUserVariablesUpdate, onUserVariablesUpdate);
        }

        public function get rooms():Vector.<Room>
        {
            var roomsVec:Vector.<Room> = new <Room>[];

            for (var idx:int in _rooms)
                roomsVec.push(_rooms[idx]);

            return roomsVec;
        }

        private function getRoom(room:Room):Room
        {
            return _rooms[room.id];
        }

        private function getRoomById(roomId:int):Room
        {
            return _rooms[roomId];
        }

        public function connect():void
        {
            server.connect(serverAddress, serverPort);
        }

        public function disconnect(_inSolo:Boolean = false):void
        {
            inSolo = _inSolo;
            server.disconnect();
        }

        public function login(username:String, password:String):void
        {
            if (connected)
                server.login(SERVER_ZONES[mode], username, password);
        }

        public function logout():void
        {
            if (connected)
                server.logout();
        }

        public function sendServerMessage(message:String, target:Object = null):void
        {
            if (connected)
            {
                if (target == null)
                    server.sendModeratorMessage(message, SmartFoxClient.MODMSG_TO_ZONE);
                else if (target.userID != null)
                    server.sendModeratorMessage(message, SmartFoxClient.MODMSG_TO_USER, target.id);
                else if (target.roomID != null)
                    server.sendModeratorMessage(message, SmartFoxClient.MODMSG_TO_ROOM, target.id);
            }
        }

        public function nukeRoom(room:Room):void
        {
            if (connected && room)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "nuke_room", {"room": room.id}, SmartFoxClient.XTMSG_TYPE_XML, lobby.id);
        }

        public function muteUser(user:User, time:int = 2, ipBan:Boolean = false):void
        {
            if (connected && user)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "mute_user", {"user": user.name, "bantime": time, "ip": (ipBan ? 1 : 0)}, SmartFoxClient.XTMSG_TYPE_XML, lobby.id);
        }

        public function banUser(user:User, time:int = 2, ipBan:Boolean = false):void
        {
            if (connected && user)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "ban_user", {"user": user.name, "bantime": time, "ip": (ipBan ? 1 : 0)}, SmartFoxClient.XTMSG_TYPE_XML, lobby.id);
        }

        public function sendHTMLMessage(message:String, target:Object = null):void
        {
            if (connected)
            {
                if (target == null)
                    server.sendXtMessage(SERVER_EXTENSIONS[mode], "html_message", {"m": message, "t": SmartFoxClient.MODMSG_TO_ZONE, "v": null});
                else if (target.id != null)
                    server.sendXtMessage(SERVER_EXTENSIONS[mode], "html_message", {"m": message, "t": SmartFoxClient.MODMSG_TO_USER, "v": target.id});
                else if (target.id != null)
                    server.sendXtMessage(SERVER_EXTENSIONS[mode], "html_message", {"m": message, "t": SmartFoxClient.MODMSG_TO_ROOM, "v": target.id});
            }
        }

        public function get lobby():Room
        {
            if (_lobby)
                return _lobby;

            for each (var room:Room in rooms)
            {
                if (room.name == "Lobby")
                {
                    _lobby = room
                    return _lobby
                }
            }

            return null
        }

        public function set lobby(room:Room):void
        {
            _lobby = room;
        }

        public function getUserList(room:Room):void
        {
            if (connected && room)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "getUserList", {"room": room.id});
        }

        public function getUserVariables(... users):void
        {
            if (connected)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "getUserVariables", {"users": users});
        }

        public function getMultiplayerLevel():void
        {
            if (connected)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "getMultiplayerLevel", {});
        }

        public function reportSongStart(room:Room):void
        {
            if (connected && mode == GAME_R3)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "playerStart", {}, "xml", room.id);
        }

        public function reportSongEnd(room:Room):void
        {
            if (connected && mode == GAME_R3)
                server.sendXtMessage(SERVER_EXTENSIONS[mode], "playerFinish", {}, "xml", room.id);
        }

        public function refreshRooms():void
        {
            if (connected)
                server.getRoomList();
        }

        public function joinRoom(room:Room, asPlayer:Boolean = true, password:String = ""):void
        {
            if (connected && room)
                server.joinRoom(room.id, password, !asPlayer, true);
        }

        public function leaveRoom(room:Room):void
        {
            if (connected && room)
            {
                clearRoomPlayerVariables(room);
                server.leaveRoom(room.id);
            }
        }

        /**
         * Attempts to switch the current user's state (player/spectator) in the given room.
         * If the user is trying to become a player, it must currently be a spectator
         * and not playing in any other room.
         */
        public function switchRole(room:Room):void
        {
            if (!connected || !room)
                return;

            if (room.isPlayer(currentUser))
            {
                // Cannot switch mode while playing
                if (room.isInGameState)
                    return;

                server.switchPlayer(room.id);
            }
            else
            {
                // Cannot switch to player if already a player in another room
                if (currentUser.isPlayer)
                {
                    eventError("You cannot be a player in more than one game");
                    return;
                }

                // Cannot switch to player if player slots are filled
                if (room.playerCount >= 2)
                    return;

                server.switchSpectator(room.id);
            }
        }

        public function createRoom(name:String, password:String = "", maxUsers:int = 2, maxSpectators:int = 100):void
        {
            if (connected && name)
            {
                var params:Object = {};
                params.name = (mode == GAME_R3) ? name : "(Non-R3) " + name;
                params.password = password;
                params.maxUsers = maxUsers;
                params.maxSpectators = maxSpectators;
                params.isGame = true;
                params.exitCurrentRoom = false;
                params.uCount = true;
                params.joinAsSpectator = currentUser.isPlayer;
                if (mode == GAME_R3)
                {
                    params.vars = [{name: "GAME_LEVEL", val: currentUser.userLevel, persistent: true},
                        {name: "GAME_MODE", val: MODE_NORMAL, persistent: true},
                        {name: "GAME_SCORE", val: MODE_SCORE_RAW, persistent: true},
                        {name: "GAME_RANKED", val: true, persistent: true}];
                }
                server.createRoom(params);
            }
        }

        public function joinLobby():void
        {
            joinRoom(lobby);
        }

        public function sendMessage(room:Room, message:String, escape:Boolean = true):void
        {
            if (connected && room && message)
                server.sendPublicMessage(escape ? htmlEscape(message) : message, room.id);
        }

        public function sendPrivateMessage(user:User, message:String, room:Room = null):void
        {
            if (connected && user && message)
                server.sendPrivateMessage(htmlEscape(message), user.id, (room ? room.id : -1));
        }

        public static function hex2dec(hex:String):int
        {
            return hex ? parseInt(hex, 16) : 0;
        }

        public static function dec2hex(dec:int):String
        {
            return dec.toString(16).toUpperCase();
        }

        /**
         * Returns a gameplay object from the room's variables given the user's playerIdx.
         * If the user isn't a player in that room, returns null.
         */
        private function getUserGameplayFromRoom(room:Room, user:User):Object
        {
            var ret:Object = {};
            var vars:Object = room.variables;
            var stats:Array;

            var playerIdx:int = room.getPlayerIndex(user);
            if (playerIdx <= 0)
                return null;

            switch (mode)
            {
                case GAME_VELOCITY:
                    var prefix:String = "p" + playerIdx;
                    ret.maxCombo = hex2dec(vars[prefix + "_maxcombo"]);
                    ret.combo = hex2dec(vars[prefix + "_combo"]);
                    ret.perfect = hex2dec(vars[prefix + "_perfect"]);
                    ret.good = hex2dec(vars[prefix + "_good"]);
                    ret.average = hex2dec(vars[prefix + "_average"]);
                    ret.boo = hex2dec(vars[prefix + "_boo"]);
                    ret.miss = hex2dec(vars[prefix + "_miss"]);
                    ret.songID = hex2dec(vars[prefix + "_levelid"]);
                    ret.statusLoading = hex2dec(vars[prefix + "_levelloading"]);
                    ret.status = STATUS_VELOCITY[hex2dec(vars[prefix + "_state"])];
                    //user.id = ret.siteID = hex2dec(vars[prefix + "_uid"]);
                    ret.userName = vars[prefix + "_name"];
                    ret.score = ret.perfect * 50 + ret.good * 25 + ret.average * 5 - ret.miss * 10 - ret.boo * 5;
                    ret.amazing = 0;
                    ret.life = 24;
                    break;
                case GAME_LEGACY:
                    stats = String(vars["mpstats" + user.id]).split(":");
                    ret.songName = stats[0] || "No Song Selected";
                    ret.score = int(stats[1]);
                    ret.life = int(stats[2]);
                    ret.maxCombo = int(stats[3]);
                    ret.combo = int(stats[4]);
                    ret.perfect = int(stats[5]);
                    ret.good = int(stats[6]);
                    ret.average = int(stats[7]);
                    ret.miss = int(stats[8]);
                    ret.boo = int(stats[9]);
                    ret.status = STATUS_LEGACY[int(stats[10])];
                    ret.amazing = 0;
                    var loading:Object = vars["arc_status_loading" + user.id];
                    if (loading != null)
                        ret.statusLoading = int(loading);
                    break;
                case GAME_R3:
                    stats = String(vars["P" + playerIdx + "_GAMESCORES"]).split(":");
                    ret.score = int(stats[0]);
                    ret.amazing = int(stats[1]);
                    ret.perfect = int(stats[2]);
                    ret.good = int(stats[3]);
                    ret.average = int(stats[4]);
                    ret.miss = int(stats[5]);
                    ret.boo = int(stats[6]);
                    ret.combo = int(stats[7]);
                    ret.maxCombo = int(stats[8]);
                    ret.status = int(vars["P" + playerIdx + "_STATE"]);
                    ret.songID = int(vars["P" + playerIdx + "_SONGID"]);
                    ret.statusLoading = int(vars["P" + playerIdx + "_SONGID_PROGRESS"]);
                    ret.life = int(vars["P" + playerIdx + "_GAMELIFE"]);
                    break;
            }

            var engine:String = vars["arc_engine" + playerIdx];
            if (engine)
            {
                ret.song = ArcGlobals.instance.legacyDecode(JSON.parse(engine));
                if (ret.song)
                {
                    if (!ret.song.name)
                        ret.song.name = ret.songName;
                    if (!("level" in ret.song) || ret.song.level < 0)
                        ret.song.level = ret.songID || -1;
                }
            }
            else
            {
                var playlist:Playlist = Playlist.instanceCanon;
                if (ret.songID)
                    ret.song = playlist.playList[ret.songID];
                if (!ret.song)
                {
                    for each (var song:Object in playlist.playList)
                    {
                        if (song.name == ret.songName)
                        {
                            ret.song = song;
                            break;
                        }
                    }
                }
            }
            var replay:Object = vars["arc_replay" + playerIdx];
            if (replay)
                ret.replay = replay;

            ret.room = room;
            ret.user = user;

            return ret;
        }

        /**
         * Sends the room variables to the server to propagate to other users
         */
        public function sendRoomVariables(room:Room, data:Object, changeOwnership:Boolean = true):void
        {
            var varArray:Array = [];
            for (var name:String in data)
                varArray.push({name: name, val: data[name]});
            if (varArray.length > 0)
                server.setRoomVariables(varArray, room.id, changeOwnership);
        }

        private function clearRoomPlayerVariables(room:Room):void
        {
            if (!room.isGameRoom)
                return;

            var vars:Object = {};
            var currentUserIdx:int = room.getPlayerIndex(currentUser);

            if (currentUserIdx > 0)
            {
                var prefix:String = currentUserIdx.toString();
                switch (mode)
                {
                    case GAME_R3:
                        prefix = "P" + prefix;
                        vars[prefix + "_NAME"] = null;
                        vars[prefix + "_UID"] = null;
                        break;
                    case GAME_VELOCITY:
                        prefix = "p" + prefix;
                        vars[prefix + "_name"] = null;
                        vars[prefix + "_uid"] = null;
                        break;
                    case GAME_LEGACY:
                        vars["player" + prefix] = null;
                        vars["mpstats" + prefix] = null;
                        break;
                }
                vars["arc_engine" + currentUser.id] = null;
                vars["arc_replay" + currentUser.id] = null;
            }

            sendRoomVariables(room, vars);
        }

        private function setRoomPlayerVariables(room:Room):void
        {
            if (!room.isGameRoom)
                return;

            var vars:Object = {};
            var currentUserIdx:int = room.getPlayerIndex(currentUser);

            if (currentUserIdx > 0)
            {
                var prefix:String = currentUserIdx.toString();
                switch (mode)
                {
                    case GAME_R3:
                        prefix = "P" + prefix;
                        vars[prefix + "_NAME"] = currentUser.name;
                        vars[prefix + "_UID"] = currentUser.id;

                        // Check if there are opponents
                        if (!room.playerCount > 1)
                            sendRoomVariables(room, {"GAME_LEVEL": currentUser.userLevel}, false);
                        break;
                    case GAME_VELOCITY:
                        prefix = "p" + prefix;
                        vars[prefix + "_name"] = currentUser.name;
                        vars[prefix + "_uid"] = dec2hex(currentUser.id);
                        break;
                    case GAME_LEGACY:
                        vars["player" + prefix] = currentUser.name;
                        vars["mpstats" + prefix] = "No Song Selected:0:0:0:0:0:0:0:0:0:0";
                        break;
                }
            }

            sendRoomVariables(room, vars);
        }

        /**
         * Sets the `vars` of the current user.
         */
        private function setCurrentUserVariables():void
        {
            var vars:Array = [];
            switch (mode)
            {
                case GAME_R3:
                    vars["UID"] = currentUser.id;
                    vars["GAME_VER"] = GAME_VERSIONS[GAME_R3];
                    vars["MP_LEVEL"] = currentUser.userLevel;
                    vars["MP_CLASS"] = currentUser.userClass;
                    vars["MP_COLOR"] = currentUser.userColour;
                    vars["MP_STATUS"] = currentUser.userStatus;
                    break;
                default:
                    vars["MP_Level"] = currentUser.userLevel;
                    vars["MP_Class"] = CLASS_LEGACY.indexOf(currentUser.userClass);
                    vars["MP_Color"] = currentUser.userColour;
                    break;
            }
            currentUser.variables = vars;
        }

        public function setRoomGameplay(room:Room, data:Object):void
        {
            var vars:Object = {};
            if (room.hasUser(currentUser))
            {
                var user:User = room.getPlayer(1);
                switch (mode)
                {
                    case GAME_VELOCITY:
                        var prefix:String = "p" + user.playerIdx;
                        vars[prefix + "_maxcombo"] = dec2hex(data.maxCombo);
                        vars[prefix + "_combo"] = dec2hex(data.combo);
                        vars[prefix + "_perfect"] = dec2hex(data.amazing + data.perfect);
                        vars[prefix + "_good"] = dec2hex(data.good);
                        vars[prefix + "_average"] = dec2hex(data.average);
                        vars[prefix + "_boo"] = dec2hex(data.boo);
                        vars[prefix + "_miss"] = dec2hex(data.miss);
                        vars[prefix + "_levelid"] = dec2hex(data.song == null ? data.songID : int(data.song.level));
                        vars[prefix + "_levelloading"] = dec2hex(data.statusLoading);
                        vars[prefix + "_state"] = dec2hex(STATUS_VELOCITY.indexOf(data.status));
                        if (data.gameScoreRecorded != null)
                            vars["gameScoreRecorded"] = data.gameScoreRecorded;
                        break;
                    case GAME_LEGACY:
                        var status:int = data.status;
                        switch (status)
                        {
                            case STATUS_LOADED:
                                status = STATUS_PLAYING;
                                break;
                            case STATUS_PICKING:
                                status = STATUS_NONE;
                                break;
                        }
                        vars["mpstats" + user.playerIdx] = String((data.songName != null ? data.songName : data.song.name)).replace(/:/g, "") + ":" + int(data.score) + ":" + int(data.life) + ":" + int(data.maxCombo) + ":" + int(data.combo) + ":" + int(data.amazing + data.perfect) + ":" + int(data.good) + ":" + int(data.average) + ":" + int(data.miss) + ":" + int(data.boo) + ":" + STATUS_LEGACY.indexOf(status);
                        if (data.statusLoading != null)
                            vars["arc_status_loading" + user.playerIdx] = int(data.statusLoading);
                        else
                            vars["arc_status_loading" + user.playerIdx] = null;
                        break;
                    case GAME_R3:
                        vars["P" + user.playerIdx + "_GAMESCORES"] = int(data.score) + ":" + int(data.amazing) + ":" + int(data.perfect) + ":" + int(data.good) + ":" + int(data.average) + ":" + int(data.miss) + ":" + int(data.boo) + ":" + int(data.combo) + ":" + int(data.maxCombo);
                        vars["P" + user.playerIdx + "_STATE"] = int(data.status);
                        vars["P" + user.playerIdx + "_GAMELIFE"] = int(data.life * 24 / 100);
                        vars["P" + user.playerIdx + "_SONGID"] = (data.song == null ? data.songID : int(data.song.level));
                        vars["P" + user.playerIdx + "_SONGID_PROGRESS"] = int(data.statusLoading);
                        break;
                }
                var engine:Object = ArcGlobals.instance.legacyEncode(data.song);
                if (engine)
                {
                    if (mode == GAME_LEGACY)
                        delete engine.songName;
                    vars["arc_engine" + user.playerIdx] = JSON.stringify(engine);
                }
                else if (data.song === null || (data.song && !data.song.engine))
                    vars["arc_engine" + user.playerIdx] = null;
                vars["arc_replay" + user.playerIdx] = data.replay || null;
            }
            sendRoomVariables(room, vars);
        }

        private function applyUserVariables(user:User):void
        {
            if (user != null)
            {
                var vars:Object = user.variables;
                switch (mode)
                {
                    case GAME_R3:
                        user.siteId = vars["UID"];
                        user.gameVersion = GAME_VERSIONS.indexOf(vars["GAME_VER"]);
                        user.userLevel = vars["MP_LEVEL"];
                        user.userClass = vars["MP_CLASS"];
                        user.userColour = vars["MP_COLOR"];
                        user.userStatus = vars["MP_STATUS"];
                        break;
                    default:
                        user.userLevel = vars["MP_Level"];
                        user.userClass = CLASS_LEGACY[vars["MP_Class"]];
                        user.userColour = vars["MP_Color"];
                        break;
                }
            }
        }

        private function removeRoom(room:Room):void
        {
            delete _rooms[room.id];
        }

        private function addRoom(room:Room):void
        {
            room.connection = this;
            _rooms[room.id] = room;

            if (room.name == "Lobby")
                lobby = room;

            if (room.isGameRoom)
                room.match = {status: STATUS_NONE, players: [], gameplay: [], playerStatus: []};

            updateRoom(room);
        }

        private function updateRoom(room:Room):void
        {
            if (room == null)
                return;

            for each (var user:User in room.players)
                user.gameplay = getUserGameplayFromRoom(room, user);

            if (mode == GAME_R3)
            {
                room.level = room.variables["GAME_LEVEL"];
                room.mode = room.variables["GAME_MODE"];
                room.scoreMode = room.variables["GAME_SCORE"];
                room.ranked = room.variables["GAME_RANKED"];
            }
            else
            {
                var name:Array = new RegExp("\\[(\\d+)\\] (.+)").exec(room.name);
                if (name)
                {
                    room.name = name[2];
                    room.level = parseInt(name[1]);
                }
            }
        }

        private function getRoomUserById(room:Room, userId:int):User
        {
            if (room == null)
                return null;

            return room.getUser(userId);
        }

        private function eventError(message:String):void
        {
            dispatchEvent(new ErrorEvent({message: message}));
        }

        private function eventConnection():void
        {
            dispatchEvent(new ConnectionEvent());
        }

        private function eventLogin():void
        {
            dispatchEvent(new LoginEvent());
        }

        private function eventServerMessage(message:String, user:User = null):void
        {
            dispatchEvent(new ServerMessageEvent({message: stripMessage(message), user: user}));
        }

        private function eventMessage(type:int, room:Room, user:User, message:String):void
        {
            dispatchEvent(new MessageEvent({msgType: type, room: room, user: user, message: stripMessage(message)}));
        }

        private function eventRoomUserStatus(room:Room, user:User):void
        {
            dispatchEvent(new RoomUserStatusEvent({room: room, user: user}));
        }

        private function eventRoomJoined(room:Room):void
        {
            dispatchEvent(new RoomJoinedEvent({room: room}));
        }

        private function eventRoomLeft(room:Room):void
        {
            dispatchEvent(new RoomLeftEvent({room: room}));
        }

        private function eventRoomUpdate(room:Room, roomList:Boolean = false, changed:Array = null):void
        {
            dispatchEvent(new RoomUpdateEvent({room: room, roomList: roomList, changed: (changed || [])}));
        }

        private function eventRoomUser(room:Room, user:User):void
        {
            dispatchEvent(new RoomUserEvent({room: room, user: user}));
        }

        private function eventRoomList():void
        {
            dispatchEvent(new RoomListEvent());
        }

        private function eventUserUpdate(user:User, changed:Array = null):void
        {
            dispatchEvent(new UserUpdateEvent({user: user, changed: (changed || [])}));
        }

        private function eventGameStart(room:Room):void
        {
            dispatchEvent(new GameStartEvent({room: room}));
        }

        private function eventGameUpdate(room:Room, user:User):void
        {
            dispatchEvent(new GameUpdateEvent({room: room, user: user}));
        }

        private function eventGameResults(room:Room):void
        {
            dispatchEvent(new GameResultsEvent({room: room}));
        }

        private function onConnection(event:ConnectionSFSEvent):void
        {
            connected = event.success;

            if (connected)
            {
                _rooms = {};
                currentUser = new User();
                ghostRooms = new <Room>[];
            }

            eventConnection();

            if (!connected)
                eventError("Multiplayer Connection Error: " + event.error);
        }

        private function onConnectionLost(event:ConnectionLostSFSEvent):void
        {
            connected = false;

            eventConnection();
            if (inSolo == false)
            {
                eventError("Multiplayer Connection Lost");
            }
        }

        CONFIG::debug
        {
            private function onDebugMessage(event:DebugMessageSFSEvent):void
            {
                //trace("arc_msg: SFS: " + event.params.message);
            }
        }

        private function onCreateRoomError(event:CreateRoomErrorSFSEvent):void
        {
            eventError("Create Room Failed: " + event.error);
        }

        private function onExtensionResponse(event:ExtensionResponseSFSEvent):void
        {
            var data:Object = event.dataObj;
            switch (data._cmd)
            {
                case "logOK":
                    currentUser.loggedIn = true;
                    currentUser.name = data.name;
                    currentUser.userClass = (mode == GAME_R3 ? data.userclass : CLASS_LEGACY[data.userclass]);
                    currentUser.userColour = data.usercolor;
                    currentUser.userLevel = data.userlevel;
                    currentUser.id = data.userID;
                    currentUser.siteId = int(data.siteID);
                    currentUser.isModerator = (data.mod || data.userclass == CLASS_ADMIN || data.userclass == CLASS_FORUM_MOD || data.userclass == CLASS_CHAT_MOD || data.userclass == CLASS_MP_MOD);
                    currentUser.isAdmin = (data.userclass == CLASS_ADMIN);
                    currentUser.userStatus = 0;

                    setCurrentUserVariables();

                    server.myUserId = currentUser.id;
                    server.myUserName = currentUser.name;
                    server.amIModerator = currentUser.isModerator;
                    server.playerId = -1;

                    eventLogin();
                    refreshRooms();
                    break;
                case "logKO":
                    currentUser.loggedIn = false;

                    eventLogin();
                    eventError("Login Failed: " + data.err);
                    break;
                case "specStatus":
                    /*var player1:int = int(data.p1i);
                       var player2:int = int(data.p2i);
                       if (player1 > 0) {

                       }
                       data.status;
                       data.p2i;
                       data.p2n;*/
                    break;
                case "stop": // when someone closes a room apparently
                    //data.n; // username
                    break;
                case "html_message":
                    data.uid = getRoomUserById(data.rid, data.uid);
                    data.rid = getRoom(data.rid);
                    dispatchEvent(new ExtensionResponseEvent({data: data}));
                    break;
            }
        }

        private function onLogout(event:LogoutSFSEvent):void
        {
            currentUser.loggedIn = false;
            eventLogin();
        }

        private function onAdminMessage(event:AdminMessageSFSEvent):void
        {
            eventServerMessage(htmlUnescape(event.message));
        }

        private function onModeratorMessage(event:ModerationMessageSFSEvent):void
        {
            if (event.userId != null)
                eventServerMessage(htmlUnescape(event.message), event.userId);
        }

        private function onPlayerSwitched(event:PlayerSwitchedSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);
            var user:User = event.userId == 0 ? currentUser : getRoomUserById(room, event.userId);

            if (!user)
                return;

            if (user == currentUser)
                clearRoomPlayerVariables(room);

            if (room.removePlayer(user.playerIdx))
            {
                user.isPlayer = false;
                user.playerIdx = -1;
            }

            updateRoom(room);

            eventRoomUserStatus(room, user);
        }

        private function onSpectatorSwitched(event:SpectatorSwitchedSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);
            var user:User = event.userId == 0 ? currentUser : getRoomUserById(room, event.userId);

            if (!user)
                return;

            if (user == currentUser)
                setRoomPlayerVariables(room);

            if (!user.isPlayer)
            {
                var newPlayerIdx:int = room.addPlayer(user);
                if (newPlayerIdx > 0)
                {
                    user.isPlayer = true;
                    user.playerIdx = newPlayerIdx;
                }
            }

            updateRoom(room);

            eventRoomUserStatus(room, user);
        }

        private function onPrivateMessage(event:PrivateMessageSFSEvent):void
        {
            if (event.userId == currentUser.id)
                return; // Ignore PM events sent by yourself because they don't include the recipient for some stupid reason

            var room:Room = getRoomById(event.roomId);
            var user:User = getRoomUserById(room, event.userId);

            if (user)
                eventMessage(MESSAGE_PRIVATE, room, user, htmlUnescape(event.message));
        }

        private function onPublicMessage(event:PublicMessageSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);
            var user:User = getRoomUserById(room, event.userId);

            if (user)
                eventMessage(MESSAGE_PUBLIC, room, user, htmlUnescape(event.message));
        }

        private function onRoomListUpdate(event:RoomListUpdateSFSEvent):void
        {
            for each (var evtRoom:Room in event.roomList)
            {
                var room:Room = getRoom(evtRoom);
                if (!room)
                {
                    addRoom(evtRoom);
                }
            }

            eventRoomList();
        }

        private function onRoomVariablesUpdate(event:RoomVariablesUpdateSFSEvent):void
        {
            var room:Room = getRoom(event.room);
            updateRoom(event.room);
            // TODO: Check roomList param validity
            eventRoomUpdate(room, true, event.changedVars);

            if (!room.isGameRoom)
                return;

            var status:int = -1;
            var istatus:int = STATUS_NONE;
            var song:Object = null;
            var songMatch:Boolean = room.playerCount > 0;
            for each (var user:User in room.players)
            {
                var gameplay:Object = user.gameplay;
                if (gameplay)
                {
                    var pstatus:int = room.match.playerStatus[user.id] || STATUS_NONE;
                    var newstatus:Boolean = false;
                    if (gameplay.status > pstatus)
                    {
                        room.match.playerStatus[user.id] = gameplay.status;
                        pstatus = gameplay.status;
                        newstatus = true;
                    }
                    if (status < 0 || status > pstatus)
                        status = pstatus;
                    if (gameplay.status > istatus)
                        istatus = gameplay.status;

                    if (gameplay.status == STATUS_PLAYING)
                        eventGameUpdate(room, user);
                    if (newstatus && gameplay.status == STATUS_RESULTS)
                    {
                        room.match.players[user.id] = user;
                        room.match.gameplay[user.id] = gameplay;
                        eventGameUpdate(room, user);
                    }

                    if (!song)
                        song = gameplay.song;
                    if (song)
                        songMatch &&= gameplay.song && ((song.level >= 0 && song.level == gameplay.song.level || (song.levelid && song.levelid == gameplay.song.levelid)) && ((!song.engine && !gameplay.song.engine) || song.engine.id == gameplay.song.engine.id));
                }
            }

            var eventReport:int = 0;
            if (status > room.match.status)
            {
                if (status == STATUS_RESULTS)
                {
                    eventReport = 2;
                    if (room.isPlayer(currentUser))
                        reportSongEnd(room);
                }
                else if (status == STATUS_LOADED || (status == STATUS_PLAYING && room.match.status < STATUS_LOADED))
                {
                    if (room.players.length > 1 && songMatch)
                    {
                        eventReport = 1;
                        if (room.isPlayer(currentUser))
                            reportSongStart(room);
                        status = STATUS_PLAYING;
                    }
                    else
                        status = STATUS_PICKING;
                }
            }
            if (istatus < STATUS_PLAYING)
            {
                room.match.status = STATUS_NONE;
                room.match.players.splice(0);
                room.match.gameplay.splice(0);
                room.match.playerStatus.splice(0);
            }

            if (status > room.match.status)
                room.match.status = status;
            if (songMatch)
                room.match.song = song;

            if (eventReport == 1)
                eventGameStart(room);
            else if (eventReport == 2)
                eventGameResults(room);
        }

        private function onRoomAdded(event:RoomAddedSFSEvent):void
        {
            addRoom(event.room);
            eventRoomList();
        }

        private function onRoomDeleted(event:RoomDeletedSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);

            if (room.getPlayerIndex(currentUser) > 0)
            {
                currentUser.isPlayer = false;
                currentUser.playerIdx = -1;
            }

            removeRoom(room);
            if (room.hasUser(currentUser))
                ghostRooms.push(room);

            eventRoomList();
        }

        /**
         * Called when the current player has left a room
         */
        private function onLeftRoom(event:LeftRoomSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);
            if (room == null)
            {
                for each (var ghost:Room in ghostRooms)
                {
                    if (ghost.id == event.roomId)
                    {
                        room = ghost;
                        ghostRooms = ghostRooms.filter(function(item:Room, index:int, vec:Vector.<Room>):Boolean
                        {
                            return item.id != ghost.id;
                        });
                        break;
                    }
                }
            }
            else
            {
                if (room.removePlayer(currentUser.playerIdx))
                {
                    currentUser.isPlayer = false;
                    currentUser.playerIdx = -1;
                }

                room.removeUser(currentUser.id);
            }

            updateRoom(room);

            eventRoomLeft(room);
        }

        /**
         * Called when the current player has joined a room.
         * This event populates the joined room with a user list.
         */
        private function onJoinedRoom(event:JoinedRoomSFSEvent):void
        {
            var room:Room = getRoom(event.room);

            // Adds the users to the room
            for each (var user:User in event.users)
            {
                if (user.id == currentUser.id)
                {
                    // This is necessary since the server does not provide `vars` for the logged in user
                    // on `joinOK` events. These `vars` are only provided in the `logOK` part of a `xtRes` event.
                    server.setUserVariables(currentUser.variables);

                    room.addUser(currentUser);

                    // Current user always gets -1 as a playerIdx on room join, so attempt to add it to players
                    if (room.isGameRoom && !currentUser.isPlayer)
                    {
                        var newPlayerIdx:int = room.addPlayer(currentUser);

                        if (newPlayerIdx > 0)
                        {
                            currentUser.isPlayer = true;
                            currentUser.playerIdx = newPlayerIdx;
                        }
                    }
                }
                else
                {
                    applyUserVariables(user);
                    room.addUser(user);

                    // If the user has a positive playerIdx, insert it in the room's players
                    if (room.isGameRoom && user.playerIdx > 0)
                        room.setPlayer(user.playerIdx, user);
                }
            }

            updateRoom(room);
            setRoomPlayerVariables(room);

            // Propagate the events
            eventUserUpdate(currentUser);
            eventRoomJoined(room);
        }

        private function onJoinRoomError(event:JoinRoomErrorSFSEvent):void
        {
            eventError("Join Failed: " + event.error);
        }

        private function onUserCountChange(event:UserCountChangeSFSEvent):void
        {
            // TODO: See if this is necessary
        }

        /**
         * Called when another user enters any room that the current user is in
         */
        private function onUserEnterRoom(event:UserEnterRoomSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);
            var user:User = event.user;

            // TODO: Check if actually needed, since uVars is called right after
            applyUserVariables(user);

            room.addUser(user);

            // Always attempt to add a new user to a room as a player if possible
            if (room.isGameRoom)
                if (room.setPlayer(user.playerIdx, user) > 0)
                    user.gameplay = getUserGameplayFromRoom(room, user);

            eventRoomUser(room, user);
            eventRoomUpdate(room);
        }

        /**
         * Called when another user leaves any room that the current user is in
         */
        private function onUserLeftRoom(event:UserLeftRoomSFSEvent):void
        {
            var room:Room = getRoomById(event.roomId);
            var user:User = getRoomUserById(room, event.userId);

            if (user)
            {
                var playerIdx:int = room.getPlayerIndex(user);
                if (playerIdx > 0 && room.removePlayer(playerIdx))
                    user.playerIdx = -1;

                room.removeUser(user.id);
            }

            eventRoomUser(room, user);
            eventRoomUpdate(room);
        }

        private function onUserVariablesUpdate(event:UserVariablesUpdateSFSEvent):void
        {
            for each (var room:Room in rooms)
            {
                var user:User = room.getUser(event.user.id);
                if (!user)
                    continue;

                user.setVariables(event.user.variables)
                applyUserVariables(user);
                eventUserUpdate(user);
                return;
            }
        }

        public static function htmlUnescape(str:String):String
        {
            try
            {
                return new XMLDocument(str).firstChild.nodeValue;
            }
            catch (error:Error)
            {
            }
            return str;
        }

        public static function htmlEscape(str:String):String
        {
            return XML(new XMLNode(XMLNodeType.TEXT_NODE, str)).toXMLString();
        }

        private static function stripMessage(str:String):String
        {
            if (str == null)
                return "";
            while (str.length && str.charAt(str.length - 1) == '\n')
                str = str.substr(0, str.length - 1);
            while (str.length && str.charAt(0) == '\n')
                str = str.substr(1);
            return str;
        }
    }
}
