package popups.replays
{
    import arc.ArcGlobals;
    import assets.GameBackgroundColor;
    import assets.menu.icons.fa.iconSearch;
    import classes.Alert;
    import classes.Language;
    import classes.replay.Replay;
    import classes.ui.BoxButton;
    import classes.ui.BoxText;
    import classes.ui.ScrollBar;
    import classes.ui.SimpleBoxButton;
    import classes.ui.Text;
    import com.flashfla.utils.SpriteUtil;
    import com.flashfla.utils.SystemUtil;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import menu.DisplayLayer;
    import flash.text.TextFormatAlign;
    import events.navigation.popups.RemovePopupEvent;
    import events.navigation.WatchReplayEvent;

    public class ReplayHistoryWindow extends DisplayLayer
    {
        private var _lang:Language = Language.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;

        private var _box:Sprite;
        private var _bmp:Bitmap;

        private var _scrollbar:ScrollBar;
        public var pane:ReplayHistoryScrollpane;

        private var _tabs:Vector.<ReplayHistoryTabBase>;

        private var _currentTab:ReplayHistoryTabBase;
        private var _currentTabIndex:int = -1;
        private var _previousTabIndex:int = 0;

        private var _tabButtons:Vector.<TabButton>;

        private var _txtTitle:Text;
        private var _txtModWarning:Text;

        private var _searchField:BoxText;
        private var _searchFieldPlaceholder:Text;
        private var _searchText:String = "";

        private var _btnClose:BoxButton;

        public function ReplayHistoryWindow():void
        {
            // build menus
            _tabs = new <ReplayHistoryTabBase>[new ReplayHistoryTabSession(this),
                new ReplayHistoryTabLocal(this)];

            if (!_gvars.activeUser.isGuest)
                _tabs.push(new ReplayHistoryTabOnline(this));

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
            _box.graphics.moveTo(670, 0);
            _box.graphics.lineTo(670, 60);
            _box.graphics.moveTo(0, 60);
            _box.graphics.lineTo(Main.GAME_WIDTH, 60);
            _box.graphics.moveTo(174, 61);
            _box.graphics.lineTo(174, Main.GAME_HEIGHT);
            _box.graphics.moveTo(Main.GAME_WIDTH - 16, 61);
            _box.graphics.lineTo(Main.GAME_WIDTH - 16, Main.GAME_HEIGHT);

            addChild(_box);

            // scroll pane
            pane = new ReplayHistoryScrollpane(this, 180, 61, 584, Main.GAME_HEIGHT - 61);
            pane.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelMoved, false, 0, false);
            pane.addEventListener(MouseEvent.CLICK, onReplayEntryClicked);
            _scrollbar = new ScrollBar(this, Main.GAME_WIDTH - 16, 61, 16, Main.GAME_HEIGHT - 61, null, new Sprite());
            _scrollbar.addEventListener(Event.CHANGE, onScrollBarMoved, false, 0, false);

            // ui
            buildTabs();

            _txtTitle = new Text(_box, 15, 5, _lang.string("replay_history_title"), 32);

            // Search
            _searchFieldPlaceholder = new Text(_box, 405, 17, _lang.string("replay_search"));
            _searchFieldPlaceholder.setAreaParams(210, 27, TextFormatAlign.LEFT);
            _searchFieldPlaceholder.alpha = 0.6;

            _searchField = new BoxText(_box, 400, 15, 220, 29);
            _searchField.addEventListener(Event.CHANGE, onSearchChanged, false, 0, true);

            var searchSprite:Sprite = new iconSearch();
            searchSprite.x = 644;
            searchSprite.y = 31;
            searchSprite.scaleX = searchSprite.scaleY = 0.25;
            searchSprite.alpha = 0.8;
            _box.addChild(searchSprite);

            _btnClose = new BoxButton(_box, 685, 15, 80, 29, _lang.string("menu_close"), 12, onCloseClicked);

            changeTab(_previousTabIndex);
        }

        override public function dispose():void
        {
            _currentTab.closeTab();
            _scrollbar.removeEventListener(Event.CHANGE, onScrollBarMoved, false);
            pane.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelMoved, false);
        }

        public function buildTabs():void
        {
            var tabBox:TabButton;

            for (var idx:int = 0; idx < _tabs.length; idx++)
            {
                tabBox = new TabButton(_box, -1, 60 + 33 * idx, idx, _lang.string("replay_tab_" + _tabs[idx].name));
                tabBox.tabIndex = idx;
                tabBox.addEventListener(MouseEvent.CLICK, onTabClicked);

                _tabButtons.push(tabBox);
            }
        }

        public function changeTab(idx:int):void
        {
            if (_currentTabIndex == idx)
                return;

            if (_currentTab != null)
            {
                _currentTab.closeTab();
                pane.clear();
            }

            _currentTabIndex = idx;
            _currentTab = _tabs[idx];
            _currentTab.openTab();
            _currentTab.setValues();
            _previousTabIndex = idx;

            // update buttons
            for each (var tabButton:TabButton in _tabButtons)
                tabButton.setActive(tabButton.index == idx);
        }

        private function onTabClicked(e:MouseEvent):void
        {
            changeTab((e.currentTarget as TabButton).index);
        }

        private function onCloseClicked(e:MouseEvent):void
        {
            dispatchEvent(new RemovePopupEvent());
        }

        private function onMouseWheelMoved(e:MouseEvent):void
        {
            if (!_scrollbar.visible)
                return;

            var dist:Number = _scrollbar.scroll + (pane.scrollFactorVertical / 2) * (e.delta > 0 ? -1 : 1);
            pane.scrollTo(dist);
            _scrollbar.scrollTo(dist, false);
        }

        private function onScrollBarMoved(e:Event):void
        {
            pane.scrollTo(e.target.scroll);
        }

        public function updateScrollPane():void
        {
            pane.scrollTo(0);
            _scrollbar.scrollTo(0, false);

            _scrollbar.visible = pane.doScroll;
        }

        public function onReplayEntryClicked(e:MouseEvent):void
        {
            var te:* = e.target;
            if (te is SimpleBoxButton)
            {
                var target:SimpleBoxButton = te as SimpleBoxButton;
                var entry:ReplayHistoryEntry = target.parent as ReplayHistoryEntry;
                var replay:Replay = _currentTab.prepareReplay(entry.replay);

                if (replay == null)
                    return;

                if (target == entry.btnPlay)
                {
                    if (replay.songInfo == null)
                    {
                        Alert.add(_lang.string("popup_replay_missing_song_data"));
                        return;
                    }

                    if (!replay.user.isLoaded())
                        replay.user.loadWithoutSettings();

                    _gvars.songResults.length = 0;
                    _gvars.songQueue = [replay.songInfo];

                    dispatchEvent(new WatchReplayEvent(replay));
                }

                if (target == entry.btnCopy)
                {
                    var replayString:String = replay.getEncode();
                    var success:Boolean = SystemUtil.setClipboard(replayString);

                    if (success)
                        Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
                    else
                        Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
                }
            }
        }

        private function onSearchChanged(e:Event):void
        {
            _searchText = _searchField.text;
            _searchFieldPlaceholder.visible = (_searchText.length <= 0);
            _currentTab.setValues();
        }

        public function get searchText():String
        {
            return _searchText;
        }
    }
}


