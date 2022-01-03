package classes.ui
{

    public class NoteColorComboBoxItem
    {
        private var _label:String;
        private var _colorName:String;

        public function NoteColorComboBoxItem(label:String, colorName:String):void
        {
            _label = label;
            _colorName = colorName;
        }

        public function get label():String
        {
            return _label;
        }

        public function get colorName():String
        {
            return _colorName;
        }
    }
}
