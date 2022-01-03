package classes.ui
{
    import com.bit101.components.ComboBox;
    import flash.display.Sprite;

    public class NoteColorOption
    {
        public var defaultSprite:Sprite;
        public var replacedSprite:Sprite;
        private var _comboBox:ComboBox;

        public function NoteColorOption(defaultSprite:Sprite, replacedSprite:Sprite, comboBox:ComboBox):void
        {
            this.defaultSprite = defaultSprite;
            this.replacedSprite = replacedSprite;
            _comboBox = comboBox;
        }

        public function get comboBox():ComboBox
        {
            return _comboBox;
        }
    }
}
