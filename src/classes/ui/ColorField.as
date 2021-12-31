package classes.ui
{
    import assets.settings.colorPickerBMP;
    import flash.display.Bitmap;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class ColorField extends Sprite
    {
        private var _color:int = 0x000000;
        private var _width:Number;
        private var _height:Number;

        private var _picker:Sprite;
        private var _bmp:Bitmap;
        private var _pickerColor:int = 0x000000;
        private var _pickerColorExample:Sprite;

        private var _listener:Function = null;

        public function ColorField(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, defaultColor:int = 0x000000, dWidth:Number = 75, dHeight:Number = 20, listener:Function = null)
        {
            if (parent)
                parent.addChild(this);

            x = xpos;
            y = ypos;

            _color = _pickerColor = defaultColor;
            _width = dWidth;
            _height = dHeight;

            addEventListener(MouseEvent.CLICK, e_onClick);

            buttonMode = true;
            useHandCursor = true;

            draw();

            if (listener != null)
            {
                _listener = listener;
                addEventListener(Event.CHANGE, listener);
            }
        }

        private function e_onClick(e:MouseEvent):void
        {
            if (!parent || !parent.contains(this))
                return;

            if (_picker == null)
            {
                _picker = new Sprite();
                _bmp = new Bitmap(new colorPickerBMP());
                _bmp.x = _bmp.y = 1;
                _picker.addChild(_bmp);

                _pickerColorExample = new Sprite();
                _pickerColorExample.x = 1;
                _pickerColorExample.y = _bmp.y + _bmp.height + 1;
                updateExampleColor();
                _picker.addChild(_pickerColorExample);

                _picker.graphics.lineStyle(1, 0xffffff, 1, false);
                _picker.graphics.beginFill(0xffffff, 1);
                _picker.graphics.drawRect(0, 0, _bmp.width + 1, _pickerColorExample.y + _pickerColorExample.height);
                _picker.graphics.endFill();
            }

            if (parent.contains(_picker))
                removePicker();
            else
            {
                _picker.addEventListener(MouseEvent.MOUSE_MOVE, e_pickerMove);
                _picker.addEventListener(MouseEvent.MOUSE_OUT, e_pickerOut);

                stage.addEventListener(MouseEvent.CLICK, e_pickerClick, true, 100);

                const stagePoint:Point = localToGlobal(new Point(width + 5, 0));
                stagePoint.x = Math.max(0, Math.min(stagePoint.x, Main.GAME_WIDTH - _picker.width - 5));
                stagePoint.y = Math.max(0, Math.min(stagePoint.y, Main.GAME_HEIGHT - _picker.height - 5));

                _picker.x = stagePoint.x;
                _picker.y = stagePoint.y;

                stage.addChild(_picker);
            }
        }

        private function draw():void
        {
            graphics.clear();
            graphics.lineStyle(0, 0, 0);
            graphics.beginFill(_color);
            graphics.drawRect(1, 1, _width - 1, _height - 1);
            graphics.endFill();
            graphics.lineStyle(1, 0xFFFFFF, 0.5);
            graphics.drawRect(0, 0, _width, _height);
        }

        public function get color():int
        {
            return _color;
        }

        public function set color(newColor:int):void
        {
            _color = _pickerColor = newColor;
            draw();
        }

        private function removePicker():void
        {
            if (!stage || !stage.contains(_picker))
                return;

            stage.removeChild(_picker);
            _picker.removeEventListener(MouseEvent.MOUSE_OUT, e_pickerOut);
            _picker.removeEventListener(MouseEvent.MOUSE_MOVE, e_pickerMove);
            stage.removeEventListener(MouseEvent.CLICK, e_pickerClick, true);
        }

        private function updateExampleColor():void
        {
            if (!_pickerColorExample || !_bmp)
                return;

            _pickerColorExample.graphics.clear();
            _pickerColorExample.graphics.lineStyle(0, 0, 0);
            _pickerColorExample.graphics.beginFill(_pickerColor);
            _pickerColorExample.graphics.drawRect(0, 0, _bmp.width, 30);
            _pickerColorExample.graphics.endFill();
        }

        private function e_pickerOut(e:MouseEvent):void
        {
            _pickerColor = color;
            updateExampleColor();
        }

        private function e_pickerMove(e:MouseEvent):void
        {
            const newColor:uint = _bmp.bitmapData.getPixel(_bmp.mouseX, _bmp.mouseY);
            const newColorS:String = newColor.toString(16);
            _pickerColor = newColor;
            updateExampleColor();
        }

        private function e_pickerClick(e:MouseEvent):void
        {
            e.preventDefault();
            removePicker();
            if (e.target == _picker)
            {
                color = _pickerColor;
                dispatchEvent(new Event(Event.CHANGE));
            }
        }
    }
}
