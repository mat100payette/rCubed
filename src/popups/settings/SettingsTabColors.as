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
    import flash.events.MouseEvent;

    public class SettingsTabColors extends SettingsTabBase
    {
        private var _lang:Language = Language.instance;

        private var _colorOptions:Object = {};
        private var _optionRawGoodTracker:ValidatedText;

        public function SettingsTabColors(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "colors";
        }

        /**
         * A common change handler for the checkbox options.
         */
        private function checkOption(e:MouseEvent):void
        {
            e.target.checked = !e.target.checked;
        }

        private function initColorOption(textLocalStringName:String, color:int):void
        {
            const option:ColorOption = _colorOptions[textLocalStringName] as ColorOption;
            option.color = color;
        }

        private function initSelectableColorOption(textLocalStringName:String, color:int, checked:Boolean):void
        {
            const option:SelectableColorOption = _colorOptions[textLocalStringName] as SelectableColorOption;
            option.color = color;
            option.checked = checked;
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
            function addColorOption(localStringName:String, onColorChanged:Function, onReset:Function):void
            {
                const label:Text = new Text(container, xOff, yOff, _lang.string(localStringName));
                label.width = 115;

                const textField:ValidatedText = new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, onColorChanged);
                textField.field.maxChars = 7;

                const colorDisplay:ColorField = new ColorField(container, xOff + 195, yOff, 0, 45, 21, onColorChanged);

                const resetButton:BoxButton = new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, function(_:Event):void
                {
                    onReset();
                });
                resetButton.color = 0xff0000;

                _colorOptions[localStringName] = new ColorOption(textField, colorDisplay, resetButton);

                yOff += 20;
                yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
            }

            /**
             * Adds a new selectable color option with given reset and enabled callbacks.
             */
            function addSelectableColorOption(localStringName:String, onColorChanged:Function, onReset:Function, onEnabledChange:Function):void
            {
                const label:Text = new Text(container, xOff, yOff, _lang.string(localStringName));
                label.width = 115;

                const textField:ValidatedText = new ValidatedText(container, xOff + 120, yOff, 70, 20, ValidatedText.R_COLOR, onColorChanged);
                textField.field.maxChars = 7;

                const colorDisplay:ColorField = new ColorField(container, xOff + 195, yOff, 0, 45, 21, onColorChanged);

                const resetButton:BoxButton = new BoxButton(container, xOff + 245, yOff, 20, 21, "R", 12, function(_:Event):void
                {
                    onReset();
                });
                resetButton.color = 0xff0000;

                const checkBox:BoxCheck = new BoxCheck(container, xOff + 250, yOff + 3, onEnabledChange);

                _colorOptions[localStringName] = new SelectableColorOption(textField, colorDisplay, resetButton, checkBox);

                yOff += 20;
                yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);
            }

            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var i:int;
            var xOff:int = 15;
            var yOff:int = 15;

            /// Col 1
            const gameJudgeColorTitle:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_JUDGE_COLORS_DISPLAY), 14);
            gameJudgeColorTitle.width = 265;
            gameJudgeColorTitle.align = Text.CENTER;
            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            addColorOption(Lang.OPTIONS_GAME_AMAZING, onAmazingJudgeColorChanged, onAmazingJudgeColorReset);
            addColorOption(Lang.OPTIONS_GAME_PERFECT, onPerfectJudgeColorChanged, onPerfectJudgeColorReset);
            addColorOption(Lang.OPTIONS_GAME_GOOD, onGoodJudgeColorChanged, onGoodJudgeColorReset);
            addColorOption(Lang.OPTIONS_GAME_AVERAGE, onAverageJudgeColorChanged, onAverageJudgeColorReset);
            addColorOption(Lang.OPTIONS_GAME_MISS, onMissJudgeColorChanged, onMissJudgeColorReset);
            addColorOption(Lang.OPTIONS_GAME_BOO, onBooJudgeColorChanged, onBooJudgeColorReset);

            yOff += 8;

            const gameColorTitle:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_GAME_COLORS_TITLE), 14);
            gameColorTitle.width = 265;
            gameColorTitle.align = Text.CENTER;

            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            addColorOption(Lang.OPTIONS_GAME_COLOR_1, onGameAColorChanged, onGameAColorReset);
            addColorOption(Lang.OPTIONS_GAME_COLOR_2, onGameBColorChanged, onGameBColorReset);
            addColorOption(Lang.OPTIONS_GAME_COLOR_3, onGameCColorChanged, onGameCColorReset);

            /// Col 2
            xOff = 310;
            yOff = 15;

            const gameComboColorTitle:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_COMBO_COLORS_TITLE), 14);
            gameComboColorTitle.width = 265;
            gameComboColorTitle.align = Text.CENTER;
            yOff += 28;
            yOff += drawSeperator(container, xOff, 266, yOff, -3, -4);

            addColorOption(Lang.OPTIONS_NORMAL_COMBO, onNormalComboColorChanged, onNormalComboColorReset);
            addSelectableColorOption(Lang.OPTIONS_FC_COMBO, onFCComboColorChanged, onFCComboColorReset, onFCComboColorEnabled);
            addSelectableColorOption(Lang.OPTIONS_AAA_COMBO, onAAAComboColorChanged, onAAAComboColorReset, onAAAComboColorEnabled);
            addSelectableColorOption(Lang.OPTIONS_SDG_COMBO, onSDGComboColorChanged, onSDGComboColorReset, onSDGComboColorEnabled);
            addSelectableColorOption(Lang.OPTIONS_BLACKFLAG_COMBO, onBlackflagComboColorChanged, onBlackflagComboColorReset, onBlackflagComboColorEnabled);
            addSelectableColorOption(Lang.OPTIONS_AVFLAG_COMBO, onAvflagComboColorChanged, onAvflagComboColorReset, onAvflagComboColorEnabled);
            addSelectableColorOption(Lang.OPTIONS_BOOFLAG_COMBO, onBooflagComboColorChanged, onBooflagComboColorReset, onBooflagComboColorEnabled);
            addSelectableColorOption(Lang.OPTIONS_MISSFLAG_COMBO, onMissflagComboColorChanged, onMissflagComboColorReset, onMissflagComboColorEnabled);

            const gameRawGoodTracker:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_RAWGOODS_TRACKER));
            gameRawGoodTracker.width = 144;
            _optionRawGoodTracker = new ValidatedText(container, xOff + 149, yOff, 70, 20, ValidatedText.R_FLOAT_P, onRawGoodsTrackerChanged);
        }

        override public function setValues():void
        {
            initColorOption(Lang.OPTIONS_GAME_AMAZING, _settings.judgeColors[0]);
            initColorOption(Lang.OPTIONS_GAME_PERFECT, _settings.judgeColors[1]);
            initColorOption(Lang.OPTIONS_GAME_GOOD, _settings.judgeColors[2]);
            initColorOption(Lang.OPTIONS_GAME_AVERAGE, _settings.judgeColors[3]);
            initColorOption(Lang.OPTIONS_GAME_MISS, _settings.judgeColors[4]);
            initColorOption(Lang.OPTIONS_GAME_BOO, _settings.judgeColors[5]);

            initColorOption(Lang.OPTIONS_GAME_COLOR_1, _settings.gameColors[0]);
            initColorOption(Lang.OPTIONS_GAME_COLOR_2, _settings.gameColors[1]);
            initColorOption(Lang.OPTIONS_GAME_COLOR_3, _settings.gameColors[4]);

            initColorOption(Lang.OPTIONS_NORMAL_COMBO, _settings.comboColors[0]);
            initSelectableColorOption(Lang.OPTIONS_FC_COMBO, _settings.comboColors[1], _settings.enableComboColors[1]);
            initSelectableColorOption(Lang.OPTIONS_AAA_COMBO, _settings.comboColors[2], _settings.enableComboColors[2]);
            initSelectableColorOption(Lang.OPTIONS_SDG_COMBO, _settings.comboColors[3], _settings.enableComboColors[3]);
            initSelectableColorOption(Lang.OPTIONS_BLACKFLAG_COMBO, _settings.comboColors[4], _settings.enableComboColors[4]);
            initSelectableColorOption(Lang.OPTIONS_AVFLAG_COMBO, _settings.comboColors[5], _settings.enableComboColors[5]);
            initSelectableColorOption(Lang.OPTIONS_BOOFLAG_COMBO, _settings.comboColors[6], _settings.enableComboColors[6]);
            initSelectableColorOption(Lang.OPTIONS_MISSFLAG_COMBO, _settings.comboColors[7], _settings.enableComboColors[7]);

            _optionRawGoodTracker.text = _settings.rawGoodTracker.toString();
        }

        private function onAmazingJudgeColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_AMAZING]);
            _settings.judgeColors[0] = newColor;
        }

        private function onAmazingJudgeColorReset():void
        {
            _settings.judgeColors[0] = DEFAULT_OPTIONS.settings.judgeColors[0];
            setValues();
        }

        private function onPerfectJudgeColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_PERFECT]);
            _settings.judgeColors[1] = newColor;
        }

        private function onPerfectJudgeColorReset():void
        {
            _settings.judgeColors[1] = DEFAULT_OPTIONS.settings.judgeColors[1];
            setValues();
        }

        private function onGoodJudgeColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_GOOD]);
            _settings.judgeColors[2] = newColor;
        }

        private function onGoodJudgeColorReset():void
        {
            _settings.judgeColors[2] = DEFAULT_OPTIONS.settings.judgeColors[2];
            setValues();
        }

        private function onAverageJudgeColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_AVERAGE]);
            _settings.judgeColors[3] = newColor;
        }

        private function onAverageJudgeColorReset():void
        {
            _settings.judgeColors[3] = DEFAULT_OPTIONS.settings.judgeColors[3];
            setValues();
        }

        private function onMissJudgeColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_MISS]);
            _settings.judgeColors[4] = newColor;
        }

        private function onMissJudgeColorReset():void
        {
            _settings.judgeColors[4] = DEFAULT_OPTIONS.settings.judgeColors[4];
            setValues();
        }

        private function onBooJudgeColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_BOO]);
            _settings.judgeColors[5] = newColor;
        }

        private function onBooJudgeColorReset():void
        {
            _settings.judgeColors[5] = DEFAULT_OPTIONS.settings.judgeColors[5];
            setValues();
        }

        private function onGameAColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_COLOR_1]);
            _settings.gameColors[0] = newColor;
            _settings.gameColors[2] = ColorUtil.darkenColor(newColor, 0.27);
        }

        private function onGameAColorReset():void
        {
            _settings.gameColors[0] = DEFAULT_OPTIONS.settings.gameColors[0];
            _settings.gameColors[2] = ColorUtil.darkenColor(DEFAULT_OPTIONS.settings.gameColors[0], 0.27);
            setValues();
        }

        private function onGameBColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_COLOR_2]);
            _settings.gameColors[1] = newColor;
            _settings.gameColors[3] = ColorUtil.darkenColor(newColor, 0.08);
        }

        private function onGameBColorReset():void
        {
            _settings.gameColors[0] = DEFAULT_OPTIONS.settings.gameColors[0];
            _settings.gameColors[3] = ColorUtil.brightenColor(DEFAULT_OPTIONS.settings.gameColors[1], 0.08);
            setValues();
        }

        private function onGameCColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_GAME_COLOR_3]);
            _settings.gameColors[4] = newColor;
        }

        private function onGameCColorReset():void
        {
            _settings.gameColors[4] = DEFAULT_OPTIONS.settings.gameColors[4];
            setValues();
        }

        private function onNormalComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_NORMAL_COMBO]);
            _settings.comboColors[0] = newColor;
        }

        private function onNormalComboColorReset():void
        {
            _settings.comboColors[0] = DEFAULT_OPTIONS.settings.comboColors[0];
            setValues();
        }

        private function onFCComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_FC_COMBO]);
            _settings.comboColors[1] = newColor;
        }

        private function onFCComboColorReset():void
        {
            _settings.comboColors[1] = DEFAULT_OPTIONS.settings.comboColors[1];
            setValues();
        }

        private function onFCComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[1] = !_settings.enableComboColors[1];
            checkOption(e);
        }

        private function onAAAComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_AAA_COMBO]);
            _settings.comboColors[2] = newColor;
        }

        private function onAAAComboColorReset():void
        {
            _settings.comboColors[2] = DEFAULT_OPTIONS.settings.comboColors[2];
            setValues();
        }

        private function onAAAComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[2] = !_settings.enableComboColors[2];
            checkOption(e);
        }

        private function onSDGComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_SDG_COMBO]);
            _settings.comboColors[3] = newColor;
        }

        private function onSDGComboColorReset():void
        {
            _settings.comboColors[3] = DEFAULT_OPTIONS.settings.comboColors[2];
            setValues();
        }

        private function onSDGComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[2] = !_settings.enableComboColors[2];
            checkOption(e);
        }

        private function onBlackflagComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_BLACKFLAG_COMBO]);
            _settings.comboColors[4] = newColor;
        }

        private function onBlackflagComboColorReset():void
        {
            _settings.comboColors[4] = DEFAULT_OPTIONS.settings.comboColors[4];
            setValues();
        }

        private function onBlackflagComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[4] = !_settings.enableComboColors[4];
            checkOption(e);
        }

        private function onAvflagComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_AVFLAG_COMBO]);
            _settings.comboColors[5] = newColor;
        }

        private function onAvflagComboColorReset():void
        {
            _settings.comboColors[5] = DEFAULT_OPTIONS.settings.comboColors[5];
            setValues();
        }

        private function onAvflagComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[5] = !_settings.enableComboColors[5];
            checkOption(e);
        }

        private function onBooflagComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_BOOFLAG_COMBO]);
            _settings.comboColors[6] = newColor;
        }

        private function onBooflagComboColorReset():void
        {
            _settings.comboColors[6] = DEFAULT_OPTIONS.settings.comboColors[6];
            setValues();
        }

        private function onBooflagComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[6] = !_settings.enableComboColors[6];
            checkOption(e);
        }

        private function onMissflagComboColorChanged(e:Event):void
        {
            const newColor:int = changeColor(e, _colorOptions[Lang.OPTIONS_MISSFLAG_COMBO]);
            _settings.comboColors[4] = newColor;
        }

        private function onMissflagComboColorReset():void
        {
            _settings.comboColors[7] = DEFAULT_OPTIONS.settings.comboColors[7];
            setValues();
        }

        private function onMissflagComboColorEnabled(e:MouseEvent):void
        {
            _settings.enableComboColors[7] = !_settings.enableComboColors[7];
            checkOption(e);
        }

        public function onRawGoodsTrackerChanged(e:Event):void
        {
            _settings.rawGoodTracker = (e.target as ValidatedText).validate(0, 0);
        }
    }
}
