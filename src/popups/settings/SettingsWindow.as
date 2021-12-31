package popups.settings
{
    import arc.ArcGlobals;
    import assets.GameBackgroundColor;
    import classes.Language;
    import classes.Room;
    import classes.SongInfo;
    import classes.User;
    import classes.chart.Song;
    import classes.ui.BoxButton;
    import classes.ui.ManageSettingsWindow;
    import classes.ui.ScrollBar;
    import classes.ui.ScrollPane;
    import classes.ui.Text;
    import classes.ui.TabButton;
    import com.bit101.components.Window;
    import com.flashfla.net.Multiplayer;
    import com.flashfla.utils.SpriteUtil;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import game.GameOptions;
    import menu.MainMenu;
    import menu.MenuPanel;
    import menu.MenuSongSelection;


    public class SettingsWindow extends MenuPanel
    {
        public var scrollbar:ScrollBar;
        public var pane:ScrollPane;

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;

        private var _user:User;

        private var _box:Sprite;
        private var _bmp:Bitmap;

        private var _tabs:Vector.<SettingsTabBase>;
        private var _tabButtons:Vector.<TabButton>;

        private var _currentTab:SettingsTabBase;
        private var _currentIndex:int = -1;
        private var _lastIndex:int = 0;

        private var _txtSettings:Text;
        private var _txtModWarning:Text;

        // buttons
        private var btnClose:BoxButton;
        private var btnManage:BoxButton;
        private var btnReset:BoxButton;

        private var btnEditorGameplay:TabButton;
        private var btnEditorMultiplayer:TabButton;
        private var btnEditorSpectator:TabButton;

        private var gameOptionsTest:GameOptions = new GameOptions(null);

        private var winManage:ManageSettingsWindow;

        public function SettingsWindow(myParent:MenuPanel, user:User)
        {
            _user = user;

            // build menus
            _tabs = new <SettingsTabBase>[new SettingsTabGeneral(this, user.settings),
                new SettingsTabInput(this, user.settings),
                new SettingsTabNoteskin(this, user.settings),
                new SettingsTabModifiers(this, user.settings),
                new SettingsTabVisuals(this, user.settings),
                new SettingsTabColors(this, user.settings),
                new SettingsTabMisc(this, user.settings)];

            _tabButtons = new <TabButton>[];

            super(myParent);
        }

        override public function stageAdd():void
        {
            stage.focus = this.stage;

            _bmp = SpriteUtil.getBitmapSprite(stage);
            addChild(_bmp);

            // background
            _box = new Sprite();
            _box.graphics.lineStyle(0, 0, 0);

            _box.graphics.beginFill(0, 0.2);
            _box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _box.graphics.endFill();

            _box.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.6);
            _box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _box.graphics.endFill();

            _box.graphics.beginFill(0xFFFFFF, 0.07);
            _box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _box.graphics.endFill();

            _box.graphics.beginFill(0x000000, 0.1);
            _box.graphics.drawRect(0, 61, 173, Main.GAME_HEIGHT - 60);
            _box.graphics.endFill();

            // dividers
            _box.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            _box.graphics.moveTo(0, 60);
            _box.graphics.lineTo(Main.GAME_WIDTH, 60);
            _box.graphics.moveTo(174, 61);
            _box.graphics.lineTo(174, Main.GAME_HEIGHT);
            _box.graphics.moveTo(Main.GAME_WIDTH - 16, 61);
            _box.graphics.lineTo(Main.GAME_WIDTH - 16, Main.GAME_HEIGHT);

            addChild(_box);

            // scroll pane
            pane = new ScrollPane(this, 175, 61, 589, Main.GAME_HEIGHT - 61);
            pane.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false, 0, false);
            scrollbar = new ScrollBar(this, Main.GAME_WIDTH - 16, 61, 16, Main.GAME_HEIGHT - 61, null, new Sprite());
            scrollbar.addEventListener(Event.CHANGE, scrollBarMoved, false, 0, false);

            // ui
            buildTabs();

            _txtSettings = new Text(_box, 15, 5, _lang.string("settings_title"), 32);

            _txtModWarning = new Text(_box, 215, 18, _lang.string("options_warning_save"), 14, "#f06868");
            _txtModWarning.setAreaParams(265, 24, "right");

            btnReset = new BoxButton(_box, 495, 15, 80, 29, _lang.string("menu_reset"), 12, clickHandler);
            btnReset.color = 0xff0000;

            btnManage = new BoxButton(_box, 590, 15, 80, 29, _lang.string("menu_manage"), 12, clickHandler);

            btnClose = new BoxButton(_box, 685, 15, 80, 29, _lang.string("menu_close"), 12, clickHandler);
            //btn_close.contextMenu = _contextImportExport;

            changeTab(_lastIndex);
        }

        override public function stageRemove():void
        {
            _currentTab.closeTab();
            scrollbar.removeEventListener(Event.CHANGE, scrollBarMoved, false);
            pane.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false);
        }

        public function buildTabs():void
        {
            var tabBox:TabButton;

            for (var idx:int = 0; idx < _tabs.length; idx++)
            {
                _tabs[idx].container = pane.content;

                tabBox = new TabButton(_box, -1, 60 + 33 * idx, idx, _lang.string("settings_tab_" + _tabs[idx].name));
                tabBox.tabIndex = idx;
                tabBox.addEventListener(MouseEvent.CLICK, tabHandler);

                _tabButtons.push(tabBox);
            }

            // editor buttons
            btnEditorGameplay = new TabButton(_box, -1, 364, -1, _lang.string("settings_tab_editor_gameplay"), true);
            btnEditorGameplay.addEventListener(MouseEvent.CLICK, clickHandler);
            btnEditorMultiplayer = new TabButton(_box, -1, 397, -1, _lang.string("settings_tab_editor_multiplayer"));
            btnEditorMultiplayer.addEventListener(MouseEvent.CLICK, clickHandler);
            btnEditorSpectator = new TabButton(_box, -1, 430, -1, _lang.string("settings_tab_editor_spectator"));
            btnEditorSpectator.addEventListener(MouseEvent.CLICK, clickHandler);

            // editor options, fake entities for filling gameplay elements
            const fakePlayer1:User = new User();
            fakePlayer1.id = 1;
            fakePlayer1.playerIdx = 1;
            fakePlayer1.isPlayer = true;
            fakePlayer1.name = "Player 1";
            fakePlayer1.siteId = 1830376;

            const fakePlayer2:User = new User();
            fakePlayer2.id = 2
            fakePlayer2.playerIdx = 2;
            fakePlayer2.isPlayer = true;
            fakePlayer2.name = "Player 2";
            fakePlayer2.siteId = 249481;

            const fakeSpectator:User = new User();
            fakeSpectator.id = 3;
            fakeSpectator.playerIdx = 3;
            fakeSpectator.isPlayer = false;
            fakeSpectator.name = "Spectator";
            fakeSpectator.siteId = 0;

            // Editor - MP
            const fakeMP1:Multiplayer = new Multiplayer();
            fakeMP1.currentUser = fakePlayer1;

            const mpEditorRoom:Room = new Room(0);
            mpEditorRoom.connection = fakeMP1;
            mpEditorRoom.addUser(fakePlayer1);
            mpEditorRoom.addUser(fakePlayer2);
            mpEditorRoom.addPlayer(fakePlayer1);
            mpEditorRoom.addPlayer(fakePlayer2);

            // Editor - MP Spectate
            const fakeMP2:Multiplayer = new Multiplayer();
            fakeMP2.currentUser = fakeSpectator;

            const mpSpectateEditorRoom:Room = new Room(0);
            mpSpectateEditorRoom.connection = fakeMP2;
            mpSpectateEditorRoom.addUser(fakePlayer1);
            mpSpectateEditorRoom.addUser(fakePlayer2);
            mpSpectateEditorRoom.addUser(fakeSpectator);
            mpSpectateEditorRoom.addPlayer(fakePlayer1);
            mpSpectateEditorRoom.addPlayer(fakePlayer2);
        }

        public function changeTab(idx:int):void
        {
            if (_currentIndex == idx)
                return;

            if (_currentTab != null)
            {
                _currentTab.closeTab();
                pane.clear();
                pane.content.graphics.clear();
            }

            _currentIndex = idx;
            _currentTab = _tabs[idx];
            _currentTab.openTab();
            _currentTab.setValues();
            _lastIndex = idx;

            pane.update();

            pane.scrollTo(0, false);
            scrollbar.scrollTo(0, false);

            scrollbar.visible = (pane.content.height > 425);

            // update buttons
            for each (var tabButton:TabButton in _tabButtons)
                tabButton.setActive(tabButton.index == idx);

            checkValidMods();
        }

        private function tabHandler(e:MouseEvent):void
        {
            changeTab((e.currentTarget as TabButton).index);
        }

        public function checkValidMods():void
        {
            gameOptionsTest.fill();
            _txtModWarning.visible = !gameOptionsTest.isScoreValid();
        }

        private function onManageSettingsWindowClosed(window:ManageSettingsWindow):void
        {
            removeChild(window);
        }

        private function clickHandler(e:MouseEvent):void
        {
            if (e.currentTarget == btnEditorGameplay || e.currentTarget == btnEditorMultiplayer || e.currentTarget == btnEditorSpectator)
            {
                _gvars.options = new GameOptions(_user);
                _gvars.options.isEditor = true;
                _gvars.options.mpRoom = e.currentTarget.editor;

                const tempSongInfo:SongInfo = new SongInfo();
                tempSongInfo.level = 1337;
                tempSongInfo.chart_type = "EDITOR";
                _gvars.options.song = new Song(tempSongInfo);

                _gvars.options.fill();
                removePopup();
                _gvars.gameMain.switchTo(Main.GAME_PLAY_PANEL);
                return;
            }

            else if (e.target == btnManage)
            {
                winManage = new ManageSettingsWindow(this.stage, onManageSettingsWindowClosed);
                addChild(winManage);
            }

            else if (e.target == btnReset)
            {
                const confirmWindow:Window = new Window(this, 0, 0, "Confirm Settings Reset");
                confirmWindow.hasMinimizeButton = false;
                confirmWindow.hasCloseButton = false;
                confirmWindow.setSize(110, 105);
                confirmWindow.x = (Main.GAME_WIDTH / 2 - confirmWindow.width / 2);
                confirmWindow.y = (Main.GAME_HEIGHT / 2 - confirmWindow.height / 2);

                function doReset(e:Event):void
                {
                    confirmWindow.parent.removeChild(confirmWindow);
                    if (_user == _gvars.playerUser)
                    {
                        _user.settings = new User().settings;
                        _avars.resetSettings();
                    }
                    changeTab(_currentIndex);
                }

                function closeReset(e:Event):void
                {
                    confirmWindow.parent.removeChild(confirmWindow);
                }

                const resB:BoxButton = new BoxButton(confirmWindow, 5, 5, 100, 35, _lang.string("menu_reset"), 12, doReset);
                resB.color = 0x330000;
                resB.textColor = "#990000";

                const conB:BoxButton = new BoxButton(confirmWindow, 5, 45, 100, 35, _lang.string("menu_close"), 12, closeReset);
                conB.color = 0;
                conB.textColor = "#000000";
            }

            else if (e.target == btnClose)
            {
                if (_user == _gvars.playerUser)
                {
                    _user.saveSettingsLocally();
                    _user.saveSettingsOnline();

                    // Setup Background Colors
                    GameBackgroundColor.BG_LIGHT = _user.settings.gameColors[0];
                    GameBackgroundColor.BG_DARK = _user.settings.gameColors[1];
                    GameBackgroundColor.BG_STATIC = _user.settings.gameColors[2];
                    GameBackgroundColor.BG_POPUP = _user.settings.gameColors[3];
                    GameBackgroundColor.BG_STAGE = _user.settings.gameColors[4];
                    (_gvars.gameMain.getChildAt(0) as GameBackgroundColor).redraw();

                    if (_gvars.gameMain.activePanel is MainMenu && ((_gvars.gameMain.activePanel as MainMenu).panel is MenuSongSelection))
                    {
                        const panel:MenuSongSelection = ((_gvars.gameMain.activePanel as MainMenu).panel as MenuSongSelection);
                        panel.buildGenreList();
                        panel.drawPages();
                    }
                }
                SoundMixer.soundTransform = new SoundTransform(_user.settings.gameVolume);
                LocalOptions.setVariable("menu_music_volume", _gvars.menuMusicSoundVolume);
                removePopup();
                return;
            }
        }

        private function mouseWheelMoved(e:MouseEvent):void
        {
            if (!scrollbar.visible)
                return;

            const dist:Number = scrollbar.scroll + (pane.scrollFactorVertical / 2) * (e.delta > 0 ? -1 : 1);
            pane.scrollTo(dist, false);
            scrollbar.scrollTo(dist, false);
        }

        private function scrollBarMoved(e:Event):void
        {
            pane.scrollTo(e.target.scroll, false);
        }
    }
}
