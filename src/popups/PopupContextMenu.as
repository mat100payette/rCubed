package popups
{
    import assets.GameBackgroundColor;
    import classes.Language;
    import classes.ui.Box;
    import classes.ui.BoxButton;
    import com.flashdynamix.utils.SWFProfiler;
    import com.flashfla.utils.SpriteUtil;
    import flash.display.Bitmap;
    import flash.events.MouseEvent;
    import flash.profiler.showRedrawRegions;
    import menu.DisplayLayer;
    import events.navigation.popups.RemovePopupEvent;
    import flash.events.Event;
    import events.state.ReloadEngineEvent;
    import events.state.LogoutEvent;

    public class PopupContextMenu extends DisplayLayer
    {
        CONFIG::debug
        {
            private static var redrawBoolean:Boolean = false;
        }

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        //- Background
        private var _box:Box;
        private var _bgBox:Box;
        private var _bmp:Bitmap;

        public function PopupContextMenu()
        {
            super();
        }

        override public function stageAdd():void
        {
            _bmp = SpriteUtil.getBitmapSprite(stage);
            addChild(_bmp);

            _bgBox = new Box(this, (Main.GAME_WIDTH - 230) / 2, 20, false, false);
            _bgBox.setSize(230, Main.GAME_HEIGHT - 40);
            _bgBox.color = GameBackgroundColor.BG_POPUP;
            _bgBox.normalAlpha = 0.5;
            _bgBox.activeAlpha = 1;

            _box = new Box(this, (Main.GAME_WIDTH - 230) / 2, 20, false, false);
            _box.setSize(230, Main.GAME_HEIGHT - 40);
            _box.activeAlpha = 0.4;

            var cButton:BoxButton;
            var cButtonHeight:Number = 39;
            var yOff:Number = 5;

            // Debug Options
            CONFIG::debug
            {
                //- Profiler
                cButton = new BoxButton(this, 5, yOff, _box.width - 10, cButtonHeight, "Toggle Profiler", 12, clickHandler);
                cButton.action = "debug_profiler";
                cButton.boxColor = GameBackgroundColor.BG_POPUP;
                yOff += cButtonHeight + 5;

                //- Redraw
                cButton = new BoxButton(this, 5, yOff, _box.width - 10, cButtonHeight, "Toggle ReDraw Regions", 12, clickHandler);
                cButton.action = "redraw_regions";
                cButton.boxColor = GameBackgroundColor.BG_POPUP;
                yOff = 5;
            }

            //- Reload Engine
            cButton = new BoxButton(_box, 5, yOff, _box.width - 10, cButtonHeight, _lang.string("popup_cm_reload_engine_user"), 12, clickHandler);
            cButton.action = "reload_engine";
            yOff += cButtonHeight + 5;

            //- Screenshot - Local
            cButton = new BoxButton(_box, 5, yOff, _box.width - 10, cButtonHeight, _lang.string("popup_cm_save_screenshot"), 12, clickHandler);
            cButton.action = "screenshot_local";
            yOff += cButtonHeight + 5;

            //- Fullscreen
            cButton = new BoxButton(_box, 5, yOff, _box.width - 10, cButtonHeight, _lang.string("popup_cm_full_screen"), 12, clickHandler);
            cButton.action = "fullscreen";
            yOff += cButtonHeight + 5;

            //- Switch Profile
            cButton = new BoxButton(_box, 5, yOff, _box.width - 10, cButtonHeight, _lang.string("popup_cm_switch_profile"), 12, clickHandler);
            cButton.action = "switch_profile";
            yOff += cButtonHeight + 5;

            //- Close
            cButton = new BoxButton(_box, 5, _box.height - 27 - 5, _box.width - 10, 27, _lang.string("menu_close"), 12, onCloseClicked);
            cButton.action = "close";
        }

        private function onCloseClicked(e:Event):void
        {
            dispose();
            dispatchEvent(new RemovePopupEvent());
        }

        private function clickHandler(e:MouseEvent):void
        {
            //- Debug Actions
            CONFIG::debug
            {
                if (e.target.action == "debug_profiler")
                {
                    SWFProfiler.onSelect();
                }
                else if (e.target.action == "redraw_regions")
                {
                    redrawBoolean = !redrawBoolean;
                    showRedrawRegions(redrawBoolean, 0xFF0000);
                }
            }

            //- Close
            if (e.target.action == "fullscreen")
            {
                _gvars.toggleFullScreen();
            }
            else if (e.target.action == "screenshot_local")
            {
                _gvars.takeScreenShot();
            }
            else if (e.target.action == "reload_engine")
            {
                dispatchEvent(new ReloadEngineEvent());
            }
            else if (e.target.action == "switch_profile")
            {
                dispatchEvent(new LogoutEvent());
            }
        }
    }
}
