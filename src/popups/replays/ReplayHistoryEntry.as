package popups.replays
{
    import flash.display.Sprite;
    import flash.display.GradientType;
    import flash.geom.Matrix;
    import classes.ui.Text;
    import classes.ui.SimpleBoxButton;
    import assets.menu.icons.fa.iconCopy;
    import classes.replay.Replay;
    import classes.SongInfo;
    import flash.text.TextFormatAlign;

    public class ReplayHistoryEntry extends Sprite
    {
        public static const ENTRY_HEIGHT:int = 50;

        private static const SCORE_BG_MATRIX:Matrix = new Matrix();
        {
            SCORE_BG_MATRIX.createGradientBox(20, 20, 1.5708);
        }

        private static const SCORE_BG:Array = [[0xbfecff, 75], // Score
            [0x12ff00, 45], // Perfect
            [0x00ad0f, 45], // Good
            [0xff9a00, 45], // Average
            [0xff0000, 45], // Miss
            [0x874300, 45], // Boo
            [0x858585, 55] // Combo
            ];

        public var replay:Replay;
        public var info:SongInfo;

        private var _title:Text;
        private var _rate:Text;
        private var _engine:Text;

        private var _fieldPlane:Sprite;
        private var _fields:Vector.<Text>;

        public var btnPlay:SimpleBoxButton;
        public var btnCopy:SimpleBoxButton;

        public var index:int = 0;
        public var garbageSweep:Boolean = false;

        public function ReplayHistoryEntry():void
        {
            graphics.lineStyle(1, 0xFFFFFF, 0.35);
            graphics.beginFill(0xFFFFFF, 0.1);
            graphics.drawRect(0, 0, 578, ENTRY_HEIGHT);
            graphics.endFill();

            graphics.moveTo(548, 1);
            graphics.lineTo(548, ENTRY_HEIGHT);

            graphics.lineStyle(0, 0xFFFFFF, 0);

            var copyIcon:iconCopy = new iconCopy();
            copyIcon.scaleX = copyIcon.scaleY = (17 / copyIcon.width);
            copyIcon.x = 564;
            copyIcon.y = (ENTRY_HEIGHT / 2) + 1;
            addChild(copyIcon);

            // Score Fields BG
            _fieldPlane = new Sprite();
            _fieldPlane.x = 1;
            _fieldPlane.y = ENTRY_HEIGHT - 20;
            addChild(_fieldPlane);

            var field_txt:Text;
            _fields = new Vector.<Text>(SCORE_BG.length, true);

            var xOff:Number = 0;
            for (var index:int = 0; index < SCORE_BG.length; index++)
            {
                var scoreField:Array = SCORE_BG[index];

                _fieldPlane.graphics.beginGradientFill(GradientType.LINEAR, [scoreField[0], scoreField[0], scoreField[0]], [0.15, 0.22, 0.32], [0x00, 0x77, 0xFF], SCORE_BG_MATRIX);
                _fieldPlane.graphics.drawRect(xOff, 0, scoreField[1], 20);
                _fieldPlane.graphics.endFill();

                field_txt = new Text(_fieldPlane, xOff + 2, 0, "");
                field_txt.setAreaParams(scoreField[1] - 4, 20, TextFormatAlign.CENTER);
                _fields[index] = field_txt;
                xOff += scoreField[1];
            }

            // Text
            _title = new Text(this, 6, 6, "???", 14);
            _title.setAreaParams(536, 20);

            _rate = new Text(this, xOff + 5, 6, "", 14);
            _rate.setAreaParams(181, 20, TextFormatAlign.RIGHT);
            _rate.alpha = 0.4;

            _engine = new Text(this, xOff + 5, ENTRY_HEIGHT - 20, "");
            _engine.setAreaParams(181, 20, TextFormatAlign.RIGHT);
            _engine.alpha = 0.4;

            // Buttons
            btnPlay = new SimpleBoxButton(548, ENTRY_HEIGHT);
            addChild(btnPlay);

            btnCopy = new SimpleBoxButton(30, ENTRY_HEIGHT);
            btnCopy.x = 548;
            addChild(btnCopy);
        }

        public function setData(item:Replay):void
        {
            replay = item;
            info = item.songInfo;

            _title.text = info.name;

            if (info.engine != null)
            {
                if (info.engine.name == null)
                    _engine.text = info.engine.id.toString().toUpperCase();
                else
                    _engine.text = info.engine.name.toString();

                _engine.visible = true;
            }
            else
                _engine.visible = false;

            if (item.user.settings.songRate != 1)
            {
                _rate.text = "x" + item.user.settings.songRate;
                _rate.visible = true;
            }
            else
                _rate.visible = false;

            _fields[0].text = item.score.toString();
            _fields[1].text = item.perfect.toString();
            _fields[2].text = item.good.toString();
            _fields[3].text = item.average.toString();
            _fields[4].text = item.miss.toString();
            _fields[5].text = item.boo.toString();
            _fields[6].text = item.maxcombo.toString();

            _fields[2].alpha = item.good > 0 ? 1 : 0.3;
            _fields[3].alpha = item.average > 0 ? 1 : 0.3;
            _fields[4].alpha = item.miss > 0 ? 1 : 0.3;
            _fields[5].alpha = item.boo > 0 ? 1 : 0.3;
        }

        public function clear():void
        {
            replay = null;
        }
    }
}
