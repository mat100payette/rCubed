package classes.ui
{
    import assets.menu.icons.fa.iconRight;
    import classes.ui.SimpleBoxButton;
    import classes.ui.Text;
    import com.greensock.TweenLite;
    import flash.display.Sprite;

    public class TabButton extends Sprite
    {
        private var _index:int;
        private var _text:Text;
        private var _button:SimpleBoxButton;
        private var _chevron:iconRight;
        private var _active:Boolean = false;
        private var _hasTopBorder:Boolean = false;

        public function TabButton(parent:Sprite, xpos:Number, ypos:Number, index:int, btnText:String, hasTopBorder:Boolean = false)
        {
            _index = index;
            _hasTopBorder = hasTopBorder;

            _text = new Text(this, 15, 5, btnText);
            _text.setAreaParams(146, 22);

            _button = new SimpleBoxButton(175, 32);
            addChild(_button);

            x = xpos;
            y = ypos;
            parent.addChild(this);

            _chevron = new iconRight();
            _chevron.x = 16;
            _chevron.y = 16.5;
            _chevron.scaleX = _chevron.scaleY = 0.2;
            _chevron.visible = false;
            addChild(_chevron);

            draw();
        }

        public function get index():int
        {
            return _index;
        }

        public function draw():void
        {
            graphics.clear();
            graphics.lineStyle(0, 0, 0);
            graphics.beginFill(0xFFFFFF, (_active ? 0.2 : 0.08));
            graphics.drawRect(0, 0, 175, 32);
            graphics.endFill();

            graphics.lineStyle(1, 0xFFFFFF, 0.35);
            graphics.moveTo(0, 32);
            graphics.lineTo(175, 32);

            if (_hasTopBorder)
            {
                graphics.moveTo(0, 0);
                graphics.lineTo(175, 0);
            }
        }

        public function setActive(newState:Boolean):void
        {
            if (_active == newState)
                return;

            TweenLite.to(_text, 0.25, {"x": (newState ? 25 : 15)});
            _active = newState;
            _button.visible = !newState;
            _chevron.visible = newState;
            draw();
        }
    }
}
