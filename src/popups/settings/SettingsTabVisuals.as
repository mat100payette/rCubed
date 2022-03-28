package popups.settings
{
    import classes.Language;
    import classes.UserSettings;
    import classes.ui.BoxCheck;
    import classes.ui.BoxSlider;
    import classes.ui.Text;
    import flash.events.Event;
    import flash.events.Event;

    public class SettingsTabVisuals extends SettingsTabBase
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        private var _optionGameTopBar:BoxCheck;
        private var _optionGameBottomBar:BoxCheck;
        private var _optionJudge:BoxCheck;
        private var _optionHealth:BoxCheck;
        private var _optionSongProgress:BoxCheck;
        private var _optionSongProgressText:BoxCheck;
        private var _optionScore:BoxCheck;
        private var _optionCombo:BoxCheck;
        private var _optionTotal:BoxCheck;
        private var _optionPACount:BoxCheck;
        private var _optionAccuracyBar:BoxCheck;
        private var _optionScreencut:BoxCheck;

        private var _optionAmazing:BoxCheck;
        private var _optionPerfect:BoxCheck;
        private var _optionReceptorAnimations:BoxCheck;
        private var _optionJudgeAnimation:BoxCheck;
        private var _optionJudgeSpeed:BoxSlider;

        private var _optionMPUI:BoxCheck;
        private var _optionMPPA:BoxCheck;
        private var _optionMPJudge:BoxCheck;
        private var _optionMPCombo:BoxCheck;

        private var _optionGenreFlag:BoxCheck;
        private var _optionSongFlag:BoxCheck;
        private var _optionSongNote:BoxCheck;

        public function SettingsTabVisuals(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "visual_graphics";
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
             * Adds a new checkbox option with a check callback.
             */
            function addCheckOption(textLocalStringName:String, onCheck:Function):BoxCheck
            {
                new Text(container, xOff + TEXT_X_OFF, yOff, _lang.string(textLocalStringName));
                const boxCheck:BoxCheck = new BoxCheck(container, xOff + CHECK_X_OFF, yOff + CHECK_Y_OFF, onCheck);
                yOff += ROW_HEIGHT;

                _options[textLocalStringName] = boxCheck;
                return boxCheck;
            }

            /**
             * Adds a new slider option with a slide callback.
             */
            function addSliderOption(textLocalStringName:String, minValue:Number, maxValue:Number, onSlide:Function, valueTextTransformer:Function = null):BoxSlider
            {
                new Text(container, xOff + TEXT_X_OFF, yOff, _lang.string(textLocalStringName));
                yOff += ROW_HEIGHT;

                const slider:BoxSlider = new BoxSlider(container, xOff + TEXT_X_OFF, yOff, SLIDER_WIDTH, SLIDER_HEIGHT, BoxSlider.TEXT_ALIGN_RIGHT, onSlide, valueTextTransformer);
                slider.minValue = minValue;
                slider.maxValue = maxValue;

                yOff += ROW_HEIGHT;

                _options[textLocalStringName] = slider;
                return slider;
            }

            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var xOff:int;
            var yOff:int;

            // LEFT COLUMN OPTIONS

            xOff = 15;
            yOff = 15;
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAMEPLAY_DISPLAY), SECTION_TITLE_FONT_SIZE);
            yOff += ROW_HEIGHT;

            _optionGameTopBar = addCheckOption(Lang.OPTIONS_GAME_TOP_BAR, onDisplayGameTopBarChanged);
            _optionGameBottomBar = addCheckOption(Lang.OPTIONS_GAME_BOTTOM_BAR, onDisplayGameBottomBarChanged);
            _optionJudge = addCheckOption(Lang.OPTIONS_JUDGE, onDisplayJudgeChanged);
            _optionHealth = addCheckOption(Lang.OPTIONS_HEALTH, onDisplayHealthChanged);
            _optionSongProgress = addCheckOption(Lang.OPTIONS_SONGPROGRESS, onDisplaySongProgressChanged);
            _optionSongProgressText = addCheckOption(Lang.OPTIONS_SONPROGRESS_TEXT, onDisplaySongProgressTextChanged);
            _optionScore = addCheckOption(Lang.OPTIONS_SCORE, onDisplayScoreChanged);
            _optionCombo = addCheckOption(Lang.OPTIONS_COMBO, onDisplayComboChanged);
            _optionTotal = addCheckOption(Lang.OPTIONS_TOTAL, onDisplayTotalChanged);
            _optionPACount = addCheckOption(Lang.OPTIONS_PA_COUNT, onDisplayPACountChanged);
            _optionAccuracyBar = addCheckOption(Lang.OPTIONS_ACCURACY_BAR, onDisplayAccuracyBarChanged);
            _optionScreencut = addCheckOption(Lang.OPTIONS_SCREENCUT, onDisplayScreencutChanged);

            yOff += drawSeperator(container, xOff, SEPARATOR_WIDTH, yOff, 0, 1);

            _optionAmazing = addCheckOption(Lang.OPTIONS_AMAZING, onDisplayAmazingChanged);
            _optionPerfect = addCheckOption(Lang.OPTIONS_PERFECT, onDisplayPerfectChanged);
            _optionReceptorAnimations = addCheckOption(Lang.OPTIONS_RECEPTOR_ANIMATIONS, onDisplayReceptorAnimationsChanged);
            _optionJudgeAnimation = addCheckOption(Lang.OPTIONS_JUDGE_ANIMATIONS, onDisplayJudgeAnimationsChanged);
            _optionJudgeSpeed = addSliderOption(Lang.OPTIONS_JUDGE_SPEED, 0.25, 3, onJudgeAnimationSpeedChanged, judgeAnimationValueTextTransformer);

            // RIGHT COLUMN OPTIONS

            xOff = 310;
            yOff = 15;
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAMEPLAY_MP_DISPLAY), SECTION_TITLE_FONT_SIZE);
            yOff += ROW_HEIGHT;

            _optionMPUI = addCheckOption(Lang.OPTIONS_MP_UI, onDisplayMPUIChanged);
            _optionMPPA = addCheckOption(Lang.OPTIONS_MP_PA, onDisplayMPPAChanged);
            _optionMPJudge = addCheckOption(Lang.OPTIONS_MP_JUDGE, onDisplayMPJudgeChanged);
            _optionMPCombo = addCheckOption(Lang.OPTIONS_MP_COMBO, onDisplayMPComboChanged);

            yOff += drawSeperator(container, xOff, SEPARATOR_WIDTH, yOff, 6, 5);
            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_PLAYLIST_DISPLAY), SECTION_TITLE_FONT_SIZE);
            yOff += ROW_HEIGHT;

            _optionGenreFlag = addCheckOption(Lang.OPTIONS_GENRE_FLAG, onDisplayGenreFlagChanged);
            _optionSongFlag = addCheckOption(Lang.OPTIONS_SONG_FLAG, onDisplaySongFlagChanged);
            _optionSongNote = addCheckOption(Lang.OPTIONS_SONG_NOTE, onDisplaySongNoteChanged);

            yOff += ROW_HEIGHT;
        }

        override public function setValues():void
        {
            _optionGameTopBar.checked = _settings.displayGameTopBar;
            _optionGameBottomBar.checked = _settings.displayGameBottomBar;
            _optionJudge.checked = _settings.displayJudge;
            _optionHealth.checked = _settings.displayHealth;
            _optionSongProgress.checked = _settings.displaySongProgress;
            _optionSongProgressText.checked = _settings.displaySongProgressText;
            _optionScore.checked = _settings.displayScore;
            _optionCombo.checked = _settings.displayCombo;
            _optionTotal.checked = _settings.displayTotal;
            _optionPACount.checked = _settings.displayPACount;
            _optionAccuracyBar.checked = _settings.displayAccuracyBar;
            _optionScreencut.checked = _settings.displayScreencut;

            _optionAmazing.checked = _settings.displayAmazing;
            _optionPerfect.checked = _settings.displayPerfect;
            _optionReceptorAnimations.checked = _settings.displayReceptorAnimations;
            _optionJudgeAnimation.checked = _settings.displayJudgeAnimations;
            _optionJudgeSpeed.slideValue = _settings.judgeSpeed;

            _optionMPUI.checked = _settings.displayMPUI;
            _optionMPPA.checked = _settings.displayMPPA;
            _optionMPJudge.checked = _settings.displayMPJudge;
            _optionMPCombo.checked = _settings.displayMPCombo;

            _optionGenreFlag.checked = _settings.displayGenreFlag;
            _optionSongFlag.checked = _settings.displaySongFlag;
            _optionSongNote.checked = _settings.displaySongNote;
        }

        private function onDisplayGameTopBarChanged(e:Event):void
        {
            _settings.displayGameTopBar = !_settings.displayGameTopBar;
            _parent.checkValidMods();
        }

        private function onDisplayGameBottomBarChanged(e:Event):void
        {
            _settings.displayGameBottomBar = !_settings.displayGameBottomBar;
            _parent.checkValidMods();
        }

        private function onDisplayJudgeChanged(e:Event):void
        {
            _settings.displayJudge = !_settings.displayJudge;
            _parent.checkValidMods();
        }

        private function onDisplayHealthChanged(e:Event):void
        {
            _settings.displayHealth = !_settings.displayHealth;
            _parent.checkValidMods();
        }

        private function onDisplaySongProgressChanged(e:Event):void
        {
            _settings.displaySongProgress = !_settings.displaySongProgress;
            _parent.checkValidMods();
        }

        private function onDisplaySongProgressTextChanged(e:Event):void
        {
            _settings.displaySongProgressText = !_settings.displaySongProgressText;
            _parent.checkValidMods();
        }

        private function onDisplayScoreChanged(e:Event):void
        {
            _settings.displayScore = !_settings.displayScore;
            _parent.checkValidMods();
        }

        private function onDisplayComboChanged(e:Event):void
        {
            _settings.displayCombo = !_settings.displayCombo;
            _parent.checkValidMods();
        }

        private function onDisplayTotalChanged(e:Event):void
        {
            _settings.displayTotal = !_settings.displayTotal;
            _parent.checkValidMods();
        }

        private function onDisplayPACountChanged(e:Event):void
        {
            _settings.displayPACount = !_settings.displayPACount;
            _parent.checkValidMods();
        }

        private function onDisplayAccuracyBarChanged(e:Event):void
        {
            _settings.displayAccuracyBar = !_settings.displayAccuracyBar;
            _parent.checkValidMods();
        }

        private function onDisplayScreencutChanged(e:Event):void
        {
            _settings.displayScreencut = !_settings.displayScreencut;
            _parent.checkValidMods();
        }

        private function onDisplayAmazingChanged(e:Event):void
        {
            _settings.displayAmazing = !_settings.displayAmazing;
            _parent.checkValidMods();
        }

        private function onDisplayPerfectChanged(e:Event):void
        {
            _settings.displayPerfect = !_settings.displayPerfect;
            _parent.checkValidMods();
        }

        private function onDisplayReceptorAnimationsChanged(e:Event):void
        {
            _settings.displayReceptorAnimations = !_settings.displayReceptorAnimations;
            _parent.checkValidMods();
        }

        private function onDisplayJudgeAnimationsChanged(e:Event):void
        {
            _settings.displayJudgeAnimations = !_settings.displayJudgeAnimations;
            _parent.checkValidMods();
        }

        private function onJudgeAnimationSpeedChanged(e:Event):void
        {
            _settings.judgeSpeed = ((Math.round((_optionJudgeSpeed.slideValue * 100) / 5) * 5) / 100);
            _parent.checkValidMods();
        }

        private function judgeAnimationValueTextTransformer(value:Number):String
        {
            return value.toFixed(2) + "x";
        }

        private function onDisplayMPUIChanged(e:Event):void
        {
            _settings.displayMPUI = !_settings.displayMPUI;
            _parent.checkValidMods();
        }

        private function onDisplayMPPAChanged(e:Event):void
        {
            _settings.displayMPPA = !_settings.displayMPPA;
            _parent.checkValidMods();
        }

        private function onDisplayMPJudgeChanged(e:Event):void
        {
            _settings.displayMPJudge = !_settings.displayMPJudge;
            _parent.checkValidMods();
        }

        private function onDisplayMPComboChanged(e:Event):void
        {
            _settings.displayMPCombo = !_settings.displayMPCombo;
            _parent.checkValidMods();
        }

        private function onDisplayGenreFlagChanged(e:Event):void
        {
            _settings.displayGenreFlag = !_settings.displayGenreFlag;
            _parent.checkValidMods();
        }

        private function onDisplaySongFlagChanged(e:Event):void
        {
            _settings.displaySongFlag = !_settings.displaySongFlag;
            _parent.checkValidMods();
        }

        private function onDisplaySongNoteChanged(e:Event):void
        {
            _settings.displaySongNote = !_settings.displaySongNote;
            _parent.checkValidMods();
        }
    }
}
