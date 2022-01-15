package game.controls
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;
    import classes.Language;

    public class Score extends Sprite
    {

        private var field:TextField;

        public function Score()
        {
            field = new TextField();
            field.defaultTextFormat = new TextFormat(Language.UNI_FONT_NAME, 25, 0xFFFFFF, false);
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.embedFonts = true;
            field.selectable = false;
            field.autoSize = TextFieldAutoSize.CENTER;
            field.x = 0;
            field.y = 0;
            field.text = "0";
            addChild(field);
        }

        public function update(score:int):void
        {
            field.text = score.toString();
        }
    }
}
