package popups.settings
{
    import arc.ArcGlobals;
    import classes.Alert;
    import classes.Language;
    import classes.UserSettings;
    import classes.ui.BoxCheck;
    import classes.ui.BoxSlider;
    import classes.ui.Prompt;
    import classes.ui.Text;
    import classes.ui.ValidatedText;
    import events.actions.gameplay.AutoJudgeOffsetToggledEvent;
    import events.actions.gameplay.SetGameVolumeEvent;
    import events.actions.gameplay.SetGlobalOffsetEvent;
    import events.actions.gameplay.SetJudgeOffsetEvent;
    import events.actions.gameplay.SetNoteScaleEvent;
    import events.actions.gameplay.SetReceptorGapEvent;
    import events.actions.gameplay.SetScrollDirectionEvent;
    import events.actions.gameplay.SetScrollSpeedEvent;
    import events.actions.gameplay.SetSongRateEvent;
    import events.actions.gameplay.ToggleAutoJudgeOffsetEvent;
    import events.actions.gameplay.ToggleMirrorEvent;
    import events.actions.gameplay.autofail.SetAutofailAmazingEvent;
    import events.actions.gameplay.autofail.SetAutofailAverageEvent;
    import events.actions.gameplay.autofail.SetAutofailBooEvent;
    import events.actions.gameplay.autofail.SetAutofailGoodEvent;
    import events.actions.gameplay.autofail.SetAutofailMissEvent;
    import events.actions.gameplay.autofail.SetAutofailPerfectEvent;
    import events.actions.gameplay.autofail.SetAutofailRawGoodsEvent;
    import events.actions.menu.SetMenuMusicVolumeEvent;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import state.AppState;
    import state.MenuState;

    public class SettingsTabGeneral extends SettingsTabBase
    {
        private static const SCROLL_DIRECTIONS:Array = ["up", "down", "left", "right", "split", "split_down", "plus"];

        private var _lang:Language = Language.instance;
        private var _avars:ArcGlobals = ArcGlobals.instance;

        private var _scrollOptionsGroup:Array = [];

        private var _optionScrollSpeed:ValidatedText;
        private var _optionReceptorSpacing:ValidatedText;
        private var _optionNoteScale:BoxSlider;
        private var _optionGameVolume:BoxSlider;
        private var _optionMenuVolume:BoxSlider;

        private var _optionGlobalOffset:ValidatedText;
        private var _optionJudgeOffset:ValidatedText;
        private var _optionAutoJudgeOffset:BoxCheck;

        private var _optionAutofailAmazing:ValidatedText;
        private var _optionAutofailPerfect:ValidatedText;
        private var _optionAutofailGood:ValidatedText;
        private var _optionAutofailAverage:ValidatedText;
        private var _optionAutofailMiss:ValidatedText;
        private var _optionAutofailBoo:ValidatedText;
        private var _optionAutofailRawGoods:ValidatedText;

        private var _optionScrollDirectionUp:BoxCheck;
        private var _optionScrollDirectionDown:BoxCheck;
        private var _optionScrollDirectionLeft:BoxCheck;
        private var _optionScrollDirectionRight:BoxCheck;
        private var _optionScrollDirectionSplit:BoxCheck;
        private var _optionScrollDirectionSplitDown:BoxCheck;
        private var _optionScrollDirectionPlus:BoxCheck;

        private var _optionMirrorMod:BoxCheck;
        private var _optionRate:ValidatedText;
        private var _optionIsolation:ValidatedText;
        private var _optionIsolationTotal:ValidatedText;

        public function SettingsTabGeneral(settingsWindow:SettingsWindow):void
        {
            super(settingsWindow);

            addEventListener(AutoJudgeOffsetToggledEvent.EVENT_TYPE, updateJudgeOffsetUI);
        }

        override public function get name():String
        {
            return "general";
        }

        override public function openTab():void
        {
            /**
             * Adds a new text option with a text type and change callback. Can be labeled or not.
             */
            function addTextOption(localStringName:String, textType:uint, labeled:Boolean = false, onTextChanged:Function = null, maxChars:int = 0):ValidatedText
            {
                if (labeled)
                {
                    new Text(container, xOff, yOff, _lang.string(localStringName));
                    yOff += 22;
                }

                const textField:ValidatedText = new ValidatedText(container, xOff, yOff, 130, 20, textType, onTextChanged);
                textField.field.maxChars = maxChars;
                yOff += 30;

                _options[localStringName] = textField;
                return textField;
            }

            /**
             * Adds a new checkbox option with a check callback.
             */
            function addCheckOption(textLocalStringName:String, onCheck:Function, tooltipText:String = null):BoxCheck
            {
                new Text(container, xOff + 22, yOff, _lang.string(textLocalStringName));
                const boxCheck:BoxCheck = new BoxCheck(container, xOff + 2, yOff + 3, onCheck);

                if (tooltipText != null)
                {
                    function onHover(e:Event):void
                    {
                        boxCheck.addEventListener(MouseEvent.MOUSE_OUT, onExit);
                        displayToolTip(boxCheck.x, boxCheck.y + 25, tooltipText);
                    }

                    function onExit(e:Event):void
                    {
                        boxCheck.removeEventListener(MouseEvent.MOUSE_OUT, onExit);
                        hideTooltip();
                    }

                    boxCheck.addEventListener(MouseEvent.MOUSE_OVER, onHover, false, 0, true);
                }

                yOff += 25;

                _options[textLocalStringName] = boxCheck;
                return boxCheck;
            }

            /**
             * Adds a new slider option with a slide callback. Can be labeled or not.
             */
            function addSliderOption(localStringName:String, minValue:Number, maxValue:Number, labeled:Boolean = false, onSlide:Function = null, valueTextTransformer:Function = null):BoxSlider
            {
                if (labeled)
                {
                    new Text(container, xOff, yOff, _lang.string(localStringName));
                    yOff += 22;
                }

                const slider:BoxSlider = new BoxSlider(container, xOff, yOff, 130, 10, BoxSlider.TEXT_ALIGN_RIGHT, onSlide, valueTextTransformer);
                slider.minValue = minValue;
                slider.maxValue = maxValue;

                yOff += 25;

                _options[localStringName] = slider;
                return slider;
            }

            container.graphics.beginFill(0, 0.05);
            container.graphics.drawRect(198, 0, 196, 418);
            container.graphics.endFill();

            container.graphics.lineStyle(1, 0xFFFFFF, 0.05);
            container.graphics.moveTo(197, 0);
            container.graphics.lineTo(197, 418);
            container.graphics.moveTo(394, 0);
            container.graphics.lineTo(394, 418);

            var xOff:int = 15;
            var yOff:int = 15;

            /// Col 1
            _optionScrollSpeed = addTextOption(Lang.OPTIONS_SCROLL_SPEED, ValidatedText.R_FLOAT_P, true, onScrollSpeedChanged);
            _optionReceptorSpacing = addTextOption(Lang.OPTIONS_RECEPTOR_SPACING, ValidatedText.R_INT, true, onReceptorGapChanged);

            yOff += drawSeperator(container, xOff, 170, yOff, 2, 4);

            _optionNoteScale = addSliderOption(Lang.OPTIONS_NOTE_SCALE, 0.1, 1.5, true, onNoteScaleChanged, toRoundedPercent);

            yOff += drawSeperator(container, xOff, 170, yOff, -4, 5);

            _optionGameVolume = addSliderOption(Lang.OPTIONS_GAME_VOLUME, 0, 1.25, true, onGameVolumeChanged, toRoundedPercent);
            _optionMenuVolume = addSliderOption(Lang.OPTIONS_MENU_VOLUME, 0, 1.25, true, onMenuVolumeChanged, toRoundedPercent);

            /// Col 2
            xOff = 211;
            yOff = 15;

            _optionGlobalOffset = addTextOption(Lang.OPTIONS_GLOBAL_OFFSET, ValidatedText.R_FLOAT, true, onGlobalOffsetChanged);
            _optionJudgeOffset = addTextOption(Lang.OPTIONS_JUDGE_OFFSET, ValidatedText.R_FLOAT, true, onJudgeOffsetChanged);

            _optionJudgeOffset.mouseEnabled = true;
            _optionJudgeOffset.contextMenu = arcJudgeMenu(_parent);

            _optionAutoJudgeOffset = addCheckOption(Lang.OPTIONS_AUTO_JUDGE_OFFSET, onAutoJudgeOffsetChanged, _lang.string(Lang.OPTIONS_POPUP_AUTO_JUDGE_OFFSET));

            yOff += drawSeperator(container, xOff, 170, yOff, 3, 5);

            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_AUTOFAIL));
            yOff += 22;

            _optionAutofailAmazing = addTextOption(Lang.GAME_AMAZING, ValidatedText.R_INT_P, true, onAutofailAmazingChanged, 5);
            _optionAutofailPerfect = addTextOption(Lang.GAME_PERFECT, ValidatedText.R_INT_P, true, onAutofailPerfectChanged, 5);
            _optionAutofailGood = addTextOption(Lang.GAME_GOOD, ValidatedText.R_INT_P, true, onAutofailGoodChanged, 5);
            _optionAutofailAverage = addTextOption(Lang.GAME_AVERAGE, ValidatedText.R_INT_P, true, onAutofailAverageChanged, 5);
            _optionAutofailMiss = addTextOption(Lang.GAME_MISS, ValidatedText.R_INT_P, true, onAutofailMissChanged, 5);
            _optionAutofailBoo = addTextOption(Lang.GAME_BOO, ValidatedText.R_INT_P, true, onAutofailBooChanged, 5);
            _optionAutofailRawGoods = addTextOption(Lang.OPTIONS_RAW_GOODS, ValidatedText.R_FLOAT_P, true, onAutofailRawGoodsChanged, 6);

            /// Col 3
            xOff = 407;
            yOff = 15;

            new Text(container, xOff, yOff, _lang.string(Lang.OPTIONS_SCROLL));
            yOff += 20;

            _optionScrollDirectionUp = addCheckOption(Lang.OPTIONS_SCROLL_UP, onScrollDirectionChanged);
            _optionScrollDirectionDown = addCheckOption(Lang.OPTIONS_SCROLL_DOWN, onScrollDirectionChanged);
            _optionScrollDirectionLeft = addCheckOption(Lang.OPTIONS_SCROLL_LEFT, onScrollDirectionChanged);
            _optionScrollDirectionRight = addCheckOption(Lang.OPTIONS_SCROLL_RIGHT, onScrollDirectionChanged);
            _optionScrollDirectionSplit = addCheckOption(Lang.OPTIONS_SCROLL_SPLIT, onScrollDirectionChanged);
            _optionScrollDirectionSplitDown = addCheckOption(Lang.OPTIONS_SCROLL_SPLIT_DOWN, onScrollDirectionChanged);
            _optionScrollDirectionPlus = addCheckOption(Lang.OPTIONS_SCROLL_PLUS, onScrollDirectionChanged);

            _scrollOptionsGroup.push(_optionScrollDirectionUp, _optionScrollDirectionDown, _optionScrollDirectionLeft, _optionScrollDirectionRight, _optionScrollDirectionSplit, _optionScrollDirectionSplitDown, _optionScrollDirectionPlus);

            yOff += drawSeperator(container, xOff, 170, yOff, 5, 6);

            _optionMirrorMod = addCheckOption(Lang.OPTIONS_MOD_MIRROR, onMirrorChanged);

            yOff += drawSeperator(container, xOff, 170, yOff, 1);

            _optionRate = addTextOption(Lang.OPTIONS_RATE, ValidatedText.R_FLOAT_P, true, onSongRateChanged);

            _optionIsolation = addTextOption(Lang.OPTIONS_ISOLATION_START, ValidatedText.R_INT_P, true, onIsolationStartChanged);
            _optionIsolationTotal = addTextOption(Lang.OPTIONS_ISOLATION_NOTES, ValidatedText.R_INT_P, true, onIsolationNotesChanged);

            setTextMaxWidth(166);
        }

        override public function setValues():void
        {
            var settings:UserSettings = AppState.instance.auth.user.settings;
            var menuState:MenuState = AppState.instance.menu;

            _optionScrollSpeed.text = settings.scrollSpeed.toString();
            _optionReceptorSpacing.text = settings.receptorGap.toString();

            _optionNoteScale.slideValue = settings.noteScale;

            _optionGameVolume.slideValue = settings.gameVolume;
            _optionMenuVolume.slideValue = menuState.menuMusicSoundVolume;

            _optionGlobalOffset.text = settings.globalOffset.toString();
            _optionJudgeOffset.text = settings.judgeOffset.toString();
            _optionAutoJudgeOffset.text = settings.autoJudgeOffset;

            updateJudgeOffsetUI();

            _optionAutofailAmazing.text = settings.autofailAmazing.toString();
            _optionAutofailPerfect.text = settings.autofailPerfect.toString();
            _optionAutofailGood.text = settings.autofailGood.toString();
            _optionAutofailAverage.text = settings.autofailAverage.toString();
            _optionAutofailMiss.text = settings.autofailMiss.toString();
            _optionAutofailBoo.text = settings.autofailBoo.toString();
            _optionAutofailRawGoods.text = settings.autofailRawGoods.toString();

            _optionScrollDirectionUp.checked = settings.scrollDirection == SCROLL_DIRECTIONS[0];
            _optionScrollDirectionDown.checked = settings.scrollDirection == SCROLL_DIRECTIONS[1];
            _optionScrollDirectionLeft.checked = settings.scrollDirection == SCROLL_DIRECTIONS[2];
            _optionScrollDirectionRight.checked = settings.scrollDirection == SCROLL_DIRECTIONS[3];
            _optionScrollDirectionSplit.checked = settings.scrollDirection == SCROLL_DIRECTIONS[4];
            _optionScrollDirectionSplitDown.checked = settings.scrollDirection == SCROLL_DIRECTIONS[5];
            _optionScrollDirectionPlus.checked = settings.scrollDirection == SCROLL_DIRECTIONS[6];

            _optionMirrorMod.checked = settings.activeVisualMods.indexOf("mirror") != -1;

            _optionRate.text = settings.songRate.toString();

            _optionIsolation.text = (_avars.configIsolationStart + 1).toString();
            _optionIsolationTotal.text = _avars.configIsolationLength.toString();
        }

        private function toRoundedPercent(val:Number):String
        {
            return Math.round(val * 100) + "%";
        }

        private function onScrollSpeedChanged(e:Event):void
        {
            dispatchEvent(new SetScrollSpeedEvent(_optionScrollSpeed.validate(1, 0.1)));
        }

        private function onReceptorGapChanged(e:Event):void
        {
            dispatchEvent(new SetReceptorGapEvent(_optionReceptorSpacing.validate(80)));
        }

        private function onNoteScaleChanged(e:Event):void
        {
            var sliderValue:int = Math.round(Math.max(Math.min(_optionNoteScale.slideValue, _optionNoteScale.maxValue), _optionNoteScale.minValue) * 100);

            // Snap to larger value when close.
            const snapTarget:int = 25;
            const snapValue:int = sliderValue % snapTarget;
            if (snapValue == 1 || snapValue == snapTarget - 1)
                sliderValue = Math.round(sliderValue / snapTarget) * snapTarget;

            dispatchEvent(new SetNoteScaleEvent(sliderValue / 100));
        }

        private function onGameVolumeChanged(e:Event):void
        {
            dispatchEvent(new SetGameVolumeEvent(_optionGameVolume.slideValue));
        }

        private function onMenuVolumeChanged(e:Event):void
        {
            var volume:Number = Math.max(Math.min(_optionMenuVolume.slideValue, _optionMenuVolume.maxValue), _optionMenuVolume.minValue);

            dispatchEvent(new SetMenuMusicVolumeEvent(volume));
        }

        private function onGlobalOffsetChanged(e:Event):void
        {
            dispatchEvent(new SetGlobalOffsetEvent(_optionGlobalOffset.validate(0)));
        }

        private function onJudgeOffsetChanged(e:Event):void
        {
            dispatchEvent(new SetJudgeOffsetEvent(_optionJudgeOffset.validate(0)));
        }

        private function onAutoJudgeOffsetChanged(e:Event):void
        {
            dispatchEvent(new ToggleAutoJudgeOffsetEvent());
        }

        private function updateJudgeOffsetUI():void
        {
            var autoJudgeOffset:Boolean = AppState.instance.auth.user.settings.autoJudgeOffset;

            _optionJudgeOffset.selectable = !autoJudgeOffset;
            _optionJudgeOffset.alpha = autoJudgeOffset ? 0.55 : 1.0;
        }

        private function onAutofailAmazingChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailAmazingEvent(_optionAutofailAmazing.validate(0, 0)));
        }

        private function onAutofailPerfectChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailPerfectEvent(_optionAutofailPerfect.validate(0, 0)));
        }

        private function onAutofailGoodChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailGoodEvent(_optionAutofailGood.validate(0, 0)));
        }

        private function onAutofailAverageChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailAverageEvent(_optionAutofailAverage.validate(0, 0)));
        }

        private function onAutofailMissChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailMissEvent(_optionAutofailMiss.validate(0, 0)));
        }

        private function onAutofailBooChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailBooEvent(_optionAutofailBoo.validate(0, 0)));
        }

        private function onAutofailRawGoodsChanged(e:Event):void
        {
            dispatchEvent(new SetAutofailRawGoodsEvent(_optionAutofailRawGoods.validate(0, 0)));
        }

        private function onScrollDirectionChanged(e:Event):void
        {
            for each (var scrollOption:BoxCheck in _scrollOptionsGroup)
            {
                if (e.target != scrollOption)
                    scrollOption.checked = false;
            }

            // TODO: This badly needs radiobuttons
            if (e.target == _optionScrollDirectionUp)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[0]));
            else if (e.target == _optionScrollDirectionDown)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[1]));
            else if (e.target == _optionScrollDirectionLeft)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[2]));
            else if (e.target == _optionScrollDirectionRight)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[3]));
            else if (e.target == _optionScrollDirectionSplit)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[4]));
            else if (e.target == _optionScrollDirectionSplitDown)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[5]));
            else if (e.target == _optionScrollDirectionPlus)
                dispatchEvent(new SetScrollDirectionEvent(SCROLL_DIRECTIONS[6]));
        }

        private function onMirrorChanged(e:Event):void
        {
            dispatchEvent(new ToggleMirrorEvent());
        }

        private function onSongRateChanged(e:Event):void
        {
            dispatchEvent(new SetSongRateEvent(_optionRate.validate(1, 0.1)));

            _parent.checkValidMods();
        }

        private function onIsolationStartChanged(e:Event):void
        {
            // TODO: destroy avars...
            _avars.configIsolationStart = _optionIsolation.validate(1, 1) - 1;
            _avars.configIsolation = _avars.configIsolationStart > 0 || _avars.configIsolationLength > 0;

            _parent.checkValidMods();
        }

        private function onIsolationNotesChanged(e:Event):void
        {
            _avars.configIsolationLength = _optionIsolationTotal.validate(0);
            _avars.configIsolation = _avars.configIsolationStart > 0 || _avars.configIsolationLength > 0;

            _parent.checkValidMods();
        }

        private function arcJudgeMenu(parent:SettingsWindow):ContextMenu
        {
            const judgeMenu:ContextMenu = new ContextMenu();
            const judgeItem:ContextMenuItem = new ContextMenuItem("Custom Judge Windows");

            judgeItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(event:ContextMenuEvent):void
            {
                new Prompt(parent, 320, "Judge Window", 100, "SUBMIT", onCustomJudgeWindowSubmit);
            });
            judgeMenu.customItems.push(judgeItem);

            return judgeMenu;
        }

        private function onCustomJudgeWindowSubmit(judgeWindow:String):void
        {
            _avars.configJudge = null;
            var judge:Array;
            for each (var item:String in judgeWindow.split(":"))
            {
                if (!judge)
                    judge = new Array();

                const items:Array = item.split(",");
                if (items.length != 2)
                {
                    judge = null;
                    break;
                }
                judge.push({t: parseInt(items[0]), s: parseInt(items[1])});
            }

            _avars.configJudge = judge;

            if (judge)
                Alert.add(_lang.string("judge_window_set"));
            else
                Alert.add(_lang.string("judge_window_cleared"));
        }
    }
}
