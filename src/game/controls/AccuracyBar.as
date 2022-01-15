package game.controls
{
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;

    public class AccuracyBar extends Sprite
    {
        private static var CLEAR_TRANSFORM:ColorTransform = new ColorTransform(1, 1, 1, 0);
        private static var ADJUST_TRANSFORM:ColorTransform = new ColorTransform(1, 1, 1, 0.95)

        private const LINE_WIDTH:int = 3;

        private var _judgeWindow:Array;

        private var _renderTarget:Shape;
        private var _displayBM:Bitmap;
        private var _displayBMD:BitmapData;
        private var _alphaArea:Rectangle;

        private var _fadeTick:int = 33;
        private var _fadeTimer:int = 0;

        private var _boundLower:int = -117;
        private var _boundUpper:int = 117;
        private var _boundRange:int = 234;

        private var _width:Number = 200;
        private var _height:Number = 16;

        private var _colors:Array;

        public function AccuracyBar(colors:Array, judgeWindow:Array):void
        {
            _judgeWindow = judgeWindow;

            updateJudge();

            // Parse Colors
            _colors = [];
            _colors[100] = colors[0];
            _colors[50] = colors[1];
            _colors[25] = colors[2];
            _colors[5] = colors[3];

            // Setup ColorTransform for Fade
            _renderTarget = new Shape();
            _alphaArea = new Rectangle(0, 0, _width, _height);

            draw();
        }

        public function onScoreSignal(_score:int, _judgeMS:int):void
        {
            // Judge Accuracy Lines
            _renderTarget.graphics.clear();

            _renderTarget.graphics.beginFill(_colors[_score], 1);
            _renderTarget.graphics.drawRect((_judgeMS / _boundRange * (_width - LINE_WIDTH)) + (_width / 2), 0, LINE_WIDTH, _height);
            _renderTarget.graphics.endFill();

            _displayBMD.draw(_renderTarget);
            _displayBMD.colorTransform(_alphaArea, ADJUST_TRANSFORM);
        }

        public function onResetSignal():void
        {
            _displayBMD.colorTransform(_alphaArea, CLEAR_TRANSFORM);
        }

        /**
         * Updates Judge Region Min Time, Max Time, and Total Size
         * either from the default judge, or a custom set judge.
         */
        public function updateJudge():void
        {
            // Get Judge Window
            var judge:Array = Constant.JUDGE_WINDOW;
            if (_judgeWindow)
                judge = _judgeWindow;

            // Get Judge Window Size
            for (var jn:int = 0; jn < judge.length; jn++)
            {
                var jni:Object = judge[jn];
                if (jni.t < _boundLower)
                    _boundLower = jni.t;

                if (jni.t > _boundUpper)
                    _boundUpper = jni.t;
            }

            _boundRange = _boundUpper - _boundLower;
        }

        public function draw():void
        {
            this.graphics.clear();

            this.graphics.lineStyle(1, 0xFFFFFF, 0.13);
            this.graphics.beginFill(0xFFFFFF, 0.02);
            this.graphics.drawRect(-(_width / 2), -(_height / 2), _width, _height);
            this.graphics.endFill();

            this.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            this.graphics.moveTo(0, -(_height / 2) - 8);
            this.graphics.lineTo(0, (_height / 2) + 8);

            drawJudgeRegions();

            // Setup Bitmap for Display
            if (_displayBM != null)
                removeChild(_displayBM);

            _displayBMD = new BitmapData(_width, _height, true, 0)
            _displayBM = new Bitmap(_displayBMD);

            _displayBM.x = -(_width / 2);
            _displayBM.y = -(_height / 2);

            addChild(_displayBM);
        }

        public function drawJudgeRegions():void
        {
            // Get Judge Window
            var judge:Array = Constant.JUDGE_WINDOW;
            if (_judgeWindow)
                judge = _judgeWindow;

            this.graphics.lineStyle(1, 0xFFFFFF, 0.13);

            for (var jn:int = 1; jn < judge.length - 1; jn++)
            {
                var dX:Number = _width * ((judge[jn]["t"] - _boundLower) / _boundRange);
                this.graphics.moveTo(-(_width / 2) + dX, -(_height / 2) + 1);
                this.graphics.lineTo(-(_width / 2) + dX, (_height / 2) - 1);
            }
        }

        override public function set width(val:Number):void
        {
            _width = val;
            _alphaArea.width = _width;
            draw();
        }

        override public function set height(val:Number):void
        {
            _height = val;
            _alphaArea.height = _height;
            draw();
        }
    }

}
