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
    import flash.text.TextFormatAlign;
    import menu.MainMenu;
    import menu.DisplayLayer;
    import menu.MenuSongSelection;
    import events.navigation.popups.RemovePopupEvent;
    import events.navigation.ChangePanelEvent;
    import events.navigation.OpenEditorEvent;


    public class SettingsWindow extends DisplayLayer
    {
        public var pane:ScrollPane;

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;

        private var _scrollbar:ScrollBar;

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

        private var _btnClose:BoxButton;
        private var _btnManage:BoxButton;
        private var _btnReset:BoxButton;

        private var _btnEditorGameplay:TabButton;
        private var _btnEditorMultiplayer:TabButton;
        private var _btnEditorSpectator:TabButton;

        private var _editorFakeDataCreated:Boolean = false;
        private var _fakePlayer1:User;
        private var _fakePlayer2:User;
        private var _fakeSpectator:User;
        private var _fakeMP1:Multiplayer;
        private var _fakeMPRoom1:Room;
        private var _fakeMP2:Multiplayer;
        private var _fakeMPRoom2:Room;

        private var _windowManage:ManageSettingsWindow;

        public function SettingsWindow(user:User)
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

            super();
        }

        override public function stageAdd():void
        {
            stage.focus = stage;

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
            _scrollbar = new ScrollBar(this, Main.GAME_WIDTH - 16, 61, 16, Main.GAME_HEIGHT - 61, null, new Sprite());
            _scrollbar.addEventListener(Event.CHANGE, scrollBarMoved, false, 0, false);

            // ui
            buildTabs();

            _txtSettings = new Text(_box, 15, 5, Lang.SETTINGS_TITLE, 32);

            _txtModWarning = new Text(_box, 215, 18, _lang.string(Lang.OPTIONS_WARNING_SAVE), 14, "#f06868");
            _txtModWarning.setAreaParams(265, 24, TextFormatAlign.RIGHT);

            _btnReset = new BoxButton(_box, 495, 15, 80, 29, _lang.string(Lang.MENU_RESET), 12, onResetSettingsClicked);
            _btnReset.color = 0xff0000;

            _btnManage = new BoxButton(_box, 590, 15, 80, 29, _lang.string(Lang.MENU_MANAGE), 12, onManageSettingsClicked);

            _btnClose = new BoxButton(_box, 685, 15, 80, 29, _lang.string(Lang.MENU_CLOSE), 12, onCloseClicked);

            changeTab(_lastIndex);
        }

        public function buildTabs():void
        {
            var tabBox:TabButton;

            for (var idx:int = 0; idx < _tabs.length; idx++)
            {
                _tabs[idx].container = pane.content;

                tabBox = new TabButton(_box, -1, 60 + 33 * idx, idx, _lang.string(Lang.SETTINGS_TAB_PREFIX + _tabs[idx].name));
                tabBox.tabIndex = idx;
                tabBox.addEventListener(MouseEvent.CLICK, onTabClicked);

                _tabButtons.push(tabBox);
            }

            // editor buttons
            _btnEditorGameplay = new TabButton(_box, -1, 364, -1, _lang.string(Lang.SETTINGS_TAB_EDITOR_GAMEPLAY), true);
            _btnEditorGameplay.addEventListener(MouseEvent.CLICK, onSoloEditorTabClicked);
            _btnEditorMultiplayer = new TabButton(_box, -1, 397, -1, _lang.string(Lang.SETTINGS_TAB_EDITOR_MULTIPLAYER));
            _btnEditorMultiplayer.addEventListener(MouseEvent.CLICK, onMPEditorTabClicked);
            _btnEditorSpectator = new TabButton(_box, -1, 430, -1, _lang.string(Lang.SETTINGS_TAB_EDITOR_SPECTATOR));
            _btnEditorSpectator.addEventListener(MouseEvent.CLICK, onMPSpectatorEditorTabClicked);
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
            _scrollbar.scrollTo(0, false);

            _scrollbar.visible = (pane.content.height > 425);

            // update buttons
            for each (var tabButton:TabButton in _tabButtons)
                tabButton.setActive(tabButton.index == idx);

            checkValidMods();
        }

        private function onTabClicked(e:MouseEvent):void
        {
            changeTab((e.currentTarget as TabButton).index);
        }

        public function checkValidMods():void
        {
            // TODO: Refactor the score validation somewhere
            //_txtModWarning.visible = !_user.settings.isScoreValid();
        }

        private function onManageSettingsWindowClosed(window:ManageSettingsWindow):void
        {
            removeChild(window);
        }

        private function onResetSettingsClicked(e:Event):void
        {
            const confirmWindow:Window = new Window(this, 0, 0, "Confirm Settings Reset");
            confirmWindow.hasMinimizeButton = false;
            confirmWindow.hasCloseButton = false;
            confirmWindow.setSize(110, 105);
            confirmWindow.x = (Main.GAME_WIDTH / 2 - confirmWindow.width / 2);
            confirmWindow.y = (Main.GAME_HEIGHT / 2 - confirmWindow.height / 2);

            function onConfirmResetClicked(e:Event):void
            {
                confirmWindow.parent.removeChild(confirmWindow);
                if (_user == _gvars.playerUser)
                {
                    _user.settings = new User().settings;
                    _avars.resetSettings();
                }
                changeTab(_currentIndex);
            }

            function onCancelResetClicked(e:Event):void
            {
                confirmWindow.parent.removeChild(confirmWindow);
            }

            const confirmBtn:BoxButton = new BoxButton(confirmWindow, 5, 5, 100, 35, _lang.string(Lang.MENU_RESET), 12, onConfirmResetClicked);
            confirmBtn.color = 0x330000;
            confirmBtn.textColor = "#990000";

            const cancelBtn:BoxButton = new BoxButton(confirmWindow, 5, 45, 100, 35, _lang.string(Lang.MENU_CLOSE), 12, onCancelResetClicked);
            cancelBtn.color = 0;
            cancelBtn.textColor = "#000000";
        }

        private function onSoloEditorTabClicked(e:Event):void
        {
            openEditor();
        }

        private function onMPEditorTabClicked(e:Event):void
        {
            openEditor();
        }

        private function onMPSpectatorEditorTabClicked(e:Event):void
        {
            openEditor();
        }

        private function openEditor():void
        {
            const tempSongInfo:SongInfo = new SongInfo();
            tempSongInfo.level = 1337;
            tempSongInfo.chart_type = "EDITOR";
            var song:Song = new Song(tempSongInfo, false, _user.settings);

            dispatchEvent(new OpenEditorEvent(song, _user));
        }

        private function onManageSettingsClicked(e:Event):void
        {
            _windowManage = new ManageSettingsWindow(this.stage, onManageSettingsWindowClosed);
            addChild(_windowManage);
        }

        private function onCloseClicked(e:Event):void
        {
            if (_user == _gvars.playerUser)
            {
                _user.saveSettingsLocally();
                _user.saveSettingsOnline(_gvars.userSession);

                // Setup Background Colors
                GameBackgroundColor.BG_LIGHT = _user.settings.gameColors[0];
                GameBackgroundColor.BG_DARK = _user.settings.gameColors[1];
                GameBackgroundColor.BG_STATIC = _user.settings.gameColors[2];
                GameBackgroundColor.BG_POPUP = _user.settings.gameColors[3];
                GameBackgroundColor.BG_STAGE = _user.settings.gameColors[4];
                _gvars.gameMain.redrawBackground();

                if (_gvars.gameMain.navigator.activePanel is MainMenu && ((_gvars.gameMain.navigator.activePanel as MainMenu).currentPanel is MenuSongSelection))
                {
                    const panel:MenuSongSelection = ((_gvars.gameMain.navigator.activePanel as MainMenu).currentPanel as MenuSongSelection);
                    panel.buildGenreList();
                    panel.drawPages();
                }
            }

            SoundMixer.soundTransform = new SoundTransform(_user.settings.gameVolume);
            LocalOptions.setVariable("menu_music_volume", _gvars.menuMusicSoundVolume);

            _currentTab.closeTab();
            _scrollbar.removeEventListener(Event.CHANGE, scrollBarMoved, false);
            pane.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelMoved, false);

            dispose();
            dispatchEvent(new RemovePopupEvent());
        }

        private function mouseWheelMoved(e:MouseEvent):void
        {
            if (!_scrollbar.visible)
                return;

            const dist:Number = _scrollbar.scroll + (pane.scrollFactorVertical / 2) * (e.delta > 0 ? -1 : 1);
            pane.scrollTo(dist, false);
            _scrollbar.scrollTo(dist, false);
        }

        private function scrollBarMoved(e:Event):void
        {
            pane.scrollTo(e.target.scroll, false);
        }
    }
}
