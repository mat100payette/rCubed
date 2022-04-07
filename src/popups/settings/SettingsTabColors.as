package popups.settings
{
    import classes.Language;
    import classes.UserSettings;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;
    import classes.ui.ColorField;
    import classes.ui.ColorOption;
    import classes.ui.SelectableColorOption;
    import classes.ui.Text;
    import classes.ui.ValidatedText;
    import events.actions.gameplay.SetRawGoodTrackerEvent;
    import events.actions.gameplay.colors.GameAColorChangedEvent;
    import events.actions.gameplay.colors.GameBColorChangedEvent;
    import events.actions.gameplay.colors.GameCColorChangedEvent;
    import events.actions.gameplay.colors.SetAAAComboColorEvent;
    import events.actions.gameplay.colors.SetAvflagComboColorEvent;
    import events.actions.gameplay.colors.SetBlackflagComboColorEvent;
    import events.actions.gameplay.colors.SetBooflagComboColorEvent;
    import events.actions.gameplay.colors.SetFCComboColorEvent;
    import events.actions.gameplay.colors.SetGameAColorEvent;
    import events.actions.gameplay.colors.SetGameBColorEvent;
    import events.actions.gameplay.colors.SetGameCColorEvent;
    import events.actions.gameplay.colors.SetJudgeColorEvent;
    import events.actions.gameplay.colors.SetMissflagComboColorEvent;
    import events.actions.gameplay.colors.SetNormalComboColorEvent;
    import events.actions.gameplay.colors.SetSDGComboColorEvent;
    import events.actions.gameplay.colors.ToggleAAAComboColorEvent;
    import events.actions.gameplay.colors.ToggleAvflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleBlackflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleBooflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleFCComboColorEvent;
    import events.actions.gameplay.colors.ToggleMissflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleSDGComboColorEvent;
    import flash.events.Event;
    import flash.text.TextFormatAlign;
    import state.AppState;

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

        public function SettingsTabColors(settingsWindow:SettingsWindow):void
        {
            super(settingsWindow);

            addEventListener(GameAColorChangedEvent.EVENT_TYPE, updateGameAColorUI);
            addEventListener(GameBColorChangedEvent.EVENT_TYPE, updateGameBColorUI);
            addEventListener(GameCColorChangedEvent.EVENT_TYPE, updateGameCColorUI);
        }

        override public function get name():String
        {
            return "colors";
        }

        private function getSelectedJudgeColor(e:Event, option:ColorOption):int
        {
            var newColor:int;

            if (e.target is ColorField)
                newColor = (e.target as ColorField).color;
            else if (e.target is ValidatedText)
                newColor = (e.target as ValidatedText).validate(0, 0);
            else
                newColor = option.color;

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
            var settings:UserSettings = AppState.instance.auth.user.settings;

            _optionAmazingJudge.color = settings.judgeColors[0];
            _optionPerfectJudge.color = settings.judgeColors[1];
            _optionGoodJudge.color = settings.judgeColors[2];
            _optionAverageJudge.color = settings.judgeColors[3];
            _optionMissJudge.color = settings.judgeColors[4];
            _optionBooJudge.color = settings.judgeColors[5];

            _optionGameColor1.color = settings.gameColors[0];
            _optionGameColor2.color = settings.gameColors[1];
            _optionGameColor3.color = settings.gameColors[4];

            _optionNormalCombo.color = settings.comboColors[0];
            _optionFCCombo.color = settings.comboColors[1];
            _optionFCCombo.checked = settings.enableComboColors[1];
            _optionAAACombo.color = settings.comboColors[2];
            _optionAAACombo.checked = settings.enableComboColors[2];
            _optionSDGCombo.color = settings.comboColors[3];
            _optionSDGCombo.checked = settings.enableComboColors[3];
            _optionBlackflagCombo.color = settings.comboColors[4];
            _optionBlackflagCombo.checked = settings.enableComboColors[4];
            _optionAvflagCombo.color = settings.comboColors[5];
            _optionAvflagCombo.checked = settings.enableComboColors[5];
            _optionBooflagCombo.color = settings.comboColors[6];
            _optionBooflagCombo.checked = settings.enableComboColors[6];
            _optionMissflagCombo.color = settings.comboColors[7];
            _optionMissflagCombo.checked = settings.enableComboColors[7];

            _optionRawGoodTracker.text = settings.rawGoodTracker.toString();
        }

        private function onAmazingJudgeColorChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeColorEvent(0, getSelectedJudgeColor(e, _optionAmazingJudge)));
        }

        private function onAmazingJudgeColorReset():void
        {
            dispatchEvent(new SetJudgeColorEvent(0, _defaultSettings.judgeColors[0]));
            _optionAmazingJudge.color = _defaultSettings.judgeColors[0];
        }

        private function onPerfectJudgeColorChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeColorEvent(1, getSelectedJudgeColor(e, _optionPerfectJudge)));
        }

        private function onPerfectJudgeColorReset():void
        {
            dispatchEvent(new SetJudgeColorEvent(1, _defaultSettings.judgeColors[1]));
            _optionAmazingJudge.color = _defaultSettings.judgeColors[1];
        }

        private function onGoodJudgeColorChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeColorEvent(2, getSelectedJudgeColor(e, _optionGoodJudge)));
        }

        private function onGoodJudgeColorReset():void
        {
            dispatchEvent(new SetJudgeColorEvent(2, _defaultSettings.judgeColors[2]));
            _optionAmazingJudge.color = _defaultSettings.judgeColors[2];
        }

        private function onAverageJudgeColorChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeColorEvent(3, getSelectedJudgeColor(e, _optionAverageJudge)));
        }

        private function onAverageJudgeColorReset():void
        {
            dispatchEvent(new SetJudgeColorEvent(3, _defaultSettings.judgeColors[3]));
            _optionAmazingJudge.color = _defaultSettings.judgeColors[3];
        }

        private function onMissJudgeColorChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeColorEvent(4, getSelectedJudgeColor(e, _optionMissJudge)));
        }

        private function onMissJudgeColorReset():void
        {
            dispatchEvent(new SetJudgeColorEvent(4, _defaultSettings.judgeColors[4]));
            _optionAmazingJudge.color = _defaultSettings.judgeColors[4];
        }

        private function onBooJudgeColorChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeColorEvent(5, getSelectedJudgeColor(e, _optionBooJudge)));
        }

        private function onBooJudgeColorReset():void
        {
            dispatchEvent(new SetJudgeColorEvent(5, _defaultSettings.judgeColors[5]));
            _optionAmazingJudge.color = _defaultSettings.judgeColors[5];
        }

        private function onGameAColorChanged(e:Event):void
        {
            const newColor:int = getSelectedJudgeColor(e, _optionGameColor1);
            dispatchEvent(new SetGameAColorEvent(newColor));
        }

        private function onGameAColorReset():void
        {
            dispatchEvent(new SetGameAColorEvent(_defaultSettings.gameColors[0]));
        }

        private function updateGameAColorUI():void
        {
            _optionGameColor1.color = AppState.instance.auth.user.settings.gameColors[0];
        }

        private function onGameBColorChanged(e:Event):void
        {
            const newColor:int = getSelectedJudgeColor(e, _optionGameColor2);
            dispatchEvent(new SetGameBColorEvent(newColor));
        }

        private function onGameBColorReset():void
        {
            dispatchEvent(new SetGameBColorEvent(_defaultSettings.gameColors[1]));
        }

        private function updateGameBColorUI():void
        {
            _optionGameColor2.color = AppState.instance.auth.user.settings.gameColors[1];
        }

        private function onGameCColorChanged(e:Event):void
        {
            const newColor:int = getSelectedJudgeColor(e, _optionGameColor3);
            dispatchEvent(new SetGameCColorEvent(newColor));
        }

        private function onGameCColorReset():void
        {
            dispatchEvent(new SetGameCColorEvent(_defaultSettings.gameColors[4]));
        }

        private function updateGameCColorUI():void
        {
            _optionGameColor3.color = AppState.instance.auth.user.settings.gameColors[4];
        }

        private function onNormalComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetNormalComboColorEvent(getSelectedJudgeColor(e, _optionNormalCombo)));
        }

        private function onNormalComboColorReset():void
        {
            dispatchEvent(new SetNormalComboColorEvent(_defaultSettings.comboColors[0]));
            _optionNormalCombo.color = _defaultSettings.comboColors[0];
        }

        private function onFCComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetFCComboColorEvent(getSelectedJudgeColor(e, _optionFCCombo)));
        }

        private function onFCComboColorReset():void
        {
            dispatchEvent(new SetFCComboColorEvent(_defaultSettings.comboColors[1]));
            _optionFCCombo.color = _defaultSettings.comboColors[1];
        }

        private function onFCComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleFCComboColorEvent());
        }

        private function onAAAComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetAAAComboColorEvent(getSelectedJudgeColor(e, _optionAAACombo)));
        }

        private function onAAAComboColorReset():void
        {
            dispatchEvent(new SetAAAComboColorEvent(_defaultSettings.comboColors[2]));
            _optionAAACombo.color = _defaultSettings.comboColors[2];
        }

        private function onAAAComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleAAAComboColorEvent());
        }

        private function onSDGComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetSDGComboColorEvent(getSelectedJudgeColor(e, _optionSDGCombo)));
        }

        private function onSDGComboColorReset():void
        {
            dispatchEvent(new SetSDGComboColorEvent(_defaultSettings.comboColors[3]));
            _optionSDGCombo.color = _defaultSettings.comboColors[3];
        }

        private function onSDGComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleSDGComboColorEvent());
        }

        private function onBlackflagComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetBlackflagComboColorEvent(getSelectedJudgeColor(e, _optionBlackflagCombo)));
        }

        private function onBlackflagComboColorReset():void
        {
            dispatchEvent(new SetBlackflagComboColorEvent(_defaultSettings.comboColors[4]));
            _optionBlackflagCombo.color = _defaultSettings.comboColors[4];
        }

        private function onBlackflagComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleBlackflagComboColorEvent());
        }

        private function onAvflagComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetAvflagComboColorEvent(getSelectedJudgeColor(e, _optionAvflagCombo)));
        }

        private function onAvflagComboColorReset():void
        {
            dispatchEvent(new SetAvflagComboColorEvent(_defaultSettings.comboColors[5]));
            _optionAvflagCombo.color = _defaultSettings.comboColors[5];
        }

        private function onAvflagComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleAvflagComboColorEvent());
        }

        private function onBooflagComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetBooflagComboColorEvent(getSelectedJudgeColor(e, _optionBooflagCombo)));
        }

        private function onBooflagComboColorReset():void
        {
            dispatchEvent(new SetBooflagComboColorEvent(_defaultSettings.comboColors[6]));
            _optionBooflagCombo.color = _defaultSettings.comboColors[6];
        }

        private function onBooflagComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleBooflagComboColorEvent());
        }

        private function onMissflagComboColorChanged(e:Event):void
        {
            dispatchEvent(new SetMissflagComboColorEvent(getSelectedJudgeColor(e, _optionMissflagCombo)));
        }

        private function onMissflagComboColorReset():void
        {
            dispatchEvent(new SetMissflagComboColorEvent(_defaultSettings.comboColors[7]));
            _optionMissflagCombo.color = _defaultSettings.comboColors[7];
        }

        private function onMissflagComboColorEnabled(e:Event):void
        {
            dispatchEvent(new ToggleMissflagComboColorEvent());
        }

        public function onRawGoodsTrackerChanged(e:Event):void
        {
            dispatchEvent(new SetRawGoodTrackerEvent(_optionRawGoodTracker.validate(0, 0)));
        }
    }
}
