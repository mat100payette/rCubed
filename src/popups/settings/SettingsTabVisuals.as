package popups.settings
{
    import classes.Language;
    import classes.UserSettings;
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
        private var _sliderOptions:Object = {};
        private var _sliderTexts:Object = {};

        public function SettingsTabVisuals(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
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
            _parent.checkValidMods();
        }

        private function initSliderOption(textLocalStringName:String, value:Number):void
        {
            const slider:BoxSlider = _sliderOptions[textLocalStringName];
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
            _parent.checkValidMods();
        }

        override public function openTab():void
        {
            const SECTION_TITLE_FONT_SIZE:int = 14;
            const ROW_HEIGHT:int = 25;
            const SEPARATOR_WIDTH:int = 250;
            const TEXT_X_OFF:int = 23;
            const CHECK_X_OFF:int = 3;
            const CHECK_Y_OFF:int = 3;
            const SLIDER_WIDTH:int = 100;
            const SLIDER_HEIGHT:int = 10;
            const SLIDER_TEXT_X_OFF:int = 128;
            const SLIDER_TEXT_Y_OFF:int = -2;

            /**
             * Adds a new checkbox option with a given check callback.
             */
            function addCheckOption(textLocalStringName:String, checkCallback:Function):void
            {
                new Text(container, xOff + TEXT_X_OFF, yOff, _lang.string(textLocalStringName));
                const boxCheck:BoxCheck = new BoxCheck(container, xOff + CHECK_X_OFF, yOff + CHECK_Y_OFF, checkCallback);
                yOff += ROW_HEIGHT;
                _checkOptions[textLocalStringName] = boxCheck;
            }

            /**
             * Adds a new slider option and value text with a slide callback.
             */
            function addSliderOption(textLocalStringName:String, minValue:Number, maxValue:Number, slideCallback:Function):void
            {
                new Text(container, xOff + TEXT_X_OFF, yOff, _lang.string(textLocalStringName));
                yOff += ROW_HEIGHT;

                const valueText:Text = new Text(container, xOff + SLIDER_TEXT_X_OFF, yOff + SLIDER_TEXT_Y_OFF);
                const slider:BoxSlider = new BoxSlider(container, xOff + TEXT_X_OFF, yOff, SLIDER_WIDTH, SLIDER_HEIGHT, function(e:Event):void
                {
                    slideCallback(e, valueText);
                });
                slider.minValue = minValue;
                slider.maxValue = maxValue;

                yOff += ROW_HEIGHT;

                _sliderOptions[textLocalStringName] = slider;
                _sliderTexts[textLocalStringName] = valueText;
            }

            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var i:int;
            var xOff:int;
            var yOff:int;

            // LEFT COLUMN OPTIONS

            xOff = 15;
            yOff = 15;
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAMEPLAY_DISPLAY), SECTION_TITLE_FONT_SIZE);
            yOff += ROW_HEIGHT;

            addCheckOption(Lang.OPTIONS_GAME_TOP_BAR, onDisplayGameTopBarChanged);
            addCheckOption(Lang.OPTIONS_GAME_BOTTOM_BAR, onDisplayGameBottomBarChanged);
            addCheckOption(Lang.OPTIONS_JUDGE, onDisplayJudgeChanged);
            addCheckOption(Lang.OPTIONS_HEALTH, onDisplayHealthChanged);
            addCheckOption(Lang.OPTIONS_SONGPROGRESS, onDisplaySongProgressChanged);
            addCheckOption(Lang.OPTIONS_SONPROGRESS_TEXT, onDisplaySongProgressTextChanged);
            addCheckOption(Lang.OPTIONS_SCORE, onDisplayScoreChanged);
            addCheckOption(Lang.OPTIONS_COMBO, onDisplayComboChanged);
            addCheckOption(Lang.OPTIONS_PA_COUNT, onDisplayPACountChanged);
            addCheckOption(Lang.OPTIONS_ACCURACY_BAR, onDisplayAccuracyBarChanged);
            addCheckOption(Lang.OPTIONS_SCREENCUT, onDisplayScreencutChanged);

            yOff += drawSeperator(container, xOff, SEPARATOR_WIDTH, yOff, 0, 1);

            addCheckOption(Lang.OPTIONS_AMAZING, onDisplayAmazingChanged);
            addCheckOption(Lang.OPTIONS_PERFECT, onDisplayPerfectChanged);
            addCheckOption(Lang.OPTIONS_RECEPTOR_ANIMATIONS, onDisplayReceptorAnimationsChanged);
            addCheckOption(Lang.OPTIONS_JUDGE_ANIMATIONS, onDisplayJudgeAnimationsChanged);
            addSliderOption(Lang.OPTIONS_JUDGE_SPEED, 0.25, 3, onJudgeAnimationSpeedChanged);

            // RIGHT COLUMN OPTIONS

            xOff = 310;
            yOff = 15;
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAMEPLAY_MP_DISPLAY), SECTION_TITLE_FONT_SIZE);
            yOff += ROW_HEIGHT;

            addCheckOption(Lang.OPTIONS_MP_UI, onDisplayMPUIChanged);
            addCheckOption(Lang.OPTIONS_MP_PA, onDisplayMPPAChanged);
            addCheckOption(Lang.OPTIONS_MP_JUDGE, onDisplayMPJudgeChanged);
            addCheckOption(Lang.OPTIONS_MP_COMBO, onDisplayMPComboChanged);

            yOff += drawSeperator(container, xOff, SEPARATOR_WIDTH, yOff, 6, 5);
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_PLAYLIST_DISPLAY), SECTION_TITLE_FONT_SIZE);
            yOff += ROW_HEIGHT;

            addCheckOption(Lang.OPTIONS_GENRE_FLAG, onDisplayGenreFlagChanged);
            addCheckOption(Lang.OPTIONS_SONG_FLAG, onDisplaySongFlagChanged);
            addCheckOption(Lang.OPTIONS_SONG_NOTE, onDisplaySongNoteChanged);

            yOff += ROW_HEIGHT;
        }

        override public function setValues():void
        {
            initCheckOption(Lang.OPTIONS_GAME_TOP_BAR, _settings.displayGameTopBar);
            initCheckOption(Lang.OPTIONS_GAME_BOTTOM_BAR, _settings.displayGameBottomBar);
            initCheckOption(Lang.OPTIONS_JUDGE, _settings.displayJudge);
            initCheckOption(Lang.OPTIONS_HEALTH, _settings.displayHealth);
            initCheckOption(Lang.OPTIONS_SONGPROGRESS, _settings.displaySongProgress);
            initCheckOption(Lang.OPTIONS_SONPROGRESS_TEXT, _settings.displaySongProgressText);
            initCheckOption(Lang.OPTIONS_SCORE, _settings.displayScore);
            initCheckOption(Lang.OPTIONS_COMBO, _settings.displayCombo);
            initCheckOption(Lang.OPTIONS_PA_COUNT, _settings.displayPACount);
            initCheckOption(Lang.OPTIONS_ACCURACY_BAR, _settings.displayAccuracyBar);
            initCheckOption(Lang.OPTIONS_SCREENCUT, _settings.displayScreencut);

            initCheckOption(Lang.OPTIONS_AMAZING, _settings.displayAmazing);
            initCheckOption(Lang.OPTIONS_PERFECT, _settings.displayPerfect);
            initCheckOption(Lang.OPTIONS_RECEPTOR_ANIMATIONS, _settings.displayReceptorAnimations);
            initCheckOption(Lang.OPTIONS_JUDGE_ANIMATIONS, _settings.displayJudgeAnimations);
            initSliderOption(Lang.OPTIONS_JUDGE_SPEED, _settings.judgeSpeed);
            initSliderTextOption(Lang.OPTIONS_JUDGE_SPEED, _settings.judgeSpeed.toFixed(2) + "x");

            initCheckOption(Lang.OPTIONS_MP_UI, _settings.displayMPUI);
            initCheckOption(Lang.OPTIONS_MP_PA, _settings.displayMPPA);
            initCheckOption(Lang.OPTIONS_MP_JUDGE, _settings.displayMPJudge);
            initCheckOption(Lang.OPTIONS_MP_COMBO, _settings.displayMPCombo);

            initCheckOption(Lang.OPTIONS_GENRE_FLAG, _settings.displayGenreFlag);
            initCheckOption(Lang.OPTIONS_SONG_FLAG, _settings.displaySongFlag);
            initCheckOption(Lang.OPTIONS_SONG_NOTE, _settings.displaySongNote);
        }

        private function onDisplayGameTopBarChanged(e:MouseEvent):void
        {
            _settings.displayGameTopBar = !_settings.displayGameTopBar;
            checkOption(e);
        }

        private function onDisplayGameBottomBarChanged(e:MouseEvent):void
        {
            _settings.displayGameBottomBar = !_settings.displayGameBottomBar;
            checkOption(e);
        }

        private function onDisplayJudgeChanged(e:MouseEvent):void
        {
            _settings.displayJudge = !_settings.displayJudge;
            checkOption(e);
        }

        private function onDisplayHealthChanged(e:MouseEvent):void
        {
            _settings.displayHealth = !_settings.displayHealth;
            checkOption(e);
        }

        private function onDisplaySongProgressChanged(e:MouseEvent):void
        {
            _settings.displaySongProgress = !_settings.displaySongProgress;
            checkOption(e);
        }

        private function onDisplaySongProgressTextChanged(e:MouseEvent):void
        {
            _settings.displaySongProgressText = !_settings.displaySongProgressText;
            checkOption(e);
        }

        private function onDisplayScoreChanged(e:MouseEvent):void
        {
            _settings.displayScore = !_settings.displayScore;
            checkOption(e);
        }

        private function onDisplayComboChanged(e:MouseEvent):void
        {
            _settings.displayCombo = !_settings.displayCombo;
            checkOption(e);
        }

        private function onDisplayPACountChanged(e:MouseEvent):void
        {
            _settings.displayPACount = !_settings.displayPACount;
            checkOption(e);
        }

        private function onDisplayAccuracyBarChanged(e:MouseEvent):void
        {
            _settings.displayAccuracyBar = !_settings.displayAccuracyBar;
            checkOption(e);
        }

        private function onDisplayScreencutChanged(e:MouseEvent):void
        {
            _settings.displayScreencut = !_settings.displayScreencut;
            checkOption(e);
        }

        private function onDisplayAmazingChanged(e:MouseEvent):void
        {
            _settings.displayAmazing = !_settings.displayAmazing;
            checkOption(e);
        }

        private function onDisplayPerfectChanged(e:MouseEvent):void
        {
            _settings.displayPerfect = !_settings.displayPerfect;
            checkOption(e);
        }

        private function onDisplayReceptorAnimationsChanged(e:MouseEvent):void
        {
            _settings.displayReceptorAnimations = !_settings.displayReceptorAnimations;
            checkOption(e);
        }

        private function onDisplayJudgeAnimationsChanged(e:MouseEvent):void
        {
            _settings.displayJudgeAnimations = !_settings.displayJudgeAnimations;
            checkOption(e);
        }

        private function onJudgeAnimationSpeedChanged(e:Event, valueText:Text):void
        {
            _settings.judgeSpeed = ((Math.round((e.target.slideValue * 100) / 5) * 5) / 100);
            slideOption(valueText, _settings.judgeSpeed.toFixed(2) + "x");
        }

        private function onDisplayMPUIChanged(e:MouseEvent):void
        {
            _settings.displayMPUI = !_settings.displayMPUI;
            checkOption(e);
        }

        private function onDisplayMPPAChanged(e:MouseEvent):void
        {
            _settings.displayMPPA = !_settings.displayMPPA;
            checkOption(e);
        }

        private function onDisplayMPJudgeChanged(e:MouseEvent):void
        {
            _settings.displayMPJudge = !_settings.displayMPJudge;
            checkOption(e);
        }

        private function onDisplayMPComboChanged(e:MouseEvent):void
        {
            _settings.displayMPCombo = !_settings.displayMPCombo;
            checkOption(e);
        }

        private function onDisplayGenreFlagChanged(e:MouseEvent):void
        {
            _settings.displayGenreFlag = !_settings.displayGenreFlag;
            checkOption(e);
            _gvars.gameMain.activePanel.draw();
        }

        private function onDisplaySongFlagChanged(e:MouseEvent):void
        {
            _settings.displaySongFlag = !_settings.displaySongFlag;
            checkOption(e);
            _gvars.gameMain.activePanel.draw();
        }

        private function onDisplaySongNoteChanged(e:MouseEvent):void
        {
            _settings.displaySongNote = !_settings.displaySongNote;
            checkOption(e);
            _gvars.gameMain.activePanel.draw();
        }
    }
}
