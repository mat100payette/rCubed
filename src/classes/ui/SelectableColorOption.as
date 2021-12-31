package classes.ui
{

    import classes.ui.ValidatedText;
    import classes.ui.ColorField;
    import classes.ui.BoxButton;
    import classes.ui.BoxCheck;

    public class SelectableColorOption extends ColorOption
    {
        private var _enabledCheckBox:BoxCheck;

        public function SelectableColorOption(textField:ValidatedText, colorDisplay:ColorField, resetButton:BoxButton, enabledCheckBox:BoxCheck):void
        {
            super(textField, colorDisplay, resetButton);
            _enabledCheckBox = enabledCheckBox;
        }

        public function set checked(checked:Boolean):void
        {
            _enabledCheckBox.checked = checked;
        }
    }
}
