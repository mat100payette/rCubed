package game.controls
{
    import com.flashfla.utils.ColorUtil;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.text.AntiAliasType;
    import classes.Language;

    public class Combo extends Sprite
    {
        private var _isAutoplay:Boolean;

        private var _rawGoodsThreshold:Boolean;

        private var _colors:Vector.<Number>;
        private var _colorsDark:Vector.<Number>;
        private var _colorsEnabled:Vector.<Boolean>;

        private var _field:TextField;
        private var _fieldShadow:TextField;

        public function Combo(colors:Array, enabledCombos:Array, isAutoplay:Boolean, rawGoodsThreshold:int)
        {
            _isAutoplay = isAutoplay;
            _rawGoodsThreshold = rawGoodsThreshold;

            var colorCount:int = colors.length;

            // Copy Combo Colors
            _colors = new Vector.<Number>(colorCount, true);
            _colorsDark = new Vector.<Number>(colorCount, true);
            for (var i:int = 0; i < colorCount; i++)
            {
                _colors[i] = colors[i];
                _colorsDark[i] = ColorUtil.darkenColor(colors[i], 0.5);
            }

            // Copy Enabled Colors
            _colorsEnabled = new Vector.<Boolean>(colorCount, true);
            for (i = 0; i < enabledCombos.length; i++)
            {
                _colorsEnabled[i] = enabledCombos[i];
            }

            _fieldShadow = new TextField();
            _fieldShadow.defaultTextFormat = new TextFormat(Language.UNI_FONT_NAME, 50, _colorsDark[2], true);
            _fieldShadow.antiAliasType = AntiAliasType.ADVANCED;
            _fieldShadow.embedFonts = true;
            _fieldShadow.selectable = false;
            _fieldShadow.autoSize = TextFieldAutoSize.LEFT;
            _fieldShadow.x = 2;
            _fieldShadow.y = 2;
            _fieldShadow.text = "0";
            addChild(_fieldShadow);

            _field = new TextField();
            _field.defaultTextFormat = new TextFormat(Language.UNI_FONT_NAME, 50, _colors[2], true);
            _field.antiAliasType = AntiAliasType.ADVANCED;
            _field.embedFonts = true;
            _field.selectable = false;
            _field.autoSize = TextFieldAutoSize.LEFT;
            _field.x = 0;
            _field.y = 0;
            _field.text = "0";
            addChild(_field);

            if (_isAutoplay)
            {
                _field.textColor = 0xD00000;
                _fieldShadow.textColor = 0x5B0000;
            }
        }

        public function update(combo:int, amazing:int = 0, perfect:int = 0, good:int = 0, average:int = 0, miss:int = 0, boo:int = 0, raw_goods:Number = 0):void
        {
            _field.text = combo.toString();
            _fieldShadow.text = combo.toString();

            /* colors[i]:
               [0] = Normal,
               [1] = FC,
               [2] = AAA,
               [3] = SDG,
               [4] = Black Flag,
               [5] = Average Flag,
               [6] = Boo Flag,
               [7] = Miss Flag,
               [8] = Raw Goods
             */

            if (!_isAutoplay)
            {
                if (_colorsEnabled[2] && good + average + boo + miss == 0) // Display AAA color
                {
                    _field.textColor = _colors[2];
                    _fieldShadow.textColor = _colorsDark[2];
                }
                else if (_colorsEnabled[6] && boo == 1 && good + average + miss == 0) // Display Boo Flag color
                {
                    _field.textColor = _colors[6];
                    _fieldShadow.textColor = _colorsDark[6];
                }
                else if (_colorsEnabled[4] && good == 1 && average + boo + miss == 0) // Display Black Flag color
                {
                    _field.textColor = _colors[4];
                    _fieldShadow.textColor = _colorsDark[4];
                }
                else if (_colorsEnabled[5] && average == 1 && good + boo + miss == 0) // Display Average Flag color
                {
                    _field.textColor = _colors[5];
                    _fieldShadow.textColor = _colorsDark[5];
                }
                else if (_colorsEnabled[7] && miss == 1 && good + average + boo == 0) // Display Miss Flag color
                {
                    _field.textColor = _colors[7];
                    _fieldShadow.textColor = _colorsDark[7];
                }
                else if (_colorsEnabled[8] && raw_goods >= _rawGoodsThreshold) // Display color for raw good tracker
                {
                    _field.textColor = _colors[8];
                    _fieldShadow.textColor = _colorsDark[8];
                }
                else if (_colorsEnabled[3] && raw_goods < 10) // Display SDG color if raw goods < 10
                {
                    _field.textColor = _colors[3];
                    _fieldShadow.textColor = _colorsDark[3];
                }
                else if (_colorsEnabled[1] && miss == 0) // Display green for FC
                {
                    _field.textColor = _colors[1];
                    _fieldShadow.textColor = _colorsDark[1];
                }
                else // Display blue combo text
                {
                    _field.textColor = _colors[0];
                    _fieldShadow.textColor = _colorsDark[0];
                }
            }
        }

        public function set alignment(autosize:String):void
        {
            _field.autoSize = autosize;
            _fieldShadow.autoSize = autosize;
        }
    }
}
