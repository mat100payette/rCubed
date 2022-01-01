package popups.settings
{
    import classes.UserSettings;
    import classes.ui.MouseTooltip;
    import classes.ui.ScrollPaneContent;
    import classes.ui.Text;
    import game.GameOptions;
    import flash.geom.Point;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.DisplayObject;
    import classes.ui.BoxCheck;
    import classes.ui.BoxSlider;
    import classes.ui.ValidatedText;

    public class SettingsTabBase
    {
        protected static const DEFAULT_OPTIONS:GameOptions = new GameOptions(null);
        protected static const JUDGE_TITLES:Array = ["amazing", "perfect", "good", "average", "miss", "boo"];
        protected static const RECEPTOR_ROTATIONS:Array = [1, 0, 2, -1];

        public var container:ScrollPaneContent;

        protected var _parent:SettingsWindow;
        protected var _settings:UserSettings;
        protected var _options:Object = {};
        private var _hoverMessage:MouseTooltip;

        public function SettingsTabBase(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            _parent = settingsWindow;
            _settings = settings;
        }

        public function get name():String
        {
            return null;
        }

        public function openTab():void
        {

        }

        public function closeTab():void
        {
            hideTooltip();

            for (var index:int = container.numChildren - 1; index >= 0; index--)
            {
                const olditem:DisplayObject = container.getChildAt(index);

                    // TODO: Remove the listeners in a `dispose()` function on the widgets
                    //olditem.removeEventListener(MouseEvent.CLICK, clickHandler);
                    //olditem.removeEventListener(Event.CHANGE, changeHandler);
            }
        }

        public function setValues():void
        {

        }

        public function drawSeperator(container:ScrollPaneContent, x:int, w:int, y:int, a:int = 0, b:int = 0):int
        {
            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(x, y + 10 + a);
            container.graphics.lineTo(x + w, y + 10 + a);

            return 20 + a + b;
        }

        protected function setTextMaxWidth(maxWidth:Number):void
        {
            for (var i:int = 0; i < container.numChildren; i++)
            {
                const child:DisplayObject = container.getChildAt(i);
                if (child is Text)
                    child.width = maxWidth;
            }
        }

        public function displayToolTip(tx:Number, ty:Number, text:String, align:String = "left"):void
        {
            if (!_hoverMessage)
                _hoverMessage = new MouseTooltip();
            _hoverMessage.message = text;

            const messagePoint:Point = _parent.globalToLocal(_parent.pane.content.localToGlobal(new Point(tx, ty)));

            switch (align)
            {
                default:
                case "left":
                    _hoverMessage.x = messagePoint.x;
                    _hoverMessage.y = messagePoint.y;
                    break;
                case "right":
                    _hoverMessage.x = messagePoint.x - _hoverMessage.width;
                    _hoverMessage.y = messagePoint.y;
                    break;
            }

            _parent.addChild(_hoverMessage);
        }

        public function hideTooltip():void
        {
            if (_hoverMessage && _parent.contains(_hoverMessage))
                _parent.removeChild(_hoverMessage);
        }
    }
}
