package popups.settings
{
    import classes.Language;
    import classes.UserSettings;
    import classes.ui.BoxCheck;
    import classes.ui.BoxSlider;
    import classes.ui.Text;
    import events.actions.gameplay.layout.ToggleAccuracyBarEvent;
    import events.actions.gameplay.layout.ToggleAmazingEvent;
    import events.actions.gameplay.layout.ToggleComboEvent;
    import events.actions.gameplay.layout.ToggleGameBottomBarEvent;
    import events.actions.gameplay.layout.ToggleGameTopBarEvent;
    import events.actions.gameplay.layout.ToggleHealthEvent;
    import events.actions.gameplay.layout.ToggleJudgeAnimationsEvent;
    import events.actions.gameplay.layout.ToggleJudgeEvent;
    import events.actions.gameplay.layout.ToggleMPComboEvent;
    import events.actions.gameplay.layout.ToggleMPJudgeEvent;
    import events.actions.gameplay.layout.ToggleMPPAEvent;
    import events.actions.gameplay.layout.ToggleMPUIEvent;
    import events.actions.gameplay.layout.TogglePACountEvent;
    import events.actions.gameplay.layout.TogglePerfectEvent;
    import events.actions.gameplay.layout.ToggleReceptorAnimationsEvent;
    import events.actions.gameplay.layout.ToggleScoreEvent;
    import events.actions.gameplay.layout.ToggleScreencutEvent;
    import events.actions.gameplay.layout.ToggleSongProgressEvent;
    import events.actions.gameplay.layout.ToggleSongTimeEvent;
    import events.actions.gameplay.layout.ToggleTotalEvent;
    import events.actions.menu.ToggleGenreFlagEvent;
    import events.actions.menu.ToggleSongFlagEvent;
    import events.actions.menu.ToggleSongNoteEvent;
    import flash.events.Event;
    import state.AppState;
    import events.actions.gameplay.SetJudgeAnimationSpeedEvent;

    public class SettingsTabVisuals extends SettingsTabBase
    {
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

        public function SettingsTabVisuals(settingsWindow:SettingsWindow):void
        {
            super(settingsWindow);
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
            var settings:UserSettings = AppState.instance.auth.user.settings;

            _optionGameTopBar.checked = settings.displayGameTopBar;
            _optionGameBottomBar.checked = settings.displayGameBottomBar;
            _optionJudge.checked = settings.displayJudge;
            _optionHealth.checked = settings.displayHealth;
            _optionSongProgress.checked = settings.displaySongProgress;
            _optionSongProgressText.checked = settings.displaySongProgressText;
            _optionScore.checked = settings.displayScore;
            _optionCombo.checked = settings.displayCombo;
            _optionTotal.checked = settings.displayTotal;
            _optionPACount.checked = settings.displayPACount;
            _optionAccuracyBar.checked = settings.displayAccuracyBar;
            _optionScreencut.checked = settings.displayScreencut;

            _optionAmazing.checked = settings.displayAmazing;
            _optionPerfect.checked = settings.displayPerfect;
            _optionReceptorAnimations.checked = settings.displayReceptorAnimations;
            _optionJudgeAnimation.checked = settings.displayJudgeAnimations;
            _optionJudgeSpeed.slideValue = settings.judgeSpeed;

            _optionMPUI.checked = settings.displayMPUI;
            _optionMPPA.checked = settings.displayMPPA;
            _optionMPJudge.checked = settings.displayMPJudge;
            _optionMPCombo.checked = settings.displayMPCombo;

            _optionGenreFlag.checked = settings.displayGenreFlag;
            _optionSongFlag.checked = settings.displaySongFlag;
            _optionSongNote.checked = settings.displaySongNote;
        }

        private function onDisplayGameTopBarChanged(e:Event):void
        {
            dispatchEvent(new ToggleGameTopBarEvent());
        }

        private function onDisplayGameBottomBarChanged(e:Event):void
        {
            dispatchEvent(new ToggleGameBottomBarEvent());
        }

        private function onDisplayJudgeChanged(e:Event):void
        {
            dispatchEvent(new ToggleJudgeEvent());
        }

        private function onDisplayHealthChanged(e:Event):void
        {
            dispatchEvent(new ToggleHealthEvent());
        }

        private function onDisplaySongProgressChanged(e:Event):void
        {
            dispatchEvent(new ToggleSongProgressEvent());
        }

        private function onDisplaySongProgressTextChanged(e:Event):void
        {
            dispatchEvent(new ToggleSongTimeEvent());
        }

        private function onDisplayScoreChanged(e:Event):void
        {
            dispatchEvent(new ToggleScoreEvent());
        }

        private function onDisplayComboChanged(e:Event):void
        {
            dispatchEvent(new ToggleComboEvent());
        }

        private function onDisplayTotalChanged(e:Event):void
        {
            dispatchEvent(new ToggleTotalEvent());
        }

        private function onDisplayPACountChanged(e:Event):void
        {
            dispatchEvent(new TogglePACountEvent());
        }

        private function onDisplayAccuracyBarChanged(e:Event):void
        {
            dispatchEvent(new ToggleAccuracyBarEvent());
        }

        private function onDisplayScreencutChanged(e:Event):void
        {
            dispatchEvent(new ToggleScreencutEvent());
        }

        private function onDisplayAmazingChanged(e:Event):void
        {
            dispatchEvent(new ToggleAmazingEvent());
        }

        private function onDisplayPerfectChanged(e:Event):void
        {
            dispatchEvent(new TogglePerfectEvent());
        }

        private function onDisplayReceptorAnimationsChanged(e:Event):void
        {
            dispatchEvent(new ToggleReceptorAnimationsEvent());
        }

        private function onDisplayJudgeAnimationsChanged(e:Event):void
        {
            dispatchEvent(new ToggleJudgeAnimationsEvent());
        }

        private function onJudgeAnimationSpeedChanged(e:Event):void
        {
            var animationSpeed:Number = (Math.round((_optionJudgeSpeed.slideValue * 100) / 5) * 5) / 100;

            dispatchEvent(new SetJudgeAnimationSpeedEvent(animationSpeed));
        }

        private function judgeAnimationValueTextTransformer(value:Number):String
        {
            return value.toFixed(2) + "x";
        }

        private function onDisplayMPUIChanged(e:Event):void
        {
            dispatchEvent(new ToggleMPUIEvent());
        }

        private function onDisplayMPPAChanged(e:Event):void
        {
            dispatchEvent(new ToggleMPPAEvent());
        }

        private function onDisplayMPJudgeChanged(e:Event):void
        {
            dispatchEvent(new ToggleMPJudgeEvent());
        }

        private function onDisplayMPComboChanged(e:Event):void
        {
            dispatchEvent(new ToggleMPComboEvent());
        }

        private function onDisplayGenreFlagChanged(e:Event):void
        {
            dispatchEvent(new ToggleGenreFlagEvent());
        }

        private function onDisplaySongFlagChanged(e:Event):void
        {
            dispatchEvent(new ToggleSongFlagEvent());
        }

        private function onDisplaySongNoteChanged(e:Event):void
        {
            dispatchEvent(new ToggleSongNoteEvent());
        }
    }
}
