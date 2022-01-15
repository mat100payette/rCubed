package menu
{
    import arc.ArcGlobals;
    import arc.mp.MultiplayerPanel;
    import arc.mp.MultiplayerState;
    import assets.GameBackgroundColor;
    import assets.menu.Logo;
    import assets.menu.MainMenuBackground;
    import assets.menu.icons.fa.iconDelete;
    import assets.menu.icons.fa.iconPause;
    import assets.menu.icons.fa.iconPlay;
    import assets.menu.icons.fa.iconStop;
    import classes.Alert;
    import classes.Language;
    import classes.ui.Box;
    import classes.ui.BoxIcon;
    import classes.ui.IconUtil;
    import classes.ui.MouseTooltip;
    import classes.ui.SimpleBoxButton;
    import classes.ui.Text;
    import classes.ui.Throbber;
    import com.flashfla.net.WebRequest;
    import com.flashfla.utils.NumberUtil;
    import com.flashfla.utils.sprintf;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.text.TextFormatAlign;
    import events.navigation.popups.AddPopupSkillRankUpdateEvent;
    import events.navigation.popups.AddPopupEvent;
    import classes.ui.BoxButton;
    import events.navigation.ChangePanelEvent;

    public class MainMenu extends DisplayLayer
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        public var _layerSongSelection:DisplayLayer;
        private var _layerMultiplayer:DisplayLayer;
        private var _layerTokens:DisplayLayer;

        private var hover_message:MouseTooltip;
        private var userText:Text;
        private var menuItemBox:Sprite;
        private var logo:Logo;

        public var menuMusicControls:Box;
        private const mmc_icons:Array = [new iconPlay(), new iconPause(), new iconStop(), new iconDelete()];
        private const mmc_functions:Array = [playMusic, pauseMusic, stopMusic, deleteMusic];
        private var mmc_buttons:Array = [];
        private const mmc_strings:Array = ["play", "pause", "stop", "remove"];

        private var statUpdaterBtn:SimpleBoxButton;
        private var rankUpdateThrobber:Throbber;

        public var currentPanel:DisplayLayer;

        ///- Constructor
        public function MainMenu()
        {
            super();

            ArcGlobals.instance.resetConfig();
            init();
        }

        public function init():void
        {
            //- Add Logo
            logo = new Logo();
            logo.x = 18 + logo.width * 0.5;
            logo.y = 8 + logo.height * 0.5;
            logo.visible = LocalOptions.getVariable("menu_show_logo", true);
            addChild(logo);

            //- Add Menu Background
            var menu_bg:MainMenuBackground = new MainMenuBackground();
            menu_bg.x = 145;
            menu_bg.visible = LocalOptions.getVariable("menu_show_menu_background", true);
            addChild(menu_bg);

            //- Add Menu to Stage
            buildMenuItems();

            for (var i:int = 0; i < mmc_strings.length; ++i)
            {
                var menu_music_button:BoxIcon = new BoxIcon(null, 5 + 30 * i, 5, 25, 25, mmc_icons[i], mmc_functions[i]);
                mmc_buttons[i] = menu_music_button;
            }

            //- Add Menu Music to Stage
            if (_gvars.menuMusic)
            {
                drawMenuMusicControls();
                if (!_gvars.menuMusic.isPlaying && !_gvars.menuMusic.userStopped)
                {
                    _gvars.menuMusic.start();
                }
            }

            MultiplayerState.instance.gameplayCleanup();

            //- Add Main Panel to Stage

            // Guests
            if (GlobalVariables.instance.activeUser.isGuest)
                setActiveLayer(Routes.PANEL_SONGSELECTION);
            else
            {
                if (!Flags.VALUES[Flags.STARTUP_SCREEN])
                {
                    var playerStartup:int = _gvars.activeUser.settings.startUpScreen;
                    Flags.VALUES[Flags.STARTUP_SCREEN] = true;

                    if (playerStartup == 0)
                        setActiveLayer(Routes.PANEL_MULTIPLAYER);
                    else
                        setActiveLayer(Routes.PANEL_SONGSELECTION);
                }
                else
                    setActiveLayer(Routes.PANEL_MULTIPLAYER);
            }
        }

        public function setActiveLayer(panelName:String):void
        {
            var newPanel:DisplayLayer;

            switch (panelName)
            {
                case Routes.PANEL_SONGSELECTION:
                    if (_layerSongSelection == null)
                        _layerSongSelection = new MenuSongSelection();
                    newPanel = _layerSongSelection;
                    break;

                case Routes.PANEL_MULTIPLAYER:
                    newPanel = MultiplayerState.instance.getPanel();
                    break;

                case Routes.PANEL_TOKENS:
                    if (_layerTokens == null)
                        _layerTokens = new MenuTokens();
                    newPanel = _layerTokens;
                    break;
            }

            if (currentPanel != null && currentPanel != newPanel)
                removeChild(currentPanel);

            if (newPanel != null)
            {
                currentPanel = newPanel;
                addChild(currentPanel);
            }
        }

        public function buildMenuItems():void
        {
            if (menuItemBox != null)
            {
                removeChild(menuItemBox);
                menuItemBox = null;

                removeChild(userText);
                userText = null;
            }

            //- User Info Display
            _gvars.activeUser.updateAverageRank(_gvars.TOTAL_PUBLIC_SONGS);
            userText = new Text(this, 153, 452, sprintf(_lang.string("main_menu_userbar"), {"player_name": _gvars.activeUser.name,
                    "games_played": NumberUtil.numberFormat(_gvars.activeUser.gamesPlayed),
                    "grand_total": NumberUtil.numberFormat(_gvars.activeUser.grandTotal),
                    "rank": NumberUtil.numberFormat(_gvars.activeUser.gameRank),
                    "skill_level": _gvars.activeUser.skillLevel,
                    "skill_rating": NumberUtil.numberFormat(_gvars.activeUser.skillRating, 2),
                    "avg_rank": NumberUtil.numberFormat(_gvars.activeUser.averageRank, 3, true)}));
            userText.width = 594;
            userText.height = 28;
            userText.align = TextFormatAlign.CENTER;

            if (!_gvars.activeUser.isGuest)
            {
                statUpdaterBtn = new SimpleBoxButton(609, 28);
                statUpdaterBtn.x = 147;
                statUpdaterBtn.y = Main.GAME_HEIGHT - 28;
                statUpdaterBtn.addEventListener(MouseEvent.MOUSE_OVER, e_statUpdaterMouseOver);
                statUpdaterBtn.addEventListener(MouseEvent.CLICK, e_statUpdaterClick);
                this.addChild(statUpdaterBtn);
            }

            menuItemBox = new Sprite();
            menuItemBox.x = 145;
            menuItemBox.y = 8;

            //- Add Menu Buttons
            var i:int;
            var btnXOffset:int = 0;

            const BTN_HEIGHT:int = 28;
            const ICON_BTN_WIDTH:int = 28;
            const BTN_SPACING:int = 6;

            // Change these two accordingly
            const ICON_BTN_COUNT:int = 2;
            const VARIABLE_BTN_COUNT:int = 4;

            const TOTAL_BTN_COUNT:int = ICON_BTN_COUNT + VARIABLE_BTN_COUNT;
            const VARIABLE_BTN_WIDTH:int = Math.floor((604 - ((TOTAL_BTN_COUNT - VARIABLE_BTN_COUNT) * ICON_BTN_WIDTH) - (BTN_SPACING * (TOTAL_BTN_COUNT - 1))) / VARIABLE_BTN_COUNT);

            function addMenuVariableButton(active:Boolean, localStringName:String, clickCallback:Function):BoxButton
            {
                var button:BoxButton = new BoxButton(null, menuItemBox.x + btnXOffset, menuItemBox.y, VARIABLE_BTN_WIDTH, BTN_HEIGHT, _lang.string(localStringName), 12, clickCallback);
                button.active = active;

                addChild(button);
                button.draw();

                btnXOffset += button.width + BTN_SPACING;

                return button;
            }

            function addMenuIconButton(active:Boolean, localStringName:String, iconName:String, clickCallback:Function):BoxIcon
            {
                var button:BoxIcon = new BoxIcon(null, menuItemBox.x + btnXOffset, menuItemBox.y, ICON_BTN_WIDTH, BTN_HEIGHT, IconUtil.getIcon(iconName), clickCallback);
                button.setIconColor("#DDDDDD");
                button.setHoverText(_lang.string(localStringName), "bottom");
                button.active = active;

                addChild(button);
                button.draw();

                btnXOffset += ICON_BTN_WIDTH + BTN_SPACING;

                return button;
            }

            addMenuVariableButton(true, "menu_play", onSongSelectionButtonClick);
            addMenuVariableButton(false, "menu_multiplayer", onMultiplayerButtonClick);
            addMenuVariableButton(false, "menu_tokens", onTokensButtonClick);
            var btnFilters:BoxIcon = addMenuIconButton(false, "menu_filters", "iconFilter", onFiltersButtonClick);
            addMenuIconButton(false, "menu_replays", "iconVideo", onReplaysButtonClick);
            addMenuVariableButton(false, "menu_options", onOptionsButtonClick);

            if (_gvars.activeFilter != null)
            {
                btnFilters.setIconColor("#61ED42");
                btnFilters.color = 0x61ED42;
                btnFilters.borderColor = 0x61ED42;
            }
        }

        private function onSongSelectionButtonClick(e:Event):void
        {
            dispatchEvent(new ChangePanelEvent(Routes.PANEL_SONGSELECTION));
        }

        private function onMultiplayerButtonClick(e:Event):void
        {
            dispatchEvent(new ChangePanelEvent(Routes.PANEL_MULTIPLAYER));
        }

        private function onTokensButtonClick(e:Event):void
        {
            dispatchEvent(new ChangePanelEvent(Routes.PANEL_TOKENS));
        }

        private function onOptionsButtonClick(e:Event):void
        {
            dispatchEvent(new AddPopupEvent(Routes.POPUP_OPTIONS));
        }

        private function onFiltersButtonClick(e:Event):void
        {
            dispatchEvent(new AddPopupEvent(Routes.POPUP_FILTER_MANAGER));
        }

        private function onReplaysButtonClick(e:Event):void
        {
            dispatchEvent(new AddPopupEvent(Routes.POPUP_REPLAY_HISTORY));
        }

        public function drawMenuMusicControls():void
        {
            if (!menuMusicControls)
            {
                menuMusicControls = new Box(null, 7, -1, false, false);
                menuMusicControls.setSize(125, 35);
                menuMusicControls.normalAlpha = 1;
                menuMusicControls.color = GameBackgroundColor.BG_STATIC;

                for (var i:int = 0; i < mmc_strings.length; ++i)
                {
                    menuMusicControls.addChildAt(mmc_buttons[i], i);
                }

                updateMenuMusicControls();
            }

            if (!contains(menuMusicControls))
                addChild(menuMusicControls);
        }

        public function updateMenuMusicControls():void
        {
            if (menuMusicControls)
            {
                for (var i:int = 0; i < mmc_strings.length; ++i)
                {
                    (menuMusicControls.getChildAt(i) as BoxIcon).setHoverText(_lang.string("main_menu_music_" + mmc_strings[i]), "bottom");
                }

                buildMenuMusicControlsContextMenu();
            }
        }

        private function buildMenuMusicControlsContextMenu():void
        {
            // Context Menu Display song Playing
            var musicContextMenu:ContextMenu = new ContextMenu();
            var musicContextMenuPlaying:ContextMenuItem = new ContextMenuItem(sprintf(_lang.stringSimple("main_menu_now_playing"), {"music_name": LocalStore.getVariable("menu_music", "Unknown")}), false, false);
            musicContextMenu.customItems.push(musicContextMenuPlaying);
            menuMusicControls.contextMenu = musicContextMenu;
        }

        private function playMusic(e:Event):void
        {
            if (_gvars.menuMusic && !_gvars.menuMusic.isPlaying)
            {
                _gvars.menuMusic.userStart();
            }
        }

        private function pauseMusic(e:Event):void
        {
            if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
            {
                _gvars.menuMusic.userPause();
            }
        }

        private function stopMusic(e:Event):void
        {
            if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
            {
                _gvars.menuMusic.userStop();
            }
        }

        private function deleteMusic(e:Event):void
        {
            if (_gvars.menuMusic)
            {
                _gvars.menuMusic.userStop();
                _gvars.menuMusic = null;
                menuMusicControls.parent.removeChild(menuMusicControls);

                AirContext.deleteFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH));
            }
        }

        private function e_statUpdaterMouseOver(e:Event):void
        {
            statUpdaterBtn.addEventListener(MouseEvent.MOUSE_OUT, e_statUpdaterMouseOut);
            displayToolTip(statUpdaterBtn.x + (statUpdaterBtn.width / 2), statUpdaterBtn.y - 25, _lang.string("menu_update_stat_over"));
        }

        private function e_statUpdaterMouseOut(e:Event):void
        {
            statUpdaterBtn.removeEventListener(MouseEvent.MOUSE_OUT, e_statUpdaterMouseOut);
            removeChild(hover_message);
        }

        private function displayToolTip(tx:Number, ty:Number, text:String, align:String = TextFormatAlign.CENTER):void
        {
            if (!hover_message)
                hover_message = new MouseTooltip("", 500)
            hover_message.message = text;

            switch (align)
            {
                default:
                case TextFormatAlign.LEFT:
                    hover_message.x = tx;
                    hover_message.y = ty;
                    break;
                case TextFormatAlign.RIGHT:
                    hover_message.x = tx - hover_message.width;
                    hover_message.y = ty;
                    break;
                case TextFormatAlign.CENTER:
                    hover_message.x = tx - (hover_message.width / 2);
                    hover_message.y = ty;
                    break;
            }

            addChild(hover_message);
        }

        private function e_statUpdaterClick(e:MouseEvent):void
        {
            if (!rankUpdateThrobber)
            {
                rankUpdateThrobber = new Throbber(16, 16, 2);
                rankUpdateThrobber.x = Main.GAME_WIDTH - 48;
                rankUpdateThrobber.y = Main.GAME_HEIGHT - 22;
                rankUpdateThrobber.visible = false;
                this.addChild(rankUpdateThrobber);
            }
            if (rankUpdateThrobber.running)
                return;

            var wr:WebRequest = new WebRequest(Constant.USER_RANKS_UPDATE_URL, c_rankComplete, c_rankFail);
            wr.load({"session": _gvars.userSession});
            rankUpdateThrobber.visible = true;
            rankUpdateThrobber.start();

            function c_rankComplete(e:* = null):void
            {
                var resp:Object = JSON.parse(e.target.data);
                if (_gvars.gameMain.navigator.activePanel is MainMenu)
                {
                    dispatchEvent(new AddPopupSkillRankUpdateEvent(resp));

                    rankUpdateThrobber.stop();
                    rankUpdateThrobber.visible = false;
                }
            }

            function c_rankFail(e:*):void
            {
                Alert.add(_lang.string("skill_rank_update_fail"), 90, Alert.RED);
                if (_gvars.gameMain.navigator.activePanel is MainMenu)
                {
                    rankUpdateThrobber.stop();
                    rankUpdateThrobber.visible = false;
                }
            }
        }
    }
}
