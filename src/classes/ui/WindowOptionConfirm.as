package classes.ui
{
    import classes.Language;
    import classes.ui.BoxButton;
    import classes.ui.Text;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.text.TextFormatAlign;

    public class WindowOptionConfirm extends Sprite
    {
        private var _lang:Language = Language.instance;

        private var _properties:WindowState;
        private var _onCancel:Function;

        private var _previousX:int;
        private var _previousY:int;
        private var _previousWidth:int;
        private var _previousHeight:int;

        private var _confirmTimer:Timer;

        private var _windowText:Text;
        private var _windowTimerText:Text;
        private var _confirmBtn:BoxButton;

        public function WindowOptionConfirm(properties:WindowState, onCancel:Function):void
        {
            _properties = properties;
            _onCancel = onCancel;

            _previousX = properties.x;
            _previousY = properties.y;
            _previousWidth = properties.width;
            _previousHeight = properties.height;

            graphics.lineStyle(0, 0, 0);
            graphics.beginFill(0, 0.95);
            graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            graphics.endFill();

            _confirmTimer = new Timer(1000, 10);
            _confirmTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
            _confirmTimer.start();

            _windowText = new Text(this, 0, 200, _lang.string(Lang.OPTIONS_WINDOW_SETTINGS_CONFIRM_TEXT), 24);
            _windowText.setAreaParams(Main.GAME_WIDTH, 30, TextFormatAlign.CENTER);

            _windowTimerText = new Text(this, 0, 250, "10", 38);
            _windowTimerText.setAreaParams(Main.GAME_WIDTH, 30, TextFormatAlign.CENTER);

            _confirmBtn = new BoxButton(this, Main.GAME_WIDTH / 2 - 50, 400, 100, 30, _lang.string(Lang.OPTIONS_WINDOW_SETTINGS_CONFIRM), 12, onConfirmClick);
        }

        private function onTimerTick(e:TimerEvent):void
        {
            _windowTimerText.text = (_confirmTimer.repeatCount - _confirmTimer.currentCount).toString();

            if (_confirmTimer.currentCount >= _confirmTimer.repeatCount)
                onCancelClick();
        }

        private function onConfirmClick(e:Event):void
        {
            _confirmTimer.stop();
            parent.removeChild(this);
        }

        private function onCancelClick():void
        {
            _properties.x = _previousX;
            _properties.y = _previousY;
            _properties.width = _previousWidth;
            _properties.height = _previousHeight;

            _confirmTimer.stop();
            parent.removeChild(this);

            _onCancel();
        }
    }
}
