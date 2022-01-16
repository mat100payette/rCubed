package game.controls
{
    import com.greensock.TweenLite;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.geom.Matrix;
    import flash.utils.getTimer;
    import AachenLight;

    public class Judge extends Sprite
    {
        private var _indexes:Object = Judge_Tweens.judge_indexes;
        private var _labelDesc:Array = [];
        private var _field:TextField;
        private var _freeze:Boolean = false;

        private var _lastScore:Number = 100;
        private var _frame:uint = 0;
        private var _subframe:Number = 0;
        private var _lastTime:Number = 0;
        private var _sX:Number = 0;

        private var _animationSpeed:Number = 1;
        private var _displayPerfects:Boolean;
        private var _isEditor:Boolean;


        public function Judge(displayPerfects:Boolean, displayAnimations:Boolean, animationSpeed:Number, colors:Array, isEditor:Boolean)
        {
            _displayPerfects = displayPerfects;
            _isEditor = isEditor;

            if (!displayAnimations)
                _indexes = Judge_Tweens.judge_indexes_static;

            animationSpeed = animationSpeed;

            _labelDesc[100] = {color: colors[0], title: "AMAZING!!!"};
            _labelDesc[50] = {color: colors[1], title: "PERFECT!"};
            _labelDesc[25] = {color: colors[2], title: "GOOD"};
            _labelDesc[5] = {color: colors[3], title: "AVERAGE"};
            _labelDesc[-5] = {color: colors[5], title: "BOO!!"};
            _labelDesc[-10] = {color: colors[4], title: "MISS!"};

            const textFormat:TextFormat = new TextFormat(new AachenLight().fontName, 42, 0xffffff, true);

            _field = new TextField();
            _field.defaultTextFormat = textFormat;
            _field.antiAliasType = AntiAliasType.NORMAL;
            _field.embedFonts = true;
            _field.selectable = false;
            _field.autoSize = TextFieldAutoSize.CENTER;
            _field.mouseEnabled = false;
            _field.doubleClickEnabled = false;
            _field.mouseWheelEnabled = false;
            _field.tabEnabled = false;
            _field.x = 0;
            _field.y = -30;
            _field.visible = true;
            _field.alpha = 1;
            _field.cacheAsBitmapMatrix = new Matrix();
            addChild(_field)

            //updateDisplay();

            mouseChildren = false;
            doubleClickEnabled = false;
            tabEnabled = false;
        }

        public function hideJudge():void
        {
            _frame = 0;
            _subframe = 0;
            alpha = 0;
            visible = false;
        }

        public function showJudge(newScore:int, doFreeze:Boolean = false):void
        {
            // Hide Perfect/Amazing Judge
            if (!_isEditor && newScore >= 50 && !_displayPerfects)
                return;

            _lastScore = newScore;

            _field.x = _sX;
            _field.textColor = _labelDesc[newScore].color;
            _field.text = _labelDesc[newScore].title;
            _sX = _field.x;
            _frame = 0;
            _subframe = 0;
            _freeze = doFreeze;
            _lastTime = getTimer();

            updateDisplay();
        }

        public function updateJudge(e:Event):void
        {
            if (!_freeze && alpha > 0)
            {
                var curTime:Number = getTimer();
                _subframe += ((curTime - _lastTime) / 30) * _animationSpeed; // Animation keys are 30fps.
                while (int(_subframe) > _frame)
                {
                    _frame++;
                    updateDisplay();
                    visible = true;
                }
                _lastTime = curTime;
            }
        }

        private function updateDisplay():void
        {
            if (_freeze && _frame > 0)
                return;

            if (_indexes[_lastScore][_frame])
            {
                var i:Array = _indexes[_lastScore][_frame];

                _field.x = _sX + i[1];
                _field.y = (i[2] - 30);

                scaleX = i[3];
                scaleY = i[4];
                alpha = i[5];

                if (_freeze)
                    return;

                // Tween
                var next:Array = _indexes[_lastScore][_frame + i[6]]; // Next Frame
                if (i[0] > 0 && next != null)
                {
                    TweenLite.to(this, i[0] / _animationSpeed, {scaleX: next[3], scaleY: next[4], alpha: next[5]});
                    TweenLite.to(_field, i[0] / _animationSpeed, {x: _sX + next[1], y: (next[2] - 30)});
                }
            }
        }
    }
}
