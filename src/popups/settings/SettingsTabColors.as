package popups.settings
{
    import classes.Language;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.ColorField;
    import classes.ui.ColorOption;
    import classes.ui.Text;
    import classes.ui.SelectableColorOption;
    import classes.ui.ValidatedText;
    import classes.UserSettings;
    import com.flashfla.utils.ColorUtil;
    import flash.events.Event;
    import flash.events.Event;
    import flash.text.TextFormatAlign;

    public class SettingsTabColors extends SettingsTabBase
    {
        private var _lang:Language = Language.instance;

        private var _optionRawGoodTracker:ValidatedText;

        private var _optionAmazingJudge:ColorOption;
        private var _optionPerfectJudge:ColorOption;
        private var _optionGoodJudge:ColorOption;
        private var _optionAverageJudge:ColorOption;
        private var _optionMissJudge:ColorOption;
        private var _optionBooJudge:ColorOption;

        private var _optionGameColor1:ColorOption;
        private var _optionGameColor2:ColorOption;
        private var _optionGameColor3:ColorOption;

        private var _optionNormalCombo:ColorOption;
        private var _optionFCCombo:SelectableColorOption;
        private var _optionAAACombo:SelectableColorOption;
        private var _optionSDGCombo:SelectableColorOption;
        private var _optionBlackflagCombo:SelectableColorOption;
        private var _optionAvflagCombo:SelectableColorOption;
        private var _optionBooflagCombo:SelectableColorOption;
        private var _optionMissflagCombo:SelectableColorOption;

        public function SettingsTabColors(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "colors";
        }

        private function changeColor(e:Event, option:ColorOption):int
        {
            var newColor:int;

            if (e.target is ColorField)
                newColor = (e.target as ColorField).color;
            else if (e.target is ValidatedText)
                newColor = (e.target as ValidatedText).validate(0, 0);
            else
                newColor = option.color;

            option.color = newColor;
            return newColor;
        }

        override public function openTab():void
        {
            /**
             * Adds a new color option with a given reset callback.
             */
            function addColorOption(localStringName:String, onColorChanged:Function, onReset:Function, tightLayout:Boolean = false):ColorOption
            {
                const label:Text = new Text(container, xOff, yOff, _lang.string(localStringName));
                label.width = 115;

                const textFieldXOff:int = tightLayout ? 100 : 120;
                const textField:ValidatedText = new ValidatedText(container, xOff + textFieldXOff, yOff, 70, 20, ValidatedText.R_COLOR, onColorChanged);
                textField.field.maxChars = 7;

                const colorDisplayXOff:int = tightLayout ? 175 : 195;
                const colorDisplay:ColorField = new ColorField(container, xOff + colorDisplayXOff, yOff, 0, 45, 21, onColorChanged);

                const resetButtonXOff:int = tightLayout ? 225 : 245;
                const resetButton:BoxButton = new BoxButton(container, xOff + resetButtonXOff, yOff, 20, 21, "R", 12, function(_:Event):void
                {
                    onReset();
                });
                resetButton.color = 0xff0000;

                const option:ColorOption = new ColorOption(textField, colorDisplay, resetButton);

                yOff += 20;
                yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

                _options[localStringName] = option;
                return option;
            }

            /**
             * Adds a new selectable color option with given reset and enabled callbacks.
             */
            function addSelectableColorOption(localStringName:String, onColorChanged:Function, onReset:Function, onEnabledChange:Function):SelectableColorOption
            {
                const label:Text = new Text(container, xOff, yOff, _lang.string(localStringName));
                label.width = 115;

                const textField:ValidatedText = new ValidatedText(container, xOff + 100, yOff, 70, 20, ValidatedText.R_COLOR, onColorChanged);
                textField.field.maxChars = 7;

                const colorDisplay:ColorField = new ColorField(container, xOff + 175, yOff, 0, 45, 21, onColorChanged);

                const resetButton:BoxButton = new BoxButton(container, xOff + 225, yOff, 20, 21, "R", 12, function(_:Event):void
                {
                    onReset();
                });
                resetButton.color = 0xff0000;

                const checkBox:BoxCheck = new BoxCheck(container, xOff + 250, yOff + 3, onEnabledChange);

                const option:SelectableColorOption = new SelectableColorOption(textField, colorDisplay, resetButton, checkBox);

                yOff += 20;
                yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

                _options[localStringName] = option;
                return option;
            }

            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var xOff:int = 15;
            var yOff:int = 15;

            /// Col 1
            const gameJudgeColorTitle:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_JUDGE_COLORS_DISPLAY), 14);
            gameJudgeColorTitle.width = 265;
            gameJudgeColorTitle.align = TextFormatAlign.CENTER;

            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            _optionAmazingJudge = addColorOption(Lang.GAME_AMAZING, onAmazingJudgeColorChanged, onAmazingJudgeColorReset);
            _optionPerfectJudge = addColorOption(Lang.GAME_PERFECT, onPerfectJudgeColorChanged, onPerfectJudgeColorReset);
            _optionGoodJudge = addColorOption(Lang.GAME_GOOD, onGoodJudgeColorChanged, onGoodJudgeColorReset);
            _optionAverageJudge = addColorOption(Lang.GAME_AVERAGE, onAverageJudgeColorChanged, onAverageJudgeColorReset);
            _optionMissJudge = addColorOption(Lang.GAME_MISS, onMissJudgeColorChanged, onMissJudgeColorReset);
            _optionBooJudge = addColorOption(Lang.GAME_BOO, onBooJudgeColorChanged, onBooJudgeColorReset);

            yOff += 8;

            const gameColorTitle:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAME_COLORS_TITLE), 14);
            gameColorTitle.width = 265;
            gameColorTitle.align = TextFormatAlign.CENTER;

            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            _optionGameColor1 = addColorOption(Lang.OPTIONS_GAME_COLOR_1, onGameAColorChanged, onGameAColorReset);
            _optionGameColor2 = addColorOption(Lang.OPTIONS_GAME_COLOR_2, onGameBColorChanged, onGameBColorReset);
            _optionGameColor3 = addColorOption(Lang.OPTIONS_GAME_COLOR_3, onGameCColorChanged, onGameCColorReset);

            /// Col 2
            xOff = 310;
            yOff = 15;

            const gameComboColorTitle:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_COMBO_COLORS_TITLE), 14);
            gameComboColorTitle.width = 265;
            gameComboColorTitle.align = TextFormatAlign.CENTER;
            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            _optionNormalCombo = addColorOption(Lang.OPTIONS_NORMAL_COMBO, onNormalComboColorChanged, onNormalComboColorReset, true);
            _optionFCCombo = addSelectableColorOption(Lang.OPTIONS_FC_COMBO, onFCComboColorChanged, onFCComboColorReset, onFCComboColorEnabled);
            _optionAAACombo = addSelectableColorOption(Lang.OPTIONS_AAA_COMBO, onAAAComboColorChanged, onAAAComboColorReset, onAAAComboColorEnabled);
            _optionSDGCombo = addSelectableColorOption(Lang.OPTIONS_SDG_COMBO, onSDGComboColorChanged, onSDGComboColorReset, onSDGComboColorEnabled);
            _optionBlackflagCombo = addSelectableColorOption(Lang.OPTIONS_BLACKFLAG_COMBO, onBlackflagComboColorChanged, onBlackflagComboColorReset, onBlackflagComboColorEnabled);
            _optionAvflagCombo = addSelectableColorOption(Lang.OPTIONS_AVFLAG_COMBO, onAvflagComboColorChanged, onAvflagComboColorReset, onAvflagComboColorEnabled);
            _optionBooflagCombo = addSelectableColorOption(Lang.OPTIONS_BOOFLAG_COMBO, onBooflagComboColorChanged, onBooflagComboColorReset, onBooflagComboColorEnabled);
            _optionMissflagCombo = addSelectableColorOption(Lang.OPTIONS_MISSFLAG_COMBO, onMissflagComboColorChanged, onMissflagComboColorReset, onMissflagComboColorEnabled);

            const gameRawGoodTracker:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_RAWGOODS_TRACKER));
            gameRawGoodTracker.width = 144;
            _optionRawGoodTracker = new ValidatedText(container, xOff + 149, yOff, 70, 20, ValidatedText.R_FLOAT_P, onRawGoodsTrackerChanged);
        }

        override public function setValues():void
        {
            _optionAmazingJudge.color = _settings.judgeColors[0];
            _optionPerfectJudge.color = _settings.judgeColors[1];
            _optionGoodJudge.color = _settings.judgeColors[2];
            _optionAverageJudge.color = _settings.judgeColors[3];
            _optionMissJudge.color = _settings.judgeColors[4];
            _optionBooJudge.color = _settings.judgeColors[5];

            _optionGameColor1.color = _settings.gameColors[0];
            _optionGameColor2.color = _settings.gameColors[1];
            _optionGameColor3.color = _settings.gameColors[4];

            _optionNormalCombo.color = _settings.comboColors[0];
            _optionFCCombo.color = _settings.comboColors[1];
            _optionFCCombo.checked = _settings.enableComboColors[1];
            _optionAAACombo.color = _settings.comboColors[2];
            _optionAAACombo.checked = _settings.enableComboColors[2];
            _optionSDGCombo.color = _settings.comboColors[3];
            _optionSDGCombo.checked = _settings.enableComboColors[3];
            _optionBlackflagCombo.color = _settings.comboColors[4];
            _optionBlackflagCombo.checked = _settings.enableComboColors[4];
            _optionAvflagCombo.color = _settings.comboColors[5];
            _optionAvflagCombo.checked = _settings.enableComboColors[5];
            _optionBooflagCombo.color = _settings.comboColors[6];
            _optionBooflagCombo.checked = _settings.enableComboColors[6];
            _optionMissflagCombo.color = _settings.comboColors[7];
            _optionMissflagCombo.checked = _settings.enableComboColors[7];

            _optionRawGoodTracker.text = _settings.rawGoodTracker.toString();
        }

        private function onAmazingJudgeColorChanged(e:Event):void
        {
            _settings.judgeColors[0] = changeColor(e, _optionAmazingJudge);
        }

        private function onAmazingJudgeColorReset():void
        {
            _settings.judgeColors[0] = DEFAULT_SETTINGS.judgeColors[0];
            setValues();
        }

        private function onPerfectJudgeColorChanged(e:Event):void
        {
            _settings.judgeColors[1] = changeColor(e, _optionPerfectJudge);
        }

        private function onPerfectJudgeColorReset():void
        {
            _settings.judgeColors[1] = DEFAULT_SETTINGS.judgeColors[1];
            setValues();
        }

        private function onGoodJudgeColorChanged(e:Event):void
        {
            _settings.judgeColors[2] = changeColor(e, _optionGoodJudge);
        }

        private function onGoodJudgeColorReset():void
        {
            _settings.judgeColors[2] = DEFAULT_SETTINGS.judgeColors[2];
            setValues();
        }

        private function onAverageJudgeColorChanged(e:Event):void
        {
            _settings.judgeColors[3] = changeColor(e, _optionAverageJudge);
        }

        private function onAverageJudgeColorReset():void
        {
            _settings.judgeColors[3] = DEFAULT_SETTINGS.judgeColors[3];
            setValues();
        }

        private function onMissJudgeColorChanged(e:Event):void
        {
            _settings.judgeColors[4] = changeColor(e, _optionMissJudge);
        }

        private function onMissJudgeColorReset():void
        {
            _settings.judgeColors[4] = DEFAULT_SETTINGS.judgeColors[4];
            setValues();
        }

        private function onBooJudgeColorChanged(e:Event):void
        {
            _settings.judgeColors[5] = changeColor(e, _optionBooJudge);
        }

        private function onBooJudgeColorReset():void
        {
            _settings.judgeColors[5] = DEFAULT_SETTINGS.judgeColors[5];
            setValues();
        }

        private function onGameAColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _optionGameColor1);
            _settings.gameColors[0] = newColor;
            _settings.gameColors[2] = ColorUtil.darkenColor(newColor, 0.27);
        }

        private function onGameAColorReset():void
        {
            _settings.gameColors[0] = DEFAULT_SETTINGS.gameColors[0];
            _settings.gameColors[2] = ColorUtil.darkenColor(DEFAULT_SETTINGS.gameColors[0], 0.27);
            setValues();
        }

        private function onGameBColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _optionGameColor2);
            _settings.gameColors[1] = newColor;
            _settings.gameColors[3] = ColorUtil.darkenColor(newColor, 0.08);
        }

        private function onGameBColorReset():void
        {
            _settings.gameColors[0] = DEFAULT_SETTINGS.gameColors[0];
            _settings.gameColors[3] = ColorUtil.brightenColor(DEFAULT_SETTINGS.gameColors[1], 0.08);
            setValues();
        }

        private function onGameCColorChanged(e:Event):void
        {
            _settings.gameColors[4] = changeColor(e, _optionGameColor3);
        }

        private function onGameCColorReset():void
        {
            _settings.gameColors[4] = DEFAULT_SETTINGS.gameColors[4];
            setValues();
        }

        private function onNormalComboColorChanged(e:Event):void
        {
            _settings.comboColors[0] = changeColor(e, _optionNormalCombo);
        }

        private function onNormalComboColorReset():void
        {
            _settings.comboColors[0] = DEFAULT_SETTINGS.comboColors[0];
            setValues();
        }

        private function onFCComboColorChanged(e:Event):void
        {
            _settings.comboColors[1] = changeColor(e, _optionFCCombo);
        }

        private function onFCComboColorReset():void
        {
            _settings.comboColors[1] = DEFAULT_SETTINGS.comboColors[1];
            setValues();
        }

        private function onFCComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[1] = !_settings.enableComboColors[1];
        }

        private function onAAAComboColorChanged(e:Event):void
        {
            _settings.comboColors[2] = changeColor(e, _optionAAACombo);
        }

        private function onAAAComboColorReset():void
        {
            _settings.comboColors[2] = DEFAULT_SETTINGS.comboColors[2];
            setValues();
        }

        private function onAAAComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[2] = !_settings.enableComboColors[2];
        }

        private function onSDGComboColorChanged(e:Event):void
        {
            _settings.comboColors[3] = changeColor(e, _optionSDGCombo);
        }

        private function onSDGComboColorReset():void
        {
            _settings.comboColors[3] = DEFAULT_SETTINGS.comboColors[2];
            setValues();
        }

        private function onSDGComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[2] = !_settings.enableComboColors[2];
        }

        private function onBlackflagComboColorChanged(e:Event):void
        {
            _settings.comboColors[4] = changeColor(e, _optionBlackflagCombo);
        }

        private function onBlackflagComboColorReset():void
        {
            _settings.comboColors[4] = DEFAULT_SETTINGS.comboColors[4];
            setValues();
        }

        private function onBlackflagComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[4] = !_settings.enableComboColors[4];
        }

        private function onAvflagComboColorChanged(e:Event):void
        {
            _settings.comboColors[5] = changeColor(e, _optionAvflagCombo);
        }

        private function onAvflagComboColorReset():void
        {
            _settings.comboColors[5] = DEFAULT_SETTINGS.comboColors[5];
            setValues();
        }

        private function onAvflagComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[5] = !_settings.enableComboColors[5];
        }

        private function onBooflagComboColorChanged(e:Event):void
        {
            _settings.comboColors[6] = changeColor(e, _optionBooflagCombo);
        }

        private function onBooflagComboColorReset():void
        {
            _settings.comboColors[6] = DEFAULT_SETTINGS.comboColors[6];
            setValues();
        }

        private function onBooflagComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[6] = !_settings.enableComboColors[6];
        }

        private function onMissflagComboColorChanged(e:Event):void
        {
            _settings.comboColors[4] = changeColor(e, _optionMissflagCombo);
        }

        private function onMissflagComboColorReset():void
        {
            _settings.comboColors[7] = DEFAULT_SETTINGS.comboColors[7];
            setValues();
        }

        private function onMissflagComboColorEnabled(e:Event):void
        {
            _settings.enableComboColors[7] = !_settings.enableComboColors[7];
        }

        public function onRawGoodsTrackerChanged(e:Event):void
        {
            _settings.rawGoodTracker = _optionRawGoodTracker.validate(0, 0);
        }
    }
}
