package popups.settings
{
    import classes.Language;
    import classes.NoteskinsList;
    import classes.UserSettings;
    import classes.ui.BoxText;
    import classes.ui.Text;
    import com.flashfla.utils.StringUtil;
    import flash.display.MovieClip;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormatAlign;

    public class SettingsTabInput extends SettingsTabBase
    {
        private var _lang:Language = Language.instance;
        private var _noteskins:NoteskinsList = NoteskinsList.instance;

        private var _optionLeftReceptor:BoxText;
        private var _optionDownReceptor:BoxText;
        private var _optionUpReceptor:BoxText;
        private var _optionRightReceptor:BoxText;

        private var _optionRestartKey:BoxText;
        private var _optionQuitKey:BoxText;
        private var _optionOptionsKey:BoxText;

        private var _keyListenerTarget:BoxText;
        private var _onKeyPicked:Function;

        private var _keysHeld:Array = [];
        private var _keysHeldText:Text;

        public function SettingsTabInput(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "input";
        }

        override public function openTab():void
        {
            function addReceptorOption(localStringName:String, rotation:int, keyPickedCallback:Function = null):BoxText
            {
                const keyText:Text = new Text(container, curOffX + 10, yOff + 4, _lang.string(localStringName));
                keyText.setAreaParams(INPUT_WIDTH, 24, TextFormatAlign.CENTER);

                container.graphics.beginFill(0xFFFFFF, 0.07);
                container.graphics.drawRect(curOffX, yOff, INPUT_WIDTH + 20, 110);
                container.graphics.endFill();

                // Set Image
                const noteImage:MovieClip = _noteskins.getReceptor(noteskinData.id, "D");

                if (hasRotation)
                    noteImage.rotation = noteskinData.rotation * rotation;

                if (isNaN(noteScale))
                    noteScale = Math.min(1, (RECEPTOR_SIZE / Math.max(noteImage.width, noteImage.height)));

                noteImage.scaleX = noteImage.scaleY = noteScale;
                container.addChild(noteImage);

                noteImage.x = curOffX + 10 + (INPUT_WIDTH / 2);
                noteImage.y = yOff + (RECEPTOR_SIZE / 2) + 33;

                const textField:BoxText = new BoxText(container, curOffX + 10, yOff + 80, INPUT_WIDTH, 20);
                textField.autoSize = TextFieldAutoSize.CENTER;
                textField.mouseEnabled = true;
                textField.mouseChildren = false;
                textField.useHandCursor = true;
                textField.buttonMode = true;
                textField.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
                {
                    onKeySetterClick(e, keyPickedCallback);
                });

                curOffX += INPUT_WIDTH + 35;

                _options[localStringName] = textField;
                return textField;
            }

            function addMenuKeyOption(localStringName:String, keyPickedCallback:Function = null):BoxText
            {
                container.graphics.beginFill(0xFFFFFF, 0.07);
                container.graphics.drawRect(xOff, yOff, 175, 34);
                container.graphics.endFill();

                new Text(container, xOff + 74, yOff + 7, _lang.string(localStringName));

                const textField:BoxText = new BoxText(container, xOff + 8, yOff + 7, 60, 19);
                textField.autoSize = TextFieldAutoSize.CENTER;
                textField.mouseEnabled = true;
                textField.mouseChildren = false;
                textField.useHandCursor = true;
                textField.buttonMode = true;
                textField.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
                {
                    onKeySetterClick(e, keyPickedCallback);
                });

                yOff += 38;

                _options[localStringName] = textField;
                return textField;
            }

            _parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true, int.MAX_VALUE - 10, true);
            _parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, true, int.MAX_VALUE - 10, true);

            const INPUT_WIDTH:int = 60;
            const RECEPTOR_SIZE:Number = 38;

            const noteskinData:Object = _noteskins.getInfo(_settings.activeNoteskin);
            // This is true if the current noteskin isn't symmetric
            const hasRotation:Boolean = (noteskinData.rotation != 0);

            var xOff:int = 15;
            var yOff:int = 15;

            var noteScale:Number = NaN;
            var curOffX:Number = xOff;

            container.graphics.lineStyle(1, 0xFFFFFF, 0.2);

            _optionLeftReceptor = addReceptorOption(Lang.OPTIONS_KEY_LEFT, 1, setKeyLeft);
            _optionDownReceptor = addReceptorOption(Lang.OPTIONS_KEY_DOWN, 0, setKeyDown);
            _optionUpReceptor = addReceptorOption(Lang.OPTIONS_KEY_UP, 2, setKeyUp);
            _optionRightReceptor = addReceptorOption(Lang.OPTIONS_KEY_RIGHT, -1, setKeyRight);

            xOff = 395;

            _optionRestartKey = addMenuKeyOption(Lang.OPTIONS_KEY_RESTART, setKeyRestart);
            _optionQuitKey = addMenuKeyOption(Lang.OPTIONS_KEY_QUIT, setKeyQuit);
            _optionOptionsKey = addMenuKeyOption(Lang.OPTIONS_KEY_OPTIONS, setKeyOptions);

            drawSeperator(container, 15, 555, 135);

            // input tester
            xOff = 15;
            yOff = 155;
            const inputTesterText:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_INPUT_TESTER), 16);
            inputTesterText.setAreaParams(555, 24, TextFormatAlign.CENTER);
            yOff += 28;

            const inputTesterDesc:Text = new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_INPUT_TESTER_DESC), 12);
            inputTesterDesc.setAreaParams(555, 24, TextFormatAlign.CENTER);

            _keysHeldText = new Text(container, xOff, 285, "", 32);
            _keysHeldText.setAreaParams(555, 32, TextFormatAlign.CENTER);
        }

        override public function closeTab():void
        {
            _parent.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
            _parent.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, true);
            super.closeTab();
        }

        override public function setValues():void
        {
            _optionLeftReceptor.text = StringUtil.keyCodeChar(_settings.keyLeft);
            _optionDownReceptor.text = StringUtil.keyCodeChar(_settings.keyDown);
            _optionUpReceptor.text = StringUtil.keyCodeChar(_settings.keyUp);
            _optionRightReceptor.text = StringUtil.keyCodeChar(_settings.keyRight);

            _optionRestartKey.text = StringUtil.keyCodeChar(_settings.keyRestart);
            _optionQuitKey.text = StringUtil.keyCodeChar(_settings.keyQuit);
            _optionOptionsKey.text = StringUtil.keyCodeChar(_settings.keyOptions);
        }

        public function onKeySetterClick(e:MouseEvent, onKeyPicked:Function):void
        {
            setValues();
            const textField:BoxText = e.target as BoxText;
            textField.htmlText = _lang.string(Lang.OPTIONS_KEY_PICK);
            _keyListenerTarget = textField;
            _onKeyPicked = onKeyPicked;
        }

        private function onKeyDown(e:KeyboardEvent):void
        {
            if (_keyListenerTarget != null)
            {
                setKeyBind(e);
                return;
            }

            if (_keysHeld.indexOf(e.keyCode) == -1)
            {
                _keysHeld[_keysHeld.length] = e.keyCode;
                updateHeldText();
            }

            e.stopImmediatePropagation();
        }

        private function onKeyUp(e:KeyboardEvent):void
        {
            const keyHeldIndex:int = _keysHeld.indexOf(e.keyCode);
            if (keyHeldIndex < 0)
                return;

            _keysHeld.removeAt(keyHeldIndex);
            updateHeldText();
        }

        private function updateHeldText():void
        {
            _keysHeld.sort();

            var keysText:String = "";
            for each (var keyCode:int in _keysHeld)
            {
                const keyChar:String = StringUtil.keyCodeChar(keyCode);
                if (keyChar != "")
                    keysText += " " + keyChar + " ";
            }
            _keysHeldText.text = keysText;
        }

        private function setKeyBind(e:KeyboardEvent):void
        {
            const keyCode:uint = e.keyCode;
            const keyChar:String = StringUtil.keyCodeChar(keyCode);
            if (keyChar == "")
                return;

            _onKeyPicked(keyCode);
            _keyListenerTarget = null;

            setValues();
        }

        private function setKeyLeft(keyCode:uint):void
        {
            _settings.keyLeft = keyCode;
        }

        private function setKeyDown(keyCode:uint):void
        {
            _settings.keyDown = keyCode;
        }

        private function setKeyUp(keyCode:uint):void
        {
            _settings.keyUp = keyCode;
        }

        private function setKeyRight(keyCode:uint):void
        {
            _settings.keyRight = keyCode;
        }

        private function setKeyRestart(keyCode:uint):void
        {
            _settings.keyRestart = keyCode;
        }

        private function setKeyQuit(keyCode:uint):void
        {
            _settings.keyQuit = keyCode;
        }

        private function setKeyOptions(keyCode:uint):void
        {
            _settings.keyOptions = keyCode;
        }
    }
}
