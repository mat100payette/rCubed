package popups.settings
{
    import classes.Language;
    import classes.ui.BoxCheck;
    import classes.ui.BoxSlider;
    import classes.ui.Text;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class SettingsTabVisuals extends SettingsTabBase
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        private var _checkOptions:Object = {};
        private var _checkOptionsInits:Object = {};

        private var _sliderOptions:Object = {};
        private var _sliderOptionsInits:Object = {};
        private var _sliderTexts:Object = {};
        private var _sliderTextsInits:Object = {};

        public function SettingsTabVisuals(settingsWindow:SettingsWindow):void
        {
            super(settingsWindow);
        }

        override public function get name():String
        {
            return "visual_graphics";
        }

        private function initCheckOption(textLocalStringName:String, checked:Boolean):void
        {
            (_checkOptions[textLocalStringName] as BoxCheck).checked = checked;
        }

        /**
         * A common change handler for the checkbox options.
         */
        private function checkOption(e:MouseEvent):void
        {
            e.target.checked = !e.target.checked;
            parent.checkValidMods();
        }

        private function initSliderOption(textLocalStringName:String, value:Number):void
        {
            var slider:BoxSlider = _sliderOptions[textLocalStringName];
            slider.slideValue = value;
        }

        private function initSliderTextOption(textLocalStringName:String, text:String):void
        {
            (_sliderTexts[textLocalStringName] as Text).text = text;
        }

        /**
         * A common change handler for the slider options.
         */
        private function slideOption(valueText:Text, text:String):void
        {
            valueText.text = text;
            parent.checkValidMods();
        }

        override public function openTab():void
        {
            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var i:int;
            var xOff:int;
            var yOff:int;

            var rowHeight:int = 25;
            var textXOff:int = 23;
            var checkXOff:int = 3;
            var checkYOff:int = 3;
            var sliderWidht:int = 100;
            var sliderHeight:int = 10;
            var sliderTextXOff:int = 128;

            /**
             * Adds a new checkbox option with a given initialization function and check callback.
             */
            function addCheckOption(textLocalStringName:String, initFunc:Function, checkCallback:Function):void
            {
                new Text(container, xOff + textXOff, yOff, _lang.string(textLocalStringName));
                var boxCheck:BoxCheck = new BoxCheck(container, xOff + checkXOff, yOff + checkYOff, checkCallback);
                yOff += rowHeight;
                _checkOptions[textLocalStringName] = boxCheck;
                _checkOptionsInits[textLocalStringName] = initFunc;
            }

            /**
             * Adds a new slider option and value text (both with a given initialization function) with a slide callback.
             */
            function addSliderOption(textLocalStringName:String, minValue:Number, maxValue:Number, sliderInitFunc:Function, textInitFunc:Function, slideCallback:Function):void
            {
                new Text(container, xOff + textXOff, yOff, _lang.string(textLocalStringName));
                yOff += rowHeight;

                var valueText:Text = new Text(container, xOff + sliderTextXOff, yOff - 2);
                var slider:BoxSlider = new BoxSlider(container, xOff + textXOff, yOff, sliderWidht, sliderHeight, function(e:Event):void
                {
                    slideCallback(e, valueText);
                });
                slider.minValue = minValue;
                slider.maxValue = maxValue;

                yOff += rowHeight;

                _sliderOptions[textLocalStringName] = slider;
                _sliderOptionsInits[textLocalStringName] = sliderInitFunc;
                _sliderTexts[textLocalStringName] = valueText;
                _sliderTextsInits[textLocalStringName] = textInitFunc;
            }

            // LEFT COLUMN OPTIONS

            xOff = 15;
            yOff = 15;
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAMEPLAY_DISPLAY), 14);
            yOff += rowHeight;

            addCheckOption(Lang.OPTIONS_GAME_TOP_BAR, initDisplayGameTopBar, onDisplayGameTopBarChanged);
            addCheckOption(Lang.OPTIONS_GAME_BOTTOM_BAR, initDisplayGameBottomBar, onDisplayGameBottomBarChanged);
            addCheckOption(Lang.OPTIONS_JUDGE, initDisplayJudge, onDisplayJudgeChanged);
            addCheckOption(Lang.OPTIONS_HEALTH, initDisplayHealth, onDisplayHealthChanged);
            addCheckOption(Lang.OPTIONS_SONGPROGRESS, initDisplaySongProgress, onDisplaySongProgressChanged);
            addCheckOption(Lang.OPTIONS_SONPROGRESS_TEXT, initDisplaySongProgressText, onDisplaySongProgressTextChanged);
            addCheckOption(Lang.OPTIONS_SCORE, initDisplayScore, onDisplayScoreChanged);
            addCheckOption(Lang.OPTIONS_COMBO, initDisplayCombo, onDisplayComboChanged);
            addCheckOption(Lang.OPTIONS_PA_COUNT, initDisplayPACount, onDisplayPACountChanged);
            addCheckOption(Lang.OPTIONS_ACCURACY_BAR, initDisplayAccuracyBar, onDisplayAccuracyBarChanged);
            addCheckOption(Lang.OPTIONS_SCREENCUT, initDisplayScreencut, onDisplayScreencutChanged);

            yOff += drawSeperator(container, xOff, 250, yOff, 0, 1);

            addCheckOption(Lang.OPTIONS_AMAZING, initDisplayAmazing, onDisplayAmazingChanged);
            addCheckOption(Lang.OPTIONS_PERFECT, initDisplayPerfefct, onDisplayPerfectChanged);
            addCheckOption(Lang.OPTIONS_RECEPTOR_ANIMATIONS, initDisplayReceptorAnimations, onDisplayReceptorAnimationsChanged);
            addCheckOption(Lang.OPTIONS_JUDGE_ANIMATIONS, initDisplayJudgeAnimations, onDisplayJudgeAnimationsChanged);
            addSliderOption(Lang.OPTIONS_JUDGE_SPEED, 0.25, 3, initJudgeAnimationSpeed, initJudgeAnimationSpeedText, onJudgeAnimationSpeedChanged);

            // RIGHT COLUMN OPTIONS

            xOff = 310;
            yOff = 15;
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAMEPLAY_MP_DISPLAY), 14);
            yOff += rowHeight;

            addCheckOption(Lang.OPTIONS_MP_UI, initDisplayMPUI, onDisplayMPUIChanged);
            addCheckOption(Lang.OPTIONS_MP_PA, initDisplayMPPA, onDisplayMPPAChanged);
            addCheckOption(Lang.OPTIONS_MP_JUDGE, initDisplayMPJudge, onDisplayMPJudgeChanged);
            addCheckOption(Lang.OPTIONS_MP_COMBO, initDisplayMPCombo, onDisplayMPComboChanged);

            yOff += drawSeperator(container, xOff, 250, yOff, 6, 5);
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_PLAYLIST_DISPLAY), 14);
            yOff += rowHeight;

            addCheckOption(Lang.OPTIONS_GENRE_FLAG, initDisplayGenreFlag, onDisplayGenreFlagChanged);
            addCheckOption(Lang.OPTIONS_SONG_FLAG, initDisplaySongFlag, onDisplaySongFlagChanged);
            addCheckOption(Lang.OPTIONS_SONG_NOTE, initDisplaySongNote, onDisplaySongNoteChanged);

            yOff += 30;
        }

        override public function setValues():void
        {
            for each (var checkInit:Function in _checkOptionsInits)
                checkInit();

            for each (var sliderInit:Function in _sliderOptionsInits)
                sliderInit();

            for each (var sliderTextInit:Function in _sliderTextsInits)
                sliderTextInit();
        }

        private function onDisplayGameTopBarChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayGameTopBar = !_gvars.activeUser.settings.displayGameTopBar;
            checkOption(e);
        }

        private function initDisplayGameTopBar():void
        {
            initCheckOption(Lang.OPTIONS_GAME_TOP_BAR, _gvars.activeUser.settings.displayGameTopBar);
        }

        private function onDisplayGameBottomBarChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayGameBottomBar = !_gvars.activeUser.settings.displayGameBottomBar;
            checkOption(e);
        }

        private function initDisplayGameBottomBar():void
        {
            initCheckOption(Lang.OPTIONS_GAME_BOTTOM_BAR, _gvars.activeUser.settings.displayGameBottomBar);
        }

        private function onDisplayJudgeChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayJudge = !_gvars.activeUser.settings.displayJudge;
            checkOption(e);
        }

        private function initDisplayJudge():void
        {
            initCheckOption(Lang.OPTIONS_JUDGE, _gvars.activeUser.settings.displayJudge);
        }

        private function onDisplayHealthChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayHealth = !_gvars.activeUser.settings.displayHealth;
            checkOption(e);
        }

        private function initDisplayHealth():void
        {
            initCheckOption(Lang.OPTIONS_HEALTH, _gvars.activeUser.settings.displayHealth);
        }

        private function onDisplaySongProgressChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displaySongProgress = !_gvars.activeUser.settings.displaySongProgress;
            checkOption(e);
        }

        private function initDisplaySongProgress():void
        {
            initCheckOption(Lang.OPTIONS_SONGPROGRESS, _gvars.activeUser.settings.displaySongProgress);
        }

        private function onDisplaySongProgressTextChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displaySongProgressText = !_gvars.activeUser.settings.displaySongProgressText;
            checkOption(e);
        }

        private function initDisplaySongProgressText():void
        {
            initCheckOption(Lang.OPTIONS_SONPROGRESS_TEXT, _gvars.activeUser.settings.displaySongProgressText);
        }

        private function onDisplayScoreChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayScore = !_gvars.activeUser.settings.displayScore;
            checkOption(e);
        }

        private function initDisplayScore():void
        {
            initCheckOption(Lang.OPTIONS_SCORE, _gvars.activeUser.settings.displayScore);
        }

        private function onDisplayComboChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayCombo = !_gvars.activeUser.settings.displayCombo;
            checkOption(e);
        }

        private function initDisplayCombo():void
        {
            initCheckOption(Lang.OPTIONS_COMBO, _gvars.activeUser.settings.displayCombo);
        }

        private function onDisplayPACountChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayPACount = !_gvars.activeUser.settings.displayPACount;
            checkOption(e);
        }

        private function initDisplayPACount():void
        {
            initCheckOption(Lang.OPTIONS_PA_COUNT, _gvars.activeUser.settings.displayPACount);
        }

        private function onDisplayAccuracyBarChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayAccuracyBar = !_gvars.activeUser.settings.displayAccuracyBar;
            checkOption(e);
        }

        private function initDisplayAccuracyBar():void
        {
            initCheckOption(Lang.OPTIONS_ACCURACY_BAR, _gvars.activeUser.settings.displayAccuracyBar);
        }

        private function onDisplayScreencutChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayScreencut = !_gvars.activeUser.settings.displayScreencut;
            checkOption(e);
        }

        private function initDisplayScreencut():void
        {
            initCheckOption(Lang.OPTIONS_SCREENCUT, _gvars.activeUser.settings.displayScreencut);
        }

        private function onDisplayAmazingChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayAmazing = !_gvars.activeUser.settings.displayAmazing;
            checkOption(e);
        }

        private function initDisplayAmazing():void
        {
            initCheckOption(Lang.OPTIONS_AMAZING, _gvars.activeUser.settings.displayAmazing);
        }

        private function onDisplayPerfectChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayPerfect = !_gvars.activeUser.settings.displayPerfect;
            checkOption(e);
        }

        private function initDisplayPerfefct():void
        {
            initCheckOption(Lang.OPTIONS_PERFECT, _gvars.activeUser.settings.displayPerfect);
        }

        private function onDisplayReceptorAnimationsChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayReceptorAnimations = !_gvars.activeUser.settings.displayReceptorAnimations;
            checkOption(e);
        }

        private function initDisplayReceptorAnimations():void
        {
            initCheckOption(Lang.OPTIONS_RECEPTOR_ANIMATIONS, _gvars.activeUser.settings.displayReceptorAnimations);
        }

        private function onDisplayJudgeAnimationsChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayJudgeAnimations = !_gvars.activeUser.settings.displayJudgeAnimations;
            checkOption(e);
        }

        private function initDisplayJudgeAnimations():void
        {
            initCheckOption(Lang.OPTIONS_JUDGE_ANIMATIONS, _gvars.activeUser.settings.displayJudgeAnimations);
        }

        private function onJudgeAnimationSpeedChanged(e:Event, valueText:Text):void
        {
            _gvars.activeUser.settings.judgeSpeed = ((Math.round((e.target.slideValue * 100) / 5) * 5) / 100);
            slideOption(valueText, _gvars.activeUser.settings.judgeSpeed.toFixed(2) + "x");
        }

        private function initJudgeAnimationSpeed():void
        {
            initSliderOption(Lang.OPTIONS_JUDGE_SPEED, _gvars.activeUser.settings.judgeSpeed);
        }

        private function initJudgeAnimationSpeedText():void
        {
            initSliderTextOption(Lang.OPTIONS_JUDGE_SPEED, _gvars.activeUser.settings.judgeSpeed.toFixed(2) + "x");
        }

        private function onDisplayMPUIChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayMPUI = !_gvars.activeUser.settings.displayMPUI;
            checkOption(e);
        }

        private function initDisplayMPUI():void
        {
            initCheckOption(Lang.OPTIONS_MP_UI, _gvars.activeUser.settings.displayMPUI);
        }

        private function onDisplayMPPAChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayMPPA = !_gvars.activeUser.settings.displayMPPA;
            checkOption(e);
        }

        private function initDisplayMPPA():void
        {
            initCheckOption(Lang.OPTIONS_MP_PA, _gvars.activeUser.settings.displayMPPA);
        }

        private function onDisplayMPJudgeChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayMPJudge = !_gvars.activeUser.settings.displayMPJudge;
            checkOption(e);
        }

        private function initDisplayMPJudge():void
        {
            initCheckOption(Lang.OPTIONS_MP_JUDGE, _gvars.activeUser.settings.displayMPJudge);
        }

        private function onDisplayMPComboChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayMPCombo = !_gvars.activeUser.settings.displayMPCombo;
            checkOption(e);
        }

        private function initDisplayMPCombo():void
        {
            initCheckOption(Lang.OPTIONS_MP_COMBO, _gvars.activeUser.settings.displayMPCombo);
        }

        private function onDisplayGenreFlagChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displayGenreFlag = !_gvars.activeUser.settings.displayGenreFlag;
            checkOption(e);
            _gvars.gameMain.activePanel.draw();
        }

        private function initDisplayGenreFlag():void
        {
            initCheckOption(Lang.OPTIONS_GENRE_FLAG, _gvars.activeUser.settings.displayGenreFlag);
        }

        private function onDisplaySongFlagChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displaySongFlag = !_gvars.activeUser.settings.displaySongFlag;
            checkOption(e);
            _gvars.gameMain.activePanel.draw();
        }

        private function initDisplaySongFlag():void
        {
            initCheckOption(Lang.OPTIONS_SONG_FLAG, _gvars.activeUser.settings.displaySongFlag);
        }

        private function onDisplaySongNoteChanged(e:MouseEvent):void
        {
            _gvars.activeUser.settings.displaySongNote = !_gvars.activeUser.settings.displaySongNote;
            checkOption(e);
            _gvars.gameMain.activePanel.draw();
        }

        private function initDisplaySongNote():void
        {
            initCheckOption(Lang.OPTIONS_SONG_NOTE, _gvars.activeUser.settings.displaySongNote);
        }
    }
}
