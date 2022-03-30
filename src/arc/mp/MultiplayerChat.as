package arc.mp
{
    import classes.Room;
    import classes.User;
    import classes.Gameplay;
    import com.bit101.components.Component;
    import com.bit101.components.InputText;
    import com.bit101.components.Style;
    import com.bit101.components.TextArea;
    import com.flashfla.net.Multiplayer;
    import com.flashfla.net.events.ServerMessageEvent;
    import com.flashfla.net.events.ExtensionResponseEvent;
    import com.flashfla.net.events.MessageEvent;
    import com.flashfla.net.events.RoomUserEvent;
    import com.flashfla.net.events.ConnectionEvent;
    import com.flashfla.net.events.LoginEvent;
    import com.flashfla.net.events.RoomJoinedEvent;
    import com.flashfla.net.events.GameResultsEvent;
    import com.flashfla.utils.HtmlUtil;
    import flash.display.DisplayObjectContainer;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import menu.MainMenu;

    public class MultiplayerChat extends Component
    {
        private var _controlChat:TextArea;
        private var _controlInput:InputText;

        private var _canRedraw:Boolean = true;
        private var _chatText:String = "";
        private var _chatScroll:Boolean = false;
        private var _chatScrollV:int;
        private var _chatFrameDelay:int;

        public var room:Room;
        private var _connection:Multiplayer;

        public function MultiplayerChat(parent:DisplayObjectContainer, room:Room)
        {
            super(parent);
            this.room = room;

            _connection = MultiplayerState.instance.connection;

            setSize(400, 300);

            _controlChat = new TextArea();
            _controlChat.editable = false;
            _controlChat.html = true;
            addChild(_controlChat);

            _controlInput = new InputText();
            _controlInput.addEventListener(KeyboardEvent.KEY_DOWN, onInputTextKeyDown);
            addChild(_controlInput);

            _connection.addEventListener(Multiplayer.EVENT_SERVER_MESSAGE, onServerMessageEvent);
            _connection.addEventListener(Multiplayer.EVENT_XT_RESPONSE, onExtensionResponseEvent);
            _connection.addEventListener(Multiplayer.EVENT_MESSAGE, onMessageEvent);
            _connection.addEventListener(Multiplayer.EVENT_ROOM_USER, onRoomUserEvent);
            _connection.addEventListener(Multiplayer.EVENT_CONNECTION, onConnectionEvent);
            _connection.addEventListener(Multiplayer.EVENT_LOGIN, onLoginEvent);
            _connection.addEventListener(Multiplayer.EVENT_ROOM_JOINED, onRoomJoinedEvent);
            _connection.addEventListener(Multiplayer.EVENT_GAME_RESULTS, onGameResultsEvent);

            buildContextMenu();

            resize();
        }

        private function onInputTextKeyDown(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.ENTER)
            {
                _connection.sendMessage(room, _controlInput.text);
                _controlInput.text = "";
            }
            event.stopPropagation();
        }

        private function onServerMessageEvent(event:ServerMessageEvent):void
        {
            textAreaAddLine(textFormatServerMessage(event.user, event.message));
        }

        private function onExtensionResponseEvent(event:ExtensionResponseEvent):void
        {
            var data:Object = event.data;
            if (data.rid == room && data._cmd == "html_message")
                textAreaAddLine(textFormatUserName(data.uid, ": ") + data.m);
        }

        private function onMessageEvent(event:MessageEvent):void
        {
            if (event.msgType == Multiplayer.MESSAGE_PUBLIC)
            {
                if (event.room == room)
                    textAreaAddLine(textFormatMessage(event.user, event.message));
            }
            else if (event.room == null || event.room == room)
                textAreaAddLine(textFormatPrivateMessageIn(event.user, event.message));
        }

        private function onRoomUserEvent(event:RoomUserEvent):void
        {
            // Broadcast join/left message in rooms, do not broadcast in lobby
            // Add "&& event.params.user.room != null" to omit "has left" messages
            if (room != null && room.name != "Lobby" && event.room == room)
                textAreaAddLine(textFormatUser(event.user, room.getUser(event.user.id) != null));
        }

        private function onConnectionEvent(event:ConnectionEvent):void
        {
            if (!_connection.connected && !event.isSolo)
                textAreaAddLine(textFormatDisconnect());
        }

        private function onLoginEvent(event:LoginEvent):void
        {
            buildContextMenu();
        }

        private function onRoomJoinedEvent(event:RoomJoinedEvent):void
        {
            if (event.room == room && !event.isSolo)
                textAreaAddLine(textFormatJoin(room));
        }

        private function onGameResultsEvent(event:GameResultsEvent):void
        {
            if (event.room == room)
                textAreaAddLine(textFormatGameResults(event));
        }

        public function resize():void
        {
            _controlInput.move(0, height - _controlInput.height);
            _controlInput.setSize(width, _controlInput.height);

            _controlChat.move(0, 0);
            _controlChat.setSize(width, _controlInput.y);
        }

        public function focus():void
        {
            if (stage)
            {
                stage.focus = _controlInput.textField;
                _controlInput.textField.setSelection(0, 0);
            }
        }

        public function broadcastServerMsg(event:ContextMenuEvent):void
        {
            if (_controlInput.text.length > 0)
                return;

            _connection.sendServerMessage(_controlInput.text);
            _controlInput.text = "";
        }

        public function broadcastRoomMsg(event:ContextMenuEvent):void
        {
            if (_controlInput.text.length > 0)
                return;

            _connection.sendServerMessage(_controlInput.text, room);
            _controlInput.text = "";
        }

        public function broadcastHtmlMsg(event:ContextMenuEvent):void
        {
            if (_controlInput.text.length > 0)
                return;

            _connection.sendHTMLMessage(_controlInput.text, room);
            _controlInput.text = "";
        }

        public function get inputHeight():int
        {
            return _controlInput.height;
        }

        public function buildContextMenu():void
        {
            if (!_connection.currentUser.isModerator)
            {
                _controlInput.contextMenu = _controlInput.textField.contextMenu = null;
                return;
            }

            var contextMenu:ContextMenu = new ContextMenu();

            var broadcastServerItem:ContextMenuItem = new ContextMenuItem("Broadcast Server Message");
            broadcastServerItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, broadcastServerMsg);
            contextMenu.customItems.push(broadcastServerItem);

            var broadcastRoomItem:ContextMenuItem = new ContextMenuItem("Broadcast Room Message");
            broadcastRoomItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, broadcastRoomMsg);
            contextMenu.customItems.push(broadcastRoomItem);

            if (_connection.currentUser.isAdmin)
            {
                var broadcastHtmlItem:ContextMenuItem = new ContextMenuItem("Send HTML");
                broadcastHtmlItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, broadcastHtmlMsg);
                contextMenu.customItems.push(broadcastHtmlItem);
            }

            contextMenu.clipboardMenu = true;
            _controlInput.contextMenu = _controlInput.textField.contextMenu = contextMenu;
        }

        public function textAreaAddLine(message:String):void
        {
            if (message == null)
                return;

            _chatScrollV = _controlChat.textField.scrollV;
            _chatScroll ||= (_chatScrollV == _controlChat.textField.maxScrollV);
            _chatFrameDelay = 0;

            _chatText += (_chatText.length == 0 ? "" : "\n");
            if (GlobalVariables.instance.activeUser.settings.displayMPTimestamp)
            {
                var date:Date = new Date();
                var hoursStr:String = (date.hours == 0 ? 12 : (date.hours > 12 ? date.hours - 12 : date.hours)).toString();
                var minutesStr:String = (date.minutes < 10 ? "0" : "") + date.minutes;
                var ampmStr:String = (date.hours < 12 ? " AM" : " PM");

                _chatText += HtmlUtil.bold("[" + hoursStr + ":" + minutesStr + ampmStr + "] ");
            }
            _chatText += message;
            redraw();
        }

        public function redraw(force:Boolean = false):void
        {
            if (force)
                _canRedraw = true;
            if (!_canRedraw)
                return;

            _chatFrameDelay = 0;
            _controlChat.text = HtmlUtil.font(_chatText, Style.fontName);
            _controlChat.draw();
            _controlChat.removeEventListener(Event.ENTER_FRAME, onRedrawFrame);
            _controlChat.addEventListener(Event.ENTER_FRAME, onRedrawFrame);
        }

        private function onRedrawFrame(event:Event):void
        {
            _chatFrameDelay++;
            if (_chatFrameDelay <= 2)
                return;

            if (_chatScroll)
            {
                _chatScrollV = _controlChat.textField.maxScrollV;
                _chatScroll = false;
            }
            _controlChat.textField.scrollV = _chatScrollV;
            _controlChat.removeEventListener(Event.ENTER_FRAME, onRedrawFrame);
        }

        public static function nameUser(user:User, format:Boolean = true):String
        {
            if (!user)
                return "";

            return (user.userLevel >= 0 ? textFormatLevel(user) : "") + (format ? textFormatUserName(user) : HtmlUtil.escape(user.name));
        }

        public static function textDullColor(color:int, factor:Number):int
        {
            return (int(((color & 0xFF0000) >> 16) * factor) << 16) | (int(((color & 0x00FF00) >> 8) * factor) << 8) | int((color & 0x0000FF) * factor);
        }

        public static function textFormatUserName(user:User, postfix:String = ""):String
        {
            var usercolor:int = user.userClass;
            if (!user.userColor)
                usercolor = user.userColor;
            var color:String = textDullColor(Multiplayer.COLORS[usercolor], 0.75).toString(16);
            if (user.variables.arc_color != null)
                color = user.variables.arc_color;
            var userName:String = HtmlUtil.escape(user.name) + postfix;

            return HtmlUtil.color(userName, "#" + color);
        }

        public static function textFormatLevel(user:User):String
        {
            const level:int = user.userLevel;
            const color:int = GlobalVariables.getDivisionColor(level);
            const title:String = GlobalVariables.getDivisionTitle(level);
            const dulledColor:String = textDullColor(color, 1).toString(16);

            return HtmlUtil.color("Lv." + level + " (" + title + ") ", "#" + dulledColor);
        }

        public static function textFormatServerMessage(user:User, message:String):String
        {
            var msg:String = "* Server Notice" + (user != null ? (" [" + user.name + "]") : "") + ": " + message;
            return HtmlUtil.color(HtmlUtil.bold(HtmlUtil.escape(msg)), "#901000");
        }

        public static function textFormatMessage(user:User, message:String):String
        {
            return textFormatUserName(user, ": ") + HtmlUtil.escape(message);
        }

        public static function textFormatPrivateMessageIn(user:User, message:String):String
        {
            var msgPrefix:String = "PM << " + user.name + ":";
            return HtmlUtil.bold(HtmlUtil.color(HtmlUtil.escape(msgPrefix), "#009090")) + " " + HtmlUtil.escape(message);
        }

        public static function textFormatPrivateMessageOut(user:User, message:String):String
        {
            var msgPrefix:String = "PM >> " + user.name + ":";
            return HtmlUtil.bold(HtmlUtil.color(HtmlUtil.escape(msgPrefix), "#009090")) + " " + HtmlUtil.escape(message);
        }

        public static function textFormatUser(user:User, isJoin:Boolean):String
        {
            var msg:String = "* " + nameUser(user, false) + (isJoin ? " has joined" : " has left");
            var color:String = isJoin ? "#009000" : "#900000";
            return HtmlUtil.bold(HtmlUtil.color(msg, color));
        }

        public static function textFormatJoin(room:Room):String
        {
            return HtmlUtil.color("* Joined " + HtmlUtil.escape(room.name), "#009000");
        }

        public static function textFormatDisconnect():String
        {
            return HtmlUtil.color("* Disconnected", "#900000");
        }

        public static function textFormatModeratorMute(user:User, minutes:int):String
        {
            var msg:String = "* " + nameUser(user, false) + " has been muted for " + minutes + " minutes.";
            return HtmlUtil.bold(HtmlUtil.color(msg, "#901000"));
        }

        public static function textFormatModeratorBan(user:User, minutes:int):String
        {
            var msg:String = "* " + nameUser(user, false) + " has been banned for " + minutes + " minutes.";
            return HtmlUtil.bold(HtmlUtil.color(msg, "#901000"));
        }

        public static function textFormatGameResults(event:GameResultsEvent):String
        {
            var room:Room = event.room;

            if (room == null)
                return null;

            if (event.initialPlayerCount <= 1)
                return null;

            var p1:User = room.getPlayer(1);
            var p2:User = room.getPlayer(2);

            // Player 1 or 2 missing
            if (!p1 && p2)
                return textFormatGameResultsSingle(room, 2);
            if (p1 && !p2)
                return textFormatGameResultsSingle(room, 1);

            // Compare scores
            var gameplayP1:Gameplay = p1.gameplay;
            var gameplayP2:Gameplay = p2.gameplay;

            var pa:Function = function(gameplay:Gameplay):String
            {
                return (gameplay.amazing + gameplay.perfect) + "-" + gameplay.good + "-" + gameplay.average + "-" + gameplay.miss + "-" + gameplay.boo + "-" + gameplay.maxCombo;
            }

            var winner:User = (gameplayP1.score > gameplayP2.score ? p1 : p2);
            var loser:User = (gameplayP1.score > gameplayP2.score ? p2 : p1);
            var isTie:Boolean = (gameplayP1.score == gameplayP2.score);

            var winnertext:String = winner.name + " (" + winner.gameplay.score + " " + pa(winner.gameplay) + ")";
            var losertext:String = loser.name + " (" + loser.gameplay.score + " " + pa(loser.gameplay) + ")";
            var songname:String = MultiplayerPlayer.nameSong(gameplayP1);

            var resultMsg:String = "* " + songname + ": " + winnertext + (isTie ? " tied with " : " won against ") + losertext;
            return HtmlUtil.size(HtmlUtil.bold(HtmlUtil.color(HtmlUtil.escape(resultMsg), "#189018")), "-2");
        }

        public static function textFormatGameResultsSingle(room:Room, playerIndex:Number):String
        {
            var player:User = room.getPlayer(playerIndex);
            var msg:String = "* Player has left, " + player.name + " has won.";

            return HtmlUtil.size(HtmlUtil.bold(HtmlUtil.color(HtmlUtil.escape(msg), "#189018")), "-2");
        }
    }
}
