package classes.ui
{
    import assets.GameBackgroundColor;
    import classes.Alert;
    import classes.Language;
    import classes.ui.BoxButton;
    import classes.ui.Text;
    import classes.UserSettings;
    import com.flashfla.utils.SpriteUtil;
    import com.flashfla.utils.SystemUtil;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.display.Stage;

    public class ManageSettingsWindow extends Sprite
    {
        private const BOX_MID:Number = (Main.GAME_WIDTH - 200) / 2;

        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        private var _onClose:Function;
        private var _bmp:Bitmap;
        private var _box:Sprite;

        private var _settingsJSONString:String;

        private var _btnClose:BoxButton;
        private var _txtExport:TextField;
        private var _btnExport:BoxButton;
        private var _txtImport:TextField;
        private var _btnImport:BoxButton;

        public function ManageSettingsWindow(stage:Stage, onClose:Function):void
        {
            _onClose = onClose;

            const userSettings:UserSettings = _gvars.activeUser.settings;
            _gvars.activeUser.saveSettingsOnline();
            _settingsJSONString = userSettings.stringify();

            _bmp = SpriteUtil.getBitmapSprite(stage);
            addChild(_bmp);

            _box = new Sprite();
            _box.graphics.beginFill(0, 0.25);
            _box.graphics.drawRect(0, 0, Main.GAME_WIDTH, Main.GAME_HEIGHT);
            _box.graphics.endFill();

            _box.graphics.lineStyle(1, 0xffffff, 0.35);
            _box.graphics.beginFill(GameBackgroundColor.BG_POPUP, 0.7);
            _box.graphics.drawRect(100, 100, Main.GAME_WIDTH - 200, Main.GAME_HEIGHT - 200);
            _box.graphics.endFill();

            _box.graphics.moveTo(100 + BOX_MID, 110);
            _box.graphics.lineTo(100 + BOX_MID, 100 + Main.GAME_HEIGHT - 210);
            addChild(_box);

            var xOff:Number = 100;
            var yOff:Number = 100;

            _btnClose = new BoxButton(_box, xOff + Main.GAME_WIDTH - 300, yOff + Main.GAME_HEIGHT - 190, 100, 29, _lang.string("menu_close"), 12, clickHandler);

            new Text(_box, xOff + 10, yOff + 12, "Export", 16).setAreaParams(160, 30);
            _btnExport = new BoxButton(_box, xOff + 179, yOff + 10, 100, 26, "Copy", 12, clickHandler);

            _txtExport = makeTextfield();
            _txtExport.x = xOff + 15;
            _txtExport.y = yOff + 50;
            _txtExport.type = TextFieldType.DYNAMIC;
            _txtExport.text = _settingsJSONString;

            _box.graphics.beginFill(0, 0.4);
            _box.graphics.drawRect(_txtExport.x - 4, _txtExport.y - 4, _txtExport.width + 8, _txtExport.height + 8);
            _box.graphics.endFill();

            xOff += BOX_MID;

            new Text(_box, xOff + 10, yOff + 12, "Import", 16).setAreaParams(160, 30);
            _btnImport = new BoxButton(_box, xOff + 179, yOff + 10, 100, 26, "Save", 12, clickHandler);

            _txtImport = makeTextfield();
            _txtImport.x = xOff + 15;
            _txtImport.y = yOff + 50;
            _txtImport.type = TextFieldType.INPUT;

            _box.graphics.beginFill(0, 0.4);
            _box.graphics.drawRect(_txtImport.x - 4, _txtImport.y - 4, _txtImport.width + 8, _txtImport.height + 8);
            _box.graphics.endFill();
        }

        private function makeTextfield():TextField
        {
            const _tf:TextField = new TextField();
            _tf.width = BOX_MID - 30;
            _tf.height = 215;
            _tf.multiline = true;
            _tf.defaultTextFormat = new TextFormat(Language.FONT_NAME, 10, 0xFFFFFF, true);
            _tf.type = TextFieldType.DYNAMIC;
            _tf.embedFonts = true;
            _tf.antiAliasType = AntiAliasType.ADVANCED;
            _tf.gridFitType = GridFitType.SUBPIXEL;
            _tf.wordWrap = true;
            _box.addChild(_tf);
            return _tf;
        }

        private function clickHandler(e:Event):void
        {
            if (e.target == _btnExport)
            {
                const success:Boolean = SystemUtil.setClipboard(_settingsJSONString);

                if (success)
                    Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
                else
                    Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
            }

            else if (e.target == _btnImport)
            {
                try
                {
                    const optionsJSON:String = _txtImport.text;
                    if (optionsJSON.length >= 2 && optionsJSON.charAt(0) == "{")
                    {
                        const item:Object = JSON.parse(optionsJSON);
                        _gvars.activeUser.settings.update(item);
                        Alert.add("Settings Imported!", 120, Alert.GREEN);
                    }
                    else
                    {
                        Alert.add("Nothing to Import", 120, Alert.RED);
                    }
                }
                catch (e:Error)
                {
                    Alert.add("Import Fail...", 120, Alert.RED);
                }
            }
            else if (e.target == _btnClose)
            {
                _onClose(this);
            }
        }
    }
}
