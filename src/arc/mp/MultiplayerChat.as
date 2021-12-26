package arc.mp
{
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
    import com.flashfla.utils.StringUtil;
    import flash.display.DisplayObjectContainer;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import classes.Room;
    import classes.User;
    import classes.Gameplay;
    import com.flashfla.utils.HtmlUtil;

    public class MultiplayerChat extends Component
    {
        public var controlChat:TextArea;
        public var controlInput:InputText;

        private var chatText:String = "";
        private var canRedraw:Boolean = true;
        private var chatScroll:Boolean = false;
        private var chatScrollV:int;
        private var chatFrameDelay:int;

        public var room:Room;
        public var connection:Multiplayer;

        public function MultiplayerChat(parent:DisplayObjectContainer, roomValue:Room)
        {
            super(parent);
            this.room = roomValue;

            connection = MultiplayerSingleton.getInstance().connection;

            setSize(400, 300);

            controlChat = new TextArea();
            controlChat.editable = false;
            controlChat.html = true;
            addChild(controlChat);

            controlInput = new InputText();
            controlInput.addEventListener(KeyboardEvent.KEY_DOWN, onInputTextKeyDown);
            addChild(controlInput);

            connection.addEventListener(Multiplayer.EVENT_SERVER_MESSAGE, onServerMessageEvent);
            connection.addEventListener(Multiplayer.EVENT_XT_RESPONSE, onExtensionResponseEvent);
            connection.addEventListener(Multiplayer.EVENT_MESSAGE, onMessageEvent);
            connection.addEventListener(Multiplayer.EVENT_ROOM_USER, onRoomUserEvent);
            connection.addEventListener(Multiplayer.EVENT_CONNECTION, onConnectionEvent);
            connection.addEventListener(Multiplayer.EVENT_LOGIN, onLoginEvent);
            connection.addEventListener(Multiplayer.EVENT_ROOM_JOINED, onRoomJoinedEvent);
            connection.addEventListener(Multiplayer.EVENT_GAME_RESULTS, onGameResultsEvent);

            GlobalVariables.instance.gameMain.addEventListener(Main.EVENT_PANEL_SWITCHED, checkRedraw);

            buildContextMenu();

            resize();
        }

        private function onInputTextKeyDown(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.ENTER)
            {
                connection.sendMessage(room, controlInput.text);
                controlInput.text = "";
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
            if (!connection.connected && !event.isSolo)
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

        private function checkRedraw(event:Event):void
        {
            canRedraw = (GlobalVariables.instance.gameMain.activePanelName == Main.GAME_MENU_PANEL);
            redraw()
        }

        public function resize():void
        {
            controlInput.move(0, height - controlInput.height);
            controlInput.setSize(width, controlInput.height);

            controlChat.move(0, 0);
            controlChat.setSize(width, controlInput.y);
        }

        public function focus():void
        {
            if (stage)
            {
                stage.focus = controlInput.textField;
                controlInput.textField.setSelection(0, 0);
            }
        }

        public function broadcastServerMsg(event:ContextMenuEvent):void
        {
            if (controlInput.text.length > 0)
                return;

            connection.sendServerMessage(controlInput.text);
            controlInput.text = "";
        }

        public function broadcastRoomMsg(event:ContextMenuEvent):void
        {
            if (controlInput.text.length > 0)
                return;

            connection.sendServerMessage(controlInput.text, room);
            controlInput.text = "";
        }

        public function broadcastHtmlMsg(event:ContextMenuEvent):void
        {
            if (controlInput.text.length > 0)
                return;

            connection.sendHTMLMessage(controlInput.text, room);
            controlInput.text = "";
        }

        public function buildContextMenu():void
        {
            if (!connection.currentUser.isModerator)
            {
                controlInput.contextMenu = controlInput.textField.contextMenu = null;
                return;
            }

            var contextMenu:ContextMenu = new ContextMenu();

            var broadcastServerItem:ContextMenuItem = new ContextMenuItem("Broadcast Server Message");
            broadcastServerItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, broadcastServerMsg);
            contextMenu.customItems.push(broadcastServerItem);

            var broadcastRoomItem:ContextMenuItem = new ContextMenuItem("Broadcast Room Message");
            broadcastRoomItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, broadcastRoomMsg);
            contextMenu.customItems.push(broadcastRoomItem);

            if (connection.currentUser.isAdmin)
            {
                var broadcastHtmlItem:ContextMenuItem = new ContextMenuItem("Send HTML");
                broadcastHtmlItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, broadcastHtmlMsg);
                contextMenu.customItems.push(broadcastHtmlItem);
            }

            contextMenu.clipboardMenu = true;
            controlInput.contextMenu = controlInput.textField.contextMenu = contextMenu;
        }

        public function textAreaAddLine(message:String):void
        {
            if (message == null)
                return;

            chatScrollV = controlChat.textField.scrollV;
            chatScroll ||= (chatScrollV == controlChat.textField.maxScrollV);
            chatFrameDelay = 0;

            chatText += (chatText.length == 0 ? "" : "\n");
            if (GlobalVariables.instance.activeUser.DISPLAY_MP_TIMESTAMP)
            {
                var date:Date = new Date();
                var hoursStr:String = (date.hours == 0 ? 12 : (date.hours > 12 ? date.hours - 12 : date.hours)).toString();
                var minutesStr:String = (date.minutes < 10 ? "0" : "") + date.minutes;
                var ampmStr:String = (date.hours < 12 ? " AM" : " PM");

                chatText += HtmlUtil.bold("[" + hoursStr + ":" + minutesStr + ampmStr + "] ");
            }
            chatText += message;
            redraw();
        }

        public function redraw(force:Boolean = false):void
        {
            if (force)
                canRedraw = true;
            if (!canRedraw)
                return;

            chatFrameDelay = 0;
            controlChat.text = HtmlUtil.font(chatText, Style.fontName);
            controlChat.draw();
            controlChat.removeEventListener(Event.ENTER_FRAME, onRedrawFrame);
            controlChat.addEventListener(Event.ENTER_FRAME, onRedrawFrame);
        }

        private function onRedrawFrame(event:Event):void
        {
            chatFrameDelay++;
            if (chatFrameDelay <= 2)
                return;

            if (chatScroll)
            {
                chatScrollV = controlChat.textField.maxScrollV;
                chatScroll = false;
            }
            controlChat.textField.scrollV = chatScrollV;
            controlChat.removeEventListener(Event.ENTER_FRAME, onRedrawFrame);
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
            if (user.variables.arc_colour != null)
                color = user.variables.arc_colour;
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
            var msgPrefix:String = "PM << " + user.name + ":";
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
