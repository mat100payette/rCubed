package popups.settings
{
    import classes.Language;
    import classes.Noteskins;
    import classes.UserSettings;
    import classes.ui.BoxText;
    import classes.ui.Text;
    import com.flashfla.utils.StringUtil;
    import flash.display.MovieClip;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;

    public class SettingsTabInput extends SettingsTabBase
    {
        private var _lang:Language = Language.instance;
        private var _noteskins:Noteskins = Noteskins.instance;

        private static const MENU_INPUTS:Array = ["restart", "quit", "options"];

        private var gameplayInputs:Array = ["left", "down", "up", "right"];

        private var optionKeyInputs:Array;
        private var keyListenerTarget:BoxText;

        private var keysHeld:Array = [];
        private var keysHeldText:Text;

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
            _parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandlerDown, true, int.MAX_VALUE - 10, true);
            _parent.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandlerUp, true, int.MAX_VALUE - 10, true);

            var i:int;
            var xOff:int = 15;
            var yOff:int = 15;

            const data:Object = _noteskins.getInfo(_settings.activeNoteskin);
            const hasRotation:Boolean = (data.rotation != 0);

            optionKeyInputs = [];

            container.graphics.lineStyle(1, 0xFFFFFF, 0.2);

            // gameplay input
            var keyText:Text;
            var noteScale:Number = -1;
            var curOffX:Number = 0;

            const INPUT_WIDTH:int = 60;
            const RECEPTOR_SIZE:Number = 38;

            for (i = 0; i < gameplayInputs.length; i++)
            {
                curOffX = xOff + ((INPUT_WIDTH + 35) * i);

                keyText = new Text(container, curOffX + 10, yOff + 4, _lang.string("options_scroll_" + gameplayInputs[i]));
                keyText.setAreaParams(INPUT_WIDTH, 24, "center");

                container.graphics.beginFill(0xFFFFFF, 0.07);
                container.graphics.drawRect(curOffX, yOff, INPUT_WIDTH + 20, 110);
                container.graphics.endFill();

                // Set Image
                var columnDirectionNote:MovieClip = _noteskins.getReceptor(data.id, "D");

                if (hasRotation)
                    columnDirectionNote.rotation = data.rotation * RECEPTOR_ROTATIONS[i];

                if (noteScale < 0)
                    noteScale = Math.min(1, (RECEPTOR_SIZE / Math.max(columnDirectionNote.width, columnDirectionNote.height)));

                columnDirectionNote.scaleX = columnDirectionNote.scaleY = noteScale;
                container.addChild(columnDirectionNote);

                columnDirectionNote.x = curOffX + 10 + (INPUT_WIDTH / 2);
                columnDirectionNote.y = yOff + (RECEPTOR_SIZE / 2) + 33;

                var gameKeyInput:BoxText = new BoxText(container, curOffX + 10, yOff + 80, INPUT_WIDTH, 20);
                gameKeyInput.autoSize = TextFieldAutoSize.CENTER;
                gameKeyInput.mouseEnabled = true;
                gameKeyInput.mouseChildren = false;
                gameKeyInput.useHandCursor = true;
                gameKeyInput.buttonMode = true;
                gameKeyInput.key = gameplayInputs[i];
                gameKeyInput.addEventListener(MouseEvent.CLICK, clickHandler);
                optionKeyInputs.push(gameKeyInput);
            }

            xOff = 395;

            for (i = 0; i < MENU_INPUTS.length; i++)
            {
                container.graphics.beginFill(0xFFFFFF, 0.07);
                container.graphics.drawRect(xOff, yOff, 175, 34);
                container.graphics.endFill();

                new Text(container, xOff + 74, yOff + 7, _lang.string("options_scroll_" + MENU_INPUTS[i]));

                gameKeyInput = new BoxText(container, xOff + 8, yOff + 7, 60, 19);
                gameKeyInput.autoSize = TextFieldAutoSize.CENTER;
                gameKeyInput.mouseEnabled = true;
                gameKeyInput.mouseChildren = false;
                gameKeyInput.useHandCursor = true;
                gameKeyInput.buttonMode = true;
                gameKeyInput.key = MENU_INPUTS[i];
                gameKeyInput.addEventListener(MouseEvent.CLICK, clickHandler);
                optionKeyInputs.push(gameKeyInput);
                yOff += 38;
            }

            drawSeperator(container, 15, 555, 135);

            // input tester
            xOff = 15;
            yOff = 155;
            keyText = new Text(container, xOff, yOff, _lang.string("options_input_tester"), 16);
            keyText.setAreaParams(555, 24, "center");
            yOff += 28;

            keyText = new Text(container, xOff, yOff, _lang.string("options_input_tester_description"), 12);
            keyText.setAreaParams(555, 24, "center");

            keysHeldText = new Text(container, xOff, 285, "", 32);
            keysHeldText.setAreaParams(555, 32, "center");
        }

        override public function closeTab():void
        {
            _parent.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandlerDown, true);
            _parent.stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandlerUp, true);
            super.closeTab();
        }

        override public function setValues():void
        {
            for each (var item:BoxText in optionKeyInputs)
            {
                item.text = StringUtil.keyCodeChar(_settings["key" + StringUtil.upperCase(item.key)]).toUpperCase();
            }
        }

        override public function clickHandler(e:MouseEvent):void
        {
            setValues();
            keyListenerTarget = (e.target as BoxText);
            keyListenerTarget.htmlText = _lang.string("options_key_pick");
        }

        private function keyHandlerDown(e:KeyboardEvent):void
        {
            if (keyListenerTarget)
            {
                var keyCode:uint = e.keyCode;
                var keyChar:String = StringUtil.keyCodeChar(keyCode);
                if (keyChar != "")
                {
                    _settings["key" + StringUtil.upperCase(keyListenerTarget.key)] = keyCode;
                    keyListenerTarget = null;
                    setValues();
                }

                return;
            }

            if (keysHeld.indexOf(e.keyCode) == -1)
            {
                keysHeld[keysHeld.length] = e.keyCode;
                updateHeldText();
            }

            e.stopImmediatePropagation();
        }

        private function keyHandlerUp(e:KeyboardEvent):void
        {
            if (keysHeld.indexOf(e.keyCode) >= 0)
            {
                keysHeld.removeAt(keysHeld.indexOf(e.keyCode));
                updateHeldText();
            }
        }

        private function updateHeldText():void
        {
            keysHeld.sort();

            var keyText:String = "";
            for each (var keyCode:int in keysHeld)
            {
                const keyChar:String = StringUtil.keyCodeChar(keyCode);
                if (keyChar != "")
                {
                    keyText += " " + keyChar + " ";
                }
            }
            keysHeldText.text = keyText;
        }
    }
}
