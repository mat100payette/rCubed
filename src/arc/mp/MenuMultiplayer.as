package arc.mp
{
    import arc.ArcGlobals;
    import arc.mp.ListItemDoubleClick;
    import arc.mp.MultiplayerChat;
    import arc.mp.MultiplayerUsers;
    import classes.Alert;
    import classes.Language;
    import classes.Room;
    import classes.User;
    import classes.ui.BoxButton;
    import classes.ui.MPCreateRoomPrompt;
    import classes.ui.Prompt;
    import classes.ui.Text;
    import classes.ui.Throbber;
    import com.bit101.components.List;
    import com.bit101.components.PushButton;
    import com.bit101.components.Style;
    import com.bit101.components.Window;
    import com.flashfla.net.Multiplayer;
    import com.flashfla.net.events.ConnectionEvent;
    import com.flashfla.net.events.LoginEvent;
    import com.flashfla.net.events.RoomJoinedEvent;
    import com.flashfla.net.events.RoomLeftEvent;
    import com.flashfla.net.events.RoomListEvent;
    import com.flashfla.net.events.RoomUserStatusEvent;
    import com.flashfla.net.events.ServerMessageEvent;
    import com.flashfla.utils.HtmlUtil;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.utils.Timer;
    import menu.DisplayLayer;

    public class MenuMultiplayer extends DisplayLayer
    {
        public var _lang:Language = Language.instance;

        private var _controlChat:MultiplayerChat;
        private var _controlUsers:MultiplayerUsers;
        private var _controlRooms:List;
        private var _controlCreate:PushButton;

        private var _textLogin:Text;
        private var _buttonMP:BoxButton;
        private var _buttonDisconnect:BoxButton;
        private var _buttonLobby:BoxButton;
        private var _throbber:Throbber;

        private var _updateTimer:Timer;

        private var _connection:Multiplayer;

        public var window:Window;

        public function MenuMultiplayer()
        {
            _connection = MultiplayerState.instance.connection;
            // Connect immediately if logged in
            if (!GlobalVariables.instance.activeUser.isGuest && GlobalVariables.instance.activeUser.id != 2)
            {
                _connection.connect();
            }
            else
            {
                _textLogin = new Text(this, 0, 0, "Please Login or Register");
                _textLogin.x = Main.GAME_WIDTH / 2 - _textLogin.width / 2;
                _textLogin.y = Main.GAME_HEIGHT / 2 - _textLogin.height * 3 / 2;
                return;
            }

            Style.fontSize = ArcGlobals.instance.configMPSize;

            window = new Window();
            window.title = "Lobby";
            window.hasCloseButton = true;
            window.hasMinimizeButton = false;

            _controlRooms = new List();
            _controlRooms.listItemClass = ListItemDoubleClick;
            _controlRooms.autoHideScrollBar = true;
            _controlRooms.move(0, 0);
            _controlRooms.setSize(200, 350);
            _controlRooms.addEventListener(MouseEvent.DOUBLE_CLICK, onRoomDoubleClick);
            window.addChild(_controlRooms);
            buildContextMenu();

            _controlChat = new MultiplayerChat(window, _connection.lobby);
            _controlChat.move(_controlRooms.x + _controlRooms.width, _controlRooms.y);
            _controlChat.setSize(365, _controlRooms.height + _controlChat.inputHeight);
            _controlChat.resize();

            _controlUsers = new MultiplayerUsers(window, _connection.lobby, this, _controlChat);
            _controlUsers.move(_controlChat.x + _controlChat.width, _controlChat.y);
            _controlUsers.setSize(_controlUsers.width, _controlChat.height);
            _controlUsers.resize();

            _controlCreate = new PushButton();
            _controlCreate.label = "Create Room";
            _controlCreate.setSize(_controlRooms.width, _controlChat.inputHeight);
            _controlCreate.move(_controlRooms.x, _controlRooms.y + _controlRooms.height);
            _controlCreate.addEventListener(MouseEvent.CLICK, onCreateRoomClick);
            window.addChild(_controlCreate);

            window.width = _controlUsers.x + _controlUsers.width;
            window.height = window.titleBar.height + _controlChat.y + _controlChat.height;

            _connection.addEventListener(Multiplayer.EVENT_SERVER_MESSAGE, onServerMessageEvent);
            _connection.addEventListener(Multiplayer.EVENT_CONNECTION, onConnectionEvent);
            _connection.addEventListener(Multiplayer.EVENT_LOGIN, onLoginEvent);
            _connection.addEventListener(Multiplayer.EVENT_ROOM_JOINED, onRoomJoinedEvent);
            _connection.addEventListener(Multiplayer.EVENT_ROOM_LEFT, onRoomLeftEvent);
            _connection.addEventListener(Multiplayer.EVENT_ROOM_LIST, onRoomListEvent);
            _connection.addEventListener(Multiplayer.EVENT_ROOM_USER_STATUS, onRoomUserStatusEvent);
            _connection.addGameUpdateCallback(onRoomUpdateEvent);

            window.addEventListener(Event.CLOSE, onCloseEvent);

            _buttonMP = new BoxButton(this, 5, Main.GAME_HEIGHT - 30, 130, 25, "Connect", 12, onClickMP);
            showButton(_buttonMP, false);

            _buttonDisconnect = new BoxButton(null, _buttonMP.x, _buttonMP.y, _buttonMP.width, _buttonMP.height, "Disconnect", 12, onClickDisconnect);

            _throbber = new Throbber();
            _throbber.x = Main.GAME_WIDTH / 2;
            _throbber.y = Main.GAME_HEIGHT / 2;
            showThrobber();
            addChild(_throbber);

            _updateTimer = new Timer(5000);
            _updateTimer.addEventListener(TimerEvent.TIMER, onUpdateTimer);
        }

        override public function dispose():void
        {
            var i:int = 0;
        }

        public function get currentUser():User
        {
            return _connection.currentUser;
        }

        private function onRoomDoubleClick(event:MouseEvent):void
        {
            if (_controlRooms.selectedItem != null && _controlRooms.selectedItem.data != null)
            {
                var room:Room = _controlRooms.selectedItem.data;
                joinRoom(room, true);
            }
        }

        private function onCreateRoomClick(event:MouseEvent):void
        {
            function e_createRoom(roomName:String, password:String):void
            {
                _connection.createRoom(roomName, password);
            }

            new MPCreateRoomPrompt(this, 320, 120, e_createRoom);
        }

        private function onServerMessageEvent(event:ServerMessageEvent):void
        {
            Alert.add(_lang.string("mp_server_message") + event.message);
        }

        private function onConnectionEvent(event:ConnectionEvent):void
        {
            showButton(_buttonDisconnect, _connection.connected);
            showButton(_buttonMP, !_connection.connected);
            if (!_connection.connected)
                hideThrobber();
        }

        private function onLoginEvent(event:LoginEvent):void
        {
            buildContextMenu();
        }

        private function onRoomJoinedEvent(event:RoomJoinedEvent):void
        {
            if (event.room == _connection.lobby)
            {
                openWindow();
                updateWindowTitle(event.room);
                hideThrobber();
            }
            else
            {
                updateRoomPanel(event.room);
                new MultiplayerRoom(this, event.room);
            }
        }

        private function onRoomLeftEvent(event:RoomLeftEvent):void
        {
            if (event.room == _connection.lobby)
                closeWindow();
        }

        private function onRoomListEvent(event:RoomListEvent):void
        {
            updateRooms();

            _controlChat.room = _connection.lobby;
            _controlUsers.room = _connection.lobby;
        }

        private function onRoomUserStatusEvent(event:RoomUserStatusEvent):void
        {
            updateRoomPanel(event.room);
        }

        private function onRoomUpdateEvent(room:Room, roomList:Boolean):void
        {
            if (roomList == true)
                updateRoomPanel(room);
        }

        private function onCloseEvent(event:Event):void
        {
            if (!_connection.connected)
            {
                closeWindow();
                return;
            }

            var inGame:Boolean = false;
            for each (var room:Room in _connection.rooms)
            {
                if (room.hasUser(currentUser) && room != _connection.lobby)
                    inGame = true;
            }

            if (inGame)
                _connection.leaveRoom(_connection.lobby);
            else
            {
                closeWindow();
                _connection.disconnect();
            }
        }

        private function onClickMP(event:MouseEvent):void
        {
            if (_connection.connected)
                _connection.disconnect();

            _connection.connect();
            showThrobber();
        }

        private function onClickDisconnect(event:MouseEvent):void
        {
            if (_connection.connected)
                _connection.disconnect();
        }

        private function onClickJoinLobby(event:MouseEvent):void
        {
            _connection.joinLobby();
        }

        private function onUpdateTimer(event:TimerEvent):void
        {
            if (_connection.connected)
            {
                updateWindowTitle(_connection.lobby);

                if (!MultiplayerState.instance.gameplayPlayingStatus())
                    _connection.refreshRooms();
            }
        }

        private function getContextMenuEventRoom(event:ContextMenuEvent):Room
        {
            if (!event.mouseTarget.hasOwnProperty("data"))
                return null;

            var item:Object = event.mouseTarget["data"];

            if (!item)
                return null;

            return item["data"] as Room;
        }

        private function spectateRoom(event:ContextMenuEvent):void
        {
            var room:Room = getContextMenuEventRoom(event);
            joinRoom(room, false);
        }

        private function nukeRoom(event:ContextMenuEvent):void
        {
            var room:Room = getContextMenuEventRoom(event);
            _connection.nukeRoom(room);
        }

        public function buildContextMenu():void
        {
            var contextMenu:ContextMenu = new ContextMenu();

            var spectateItem:ContextMenuItem = new ContextMenuItem("Spectate");
            spectateItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, spectateRoom);
            contextMenu.customItems.push(spectateItem);

            if (currentUser.isModerator)
            {
                var nukeRoomItem:ContextMenuItem = new ContextMenuItem("Nuke Room");
                nukeRoomItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, nukeRoom);
                contextMenu.customItems.push(nukeRoomItem);
            }

            _controlRooms.contextMenu = contextMenu;
        }

        private function joinRoom(room:Room, asPlayer:Boolean):void
        {
            function e_joinRoomPassword(password:String):void
            {
                _connection.joinRoom(room, asPlayer, password);
            }

            if (room.isPrivate)
                new Prompt(this, 320, "Password: " + room.name, 100, "SUBMIT", e_joinRoomPassword, true);
            else
                _connection.joinRoom(room, asPlayer);
        }

        private function updateRoomPanel(room:Room):void
        {
            if (window.parent == null)
                return;

            for each (var item:Object in _controlRooms.items)
            {
                if (item.data == room)
                {
                    item.label = nameRoom(room);
                    _controlRooms.items = _controlRooms.items;
                    break;
                }
            }
        }

        /**
         * Updates the rooms list
         */
        private function updateRooms():void
        {
            var items:Array = [];
            for each (var room:Room in _connection.rooms)
            {
                if (room.isGameRoom)
                    items.push({label: nameRoom(room), labelhtml: true, data: room});
            }
            updateWindowTitle(_connection.lobby);
            _controlRooms.items = items;
            _controlRooms.listItemClass = _controlRooms.listItemClass;
        }

        public function updateWindowTitle(room:Room):void
        {
            if (room != null)
                window.title = Multiplayer.GAME_VERSION + " " + room.name + " - Rooms: " + (_connection.rooms.length - 2) + " - Players: " + room.userCount;
        }

        private function nameRoom(room:Room):String
        {
            const level:int = room.level;
            const spectatorString:String = (room.specCount > 0) ? "+" + room.specCount + " " : "";
            const roomPopulationString:String = HtmlUtil.size(room.userCount + "/2 " + spectatorString, "-1");
            const isPrivateString:String = (room.isPrivate ? "!" : "");

            if (room.userCount > 0 && level != -1)
            {
                const color:int = GlobalVariables.getDivisionColor(level);
                const titleString:String = GlobalVariables.getDivisionTitle(level);
                const dulledColor:String = MultiplayerChat.textDullColor(color, 1).toString(16);
                const titlePrefix:String = "(" + titleString + ")";

                return roomPopulationString + HtmlUtil.color(isPrivateString + titlePrefix, "#" + dulledColor) + " " + HtmlUtil.escape(room.name);
            }

            return roomPopulationString + " " + HtmlUtil.escape(isPrivateString + room.name);
        }

        private function showButton(button:BoxButton, show:Boolean):void
        {
            if (button == null)
                return;

            if (button.parent == null && show)
                addChild(button);
            else if (button.parent == this && !show)
                removeChild(button);
        }

        public function hideBackground(show:Boolean = false):void
        {
            if (_buttonMP != null)
                _buttonMP.visible = show;
            if (_buttonDisconnect != null)
                _buttonDisconnect.visible = show;
            if (_textLogin != null)
                _textLogin.visible = show;
            if (window != null)
                window.visible = show;
        }

        private function forEachRoom(func:Function):void
        {
            for (var i:int = 0; i < numChildren; i++)
            {
                var container:Object = getChildAt(i);
                if (container is MultiplayerRoom)
                    func(container);
            }
        }

        public function setRoomsVisibility(visible:Boolean = false):void
        {
            forEachRoom(function(room:MultiplayerRoom):void
            {
                room.visible = visible;
                if (visible)
                    room.redraw();
            });
        }

        public function hideRoom(room:Room, show:Boolean = false):void
        {
            forEachRoom(function(mproom:MultiplayerRoom):void
            {
                if (mproom.room == room)
                {
                    mproom.visible = show;
                    if (show)
                        mproom.redraw();
                }
            });
        }

        public function openWindow():void
        {
            if (window.parent == null)
                closeWindow();
            window.x = 5; // Main.GAME_WIDTH / 2 - window.width / 2.6;
            window.y = 50; // Main.GAME_HEIGHT / 2 - window.height / 1.75;

            addChild(window);
            _controlChat.redraw();
            _controlChat.focus();
            _updateTimer.start();
        }

        public function closeWindow():void
        {
            if (window.parent == this)
                removeChild(window);
            _updateTimer.stop();
        }

        private function showThrobber():void
        {
            if (_throbber != null)
            {
                _throbber.visible = true;
                _throbber.start();
            }
        }

        private function hideThrobber():void
        {
            if (_throbber != null)
            {
                _throbber.visible = false;
                _throbber.stop();
            }
        }
    }
}