import assets.menu.icons.fa.iconRight;

import classes.Room;
import classes.ui.SimpleBoxButton;
import classes.ui.Text;

import com.greensock.TweenLite;

import flash.display.Sprite;

internal class TabButton extends Sprite
{
    public var index:int;

    public var editor:Room;

    private var text:Text;
    private var button:SimpleBoxButton;
    private var chevron:iconRight;

    private var active:Boolean = false;

    private var hasTopBorder:Boolean = false;

    public function TabButton(parent:Sprite, xpos:Number, ypos:Number, index:int, btnText:String, hasTopBorder:Boolean = false)
    {
        this.index = index;
        this.hasTopBorder = hasTopBorder;

        this.text = new Text(this, 15, 5, btnText);
        this.text.setAreaParams(146, 22);

        this.button = new SimpleBoxButton(175, 32);
        this.addChild(button);

        this.x = xpos;
        this.y = ypos;
        parent.addChild(this);

        this.chevron = new iconRight();
        this.chevron.x = 16;
        this.chevron.y = 16.5;
        this.chevron.scaleX = this.chevron.scaleY = 0.2;
        this.chevron.visible = false;
        this.addChild(chevron);

        draw();
    }

    public function draw():void
    {
        this.graphics.clear();
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(0xFFFFFF, (active ? 0.2 : 0.08));
        this.graphics.drawRect(0, 0, 175, 32);
        this.graphics.endFill();

        this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
        this.graphics.moveTo(0, 32);
        this.graphics.lineTo(175, 32);

        if (hasTopBorder)
        {
            this.graphics.moveTo(0, 0);
            this.graphics.lineTo(175, 0);
        }
    }

    public function setActive(newState:Boolean):void
    {
        if (this.active != newState)
        {
            TweenLite.to(this.text, 0.25, {"x": (newState ? 25 : 15)});
            this.active = newState;
            this.button.visible = !newState;
            this.chevron.visible = newState;
            draw();
        }
    }
}
