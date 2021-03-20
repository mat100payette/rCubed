package arc.mp
{
    import com.bit101.components.Label;
    import com.bit101.components.Panel;
    import com.flashfla.net.Multiplayer;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import com.flashfla.net.events.RoomUpdateEvent;
    import com.flashfla.net.events.RoomUserEvent;
    import com.flashfla.net.events.RoomUserStatusEvent;
    import classes.Room;
    import classes.User;

    public class MultiplayerPlayer extends Panel
    {
        private var connection:Multiplayer;
        public var room:Room;
        public var playerIdx:int;

        private var playerLabel:Label;
        private var songLabel:Label;
        private var statusLabel:Label;
        private var scoreLabel:Label;
        private var paLabel:Label;
        private var comboLabel:Label;
        private var canRedraw:Boolean = true;

        public function MultiplayerPlayer(parent:DisplayObjectContainer, roomValue:Room, playerValue:int)
        {
            super(parent);

            var self:MultiplayerPlayer = this

            room = roomValue;
            playerIdx = playerValue;

            connection = room.connection;

            playerLabel = new Label(content, 0, 0, "Player " + playerIdx + ": ");
            songLabel = new Label(content, 0, playerLabel.y + playerLabel.height - 4, "Song: ");
            statusLabel = new Label(content, 0, songLabel.y + songLabel.height - 4, "Song: ");
            scoreLabel = new Label(content, 0, statusLabel.y + statusLabel.height - 4, "Score: ");
            paLabel = new Label(content, 0, scoreLabel.y + scoreLabel.height - 4, "PA: ");
            comboLabel = new Label(content, 0, paLabel.y + paLabel.height - 4, "Combo: ");

            songLabel.mouseEnabled = true;
            songLabel.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
            {
                var user:User = room.getPlayer(playerIdx);

                if (user)
                {
                    var gameplay:Object = user.gameplay;
                    if (gameplay != null)
                        MultiplayerSingleton.getInstance().gameplayPick(gameplay.song);
                }
            });

            height = comboLabel.y + comboLabel.height;
            width = 150;

            connection.addEventListener(Multiplayer.EVENT_ROOM_UPDATE, function(event:RoomUpdateEvent):void
            {
                if (event.room == self.room)
                    redraw();
            });
            connection.addEventListener(Multiplayer.EVENT_ROOM_USER, function(event:RoomUserEvent):void
            {
                if (event.room == self.room)
                    redraw();
            });
            connection.addEventListener(Multiplayer.EVENT_ROOM_USER_STATUS, function(event:RoomUserStatusEvent):void
            {
                if (event.room == self.room)
                    redraw();
            });

            GlobalVariables.instance.gameMain.addEventListener(Main.EVENT_PANEL_SWITCHED, checkRedraw);

            redraw();
        }

        private function checkRedraw(event:Event):void
        {
            canRedraw = (GlobalVariables.instance.gameMain.activePanelName == Main.GAME_MENU_PANEL);
            redraw()
        }

        public function redraw(force:Boolean = false):void
        {
            if (force)
                canRedraw = true;

            if (!canRedraw)
                return;

            var user:User = null;
            for each (var roomUser:User in room.users)
            {
                if (roomUser.playerIdx == playerIdx)
                {
                    user = roomUser;
                    break;
                }
            }

            var gameplay:Object;
            if (user)
                gameplay = user.gameplay;

            if (!gameplay)
            {
                playerLabel.text = "";
                songLabel.text = "";
                statusLabel.text = "Status: Waiting for Player";
                scoreLabel.text = "";
                paLabel.text = "";
                comboLabel.text = "";
                songLabel.buttonMode = false;
                songLabel.useHandCursor = false;
            }
            else
            {
                songLabel.text = "Song: " + nameSong(gameplay);
                songLabel.buttonMode = true;
                songLabel.useHandCursor = true;

                statusLabel.text = "Status: "
                switch (gameplay.status)
                {
                    case Multiplayer.STATUS_NONE:
                    case Multiplayer.STATUS_CLEANUP:
                        statusLabel.text += "None";
                        break;
                    case Multiplayer.STATUS_PLAYING:
                        statusLabel.text += "Playing";
                        break;
                    case Multiplayer.STATUS_PICKING:
                        statusLabel.text += "Selecting";
                        break;
                    case Multiplayer.STATUS_LOADING:
                        statusLabel.text += "Loading";
                        if (gameplay.statusLoading > 0)
                            statusLabel.text += " (" + gameplay.statusLoading + "%)";
                        break;
                    case Multiplayer.STATUS_LOADED:
                        statusLabel.text += "Loaded";
                        break;
                    case Multiplayer.STATUS_RESULTS:
                        statusLabel.text += "Results";
                        break;
                }


                playerLabel.html = true;
                playerLabel.text = MultiplayerChat.textFormatLevel(user) + user.name;
                scoreLabel.text = "Score: " + gameplay.score;
                paLabel.text = "PA: " + (gameplay.amazing + gameplay.perfect) + " - " + gameplay.good + " - " + gameplay.average + " - " + gameplay.miss + " - " + gameplay.boo;
                comboLabel.text = "Combo: " + gameplay.combo + " / " + gameplay.maxCombo;
            }
        }

        public static function nameSong(gameplay:Object):String
        {
            if (gameplay.song)
                return gameplay.song.name;

            return "No Song Selected";
        }
    }
}
