package classes.ui
{
    import flash.text.TextField;
    import flash.text.AntiAliasType;
    import flash.text.TextFieldAutoSize;
    import flash.display.Sprite;

    public class PreloaderStatusBar extends Sprite
    {
        public var text:TextField;
        public var bar:ProgressBar;

        public function PreloaderStatusBar(x:int, y:int, width:int, labelSpacing:int = 88)
        {
            text = new TextField();
            text.x = x;
            text.y = y - labelSpacing;
            text.width = width;
            text.selectable = false;
            text.embedFonts = true;
            text.antiAliasType = AntiAliasType.ADVANCED;
            text.autoSize = TextFieldAutoSize.LEFT;
            text.defaultTextFormat = Constant.TEXT_FORMAT;

            bar = new ProgressBar(x + 2, y, width, 20);
            bar.setOnComplete(onStatusComplete);

            addChild(text);
            addChild(bar);
        }

        private function onStatusComplete():void
        {
            removeChild(bar);
        }
    }
}
