package classes.ui
{

    import classes.ui.ValidatedText;
    import classes.ui.ColorField;
    import classes.ui.BoxButton;
    import com.flashfla.utils.StringUtil;
    import flash.events.Event;

    public class ColorOption
    {
        private var _textField:ValidatedText;
        private var _colorDisplay:ColorField;
        private var _resetButton:BoxButton;

        public function ColorOption(textField:ValidatedText, colorDisplay:ColorField, resetButton:BoxButton):void
        {
            _textField = textField;
            _colorDisplay = colorDisplay;
            _resetButton = resetButton;
        }

        public function get textField():ValidatedText
        {
            return _textField;
        }

        public function get colorDisplay():ColorField
        {
            return _colorDisplay;
        }

        public function get color():int
        {
            return _colorDisplay.color;
        }

        public function set color(color:int):void
        {
            if (color != _colorDisplay.color)
                _colorDisplay.color = color;

            _textField.text = "#" + StringUtil.pad(color.toString(16).substr(0, 6), 6, "0", StringUtil.STR_PAD_LEFT);
            _textField.validate(0, 0);
        }

        public function get resetButton():BoxButton
        {
            return _resetButton;
        }
    }
}
