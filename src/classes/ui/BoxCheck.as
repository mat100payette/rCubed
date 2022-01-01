package classes.ui
{
    import assets.GameBackgroundColor;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;

    dynamic public class BoxCheck extends Sprite
    {
        // Display
        private var _width:Number = 14;
        private var _height:Number = 14;
        private var _highlight:Boolean = false;
        private var _active:Boolean = false;

        private var _onClick:Function = null;

        public function BoxCheck(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, onClick:Function = null):void
        {
            if (parent)
                parent.addChild(this);

            //- Set Button Mode
            mouseChildren = false;
            useHandCursor = true;
            buttonMode = true;

            //- Set position
            x = xpos;
            y = ypos;

            //- Set click event listener
            if (onClick != null)
            {
                _onClick = onClick;
                addEventListener(MouseEvent.CLICK, this.onClick);
            }

            draw();
        }

        public function dispose():void
        {
            if (_onClick != null)
                removeEventListener(MouseEvent.CLICK, onClick);
        }

        private function onClick(event:Event):void
        {
            checked = !_active;
            if (_onClick != null)
                _onClick(event);
        }

        public function draw():void
        {
            graphics.clear();
            graphics.lineStyle(1, 0xFFFFFF, 0.75, true);
            graphics.beginFill((highlight ? GameBackgroundColor.BG_LIGHT : 0xFFFFFF), (highlight ? 1 : 0.25));
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();

            // X
            if (_active)
            {
                graphics.lineStyle(0, 0, 0);
                graphics.beginFill(0xFFFFFF, 0.75)
                graphics.drawRect(5, 5, width - 9, height - 9);
                graphics.endFill();
            }
        }

        ////////////////////////////////////////////////////////////////////////
        //- Getters / Setters
        public function get highlight():Boolean
        {
            return _highlight || _active;
        }

        public function set checked(val:Boolean):void
        {
            _active = val;
            draw();
        }

        public function get checked():Boolean
        {
            return _active;
        }

        override public function get width():Number
        {
            return _width;
        }

        override public function get height():Number
        {
            return _height;
        }
    }
}
