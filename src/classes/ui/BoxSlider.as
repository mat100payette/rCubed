package classes.ui
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    public class BoxSlider extends Sprite
    {
        public static const TEXT_ALIGN_RIGHT:int = 0;
        public static const TEXT_ALIGN_BOTTOM:int = 1;

        private var _width:Number;
        private var _height:Number;
        private var _slider:Sprite;
        private var _slideValue:Number = 0;
        private var _minValue:Number = 0;
        private var _maxValue:Number = 1;

        private var _valueText:Text;
        private var _valueTextTransformer:Function;
        private var _onSlide:Function;

        public function BoxSlider(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, width:int = 0, height:int = 0, alignment:int = TEXT_ALIGN_RIGHT, onSlide:Function = null, valueTextTransformer:Function = null)
        {

            const textXOff:int = alignment == TEXT_ALIGN_RIGHT ? width + 5 : 0;
            const textYOff:int = alignment == TEXT_ALIGN_RIGHT ? -6 : 10;
            _valueText = new Text(parent, xpos + textXOff, ypos + textYOff);
            _valueTextTransformer = valueTextTransformer;

            if (parent)
            {
                parent.addChild(this);
                parent.addChild(_valueText);
            }

            x = xpos;
            y = ypos;

            _width = width;
            _height = height;

            init();

            if (onSlide != null)
            {
                _onSlide = onSlide;
                addEventListener(Event.CHANGE, _onSlide);
            }
        }

        protected function init():void
        {
            graphics.lineStyle(1, 0xFFFFFF, 0.2);
            graphics.moveTo(0, _height / 2);
            graphics.lineTo(_width, _height / 2);

            _slider = new Sprite();
            _slider.graphics.lineStyle(1, 0xFFFFFF, 0.55);
            _slider.graphics.beginFill(0xFFFFFF, 0.2);
            _slider.graphics.drawRect(0, 0, 10, _height);
            _slider.graphics.endFill();
            _slider.buttonMode = true;
            _slider.useHandCursor = true;
            _slider.mouseChildren = false;
            _slider.addEventListener(MouseEvent.MOUSE_DOWN, e_startDrag);

            addChild(_slider);
        }

        private function e_startDrag(e:MouseEvent):void
        {
            _slider.startDrag(false, new Rectangle(0, 0, _width - _slider.width, 0));
            stage.addEventListener(MouseEvent.MOUSE_MOVE, e_dragMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, e_stopDrag);
        }

        private function e_dragMove(e:MouseEvent):void
        {
            setSliderValue((_slider.x / (_width - _slider.width)) * valueRange + _minValue);

            dispatchEvent(new Event(Event.CHANGE));
        }

        private function e_stopDrag(e:MouseEvent):void
        {
            _slider.stopDrag();
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, e_dragMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, e_stopDrag);

            setSliderValue((_slider.x / (_width - _slider.width)) * valueRange + _minValue);
        }

        /**
         * Returns the slider value capped between the min and max values.
         */
        public function get slideValue():Number
        {
            return Math.max(Math.min(_slideValue, _maxValue), _minValue);
        }

        private function setSliderValue(value:Number):void
        {
            _slideValue = value;
            _valueText.text = _valueTextTransformer != null ? _valueTextTransformer(_slideValue) : _slideValue.toString();
        }

        public function set slideValue(value:Number):void
        {
            setSliderValue(value);
            const moveVal:Number = (slideValue - minValue) / valueRange;
            _slider.x = (_width - _slider.width) * moveVal;
        }

        public function get valueRange():Number
        {
            return _maxValue - _minValue;
        }

        public function get minValue():Number
        {
            return _minValue;
        }

        public function set minValue(val:Number):void
        {
            _minValue = val;
        }

        public function get maxValue():Number
        {
            return _maxValue;
        }

        public function set maxValue(val:Number):void
        {
            _maxValue = val;
        }
    }
}
