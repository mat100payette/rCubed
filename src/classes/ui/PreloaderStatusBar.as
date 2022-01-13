package classes.ui
{
    import flash.text.TextField;
    import flash.text.AntiAliasType;
    import flash.text.TextFieldAutoSize;
    import flash.display.Sprite;

    public class PreloaderStatusBar extends Sprite implements IDisposable
    {
        private var _textBaseY:int;
        private var _labelSpacing:int;

        public var text:TextField;
        public var bar:ProgressBar;

        public function PreloaderStatusBar(x:int, y:int, width:int, labelSpacing:int = 88)
        {
            bar = new ProgressBar(x + 2, y, width, 20);
            bar.setOnComplete(dispose);

            _labelSpacing = labelSpacing;
            _textBaseY = y - bar.height;

            text = new TextField();
            text.x = x;
            text.y = _textBaseY - labelSpacing;
            text.width = width;
            text.selectable = false;
            text.embedFonts = true;
            text.antiAliasType = AntiAliasType.ADVANCED;
            text.autoSize = TextFieldAutoSize.LEFT;
            text.defaultTextFormat = Constant.TEXT_FORMAT;

            addChild(text);
            addChild(bar);
        }

        public function set htmlText(htmlText:String):void
        {
            text.htmlText = htmlText;
            text.y = _textBaseY - _labelSpacing - text.textHeight;
        }

        public function dispose():void
        {
            removeChild(text);
            removeChild(bar);
        }
    }
}
