package popups.settings
{
    import classes.Language;
    import classes.UserSettings;
    import classes.ui.BoxCheck;
    import classes.ui.Text;
    import com.flashfla.utils.ArrayUtil;
    import flash.events.Event;

    public class SettingsTabModifiers extends SettingsTabBase
    {
        private var _gvars:GlobalVariables = GlobalVariables.instance;
        private var _lang:Language = Language.instance;

        private var _optionHidden:BoxCheck;
        private var _optionSudden:BoxCheck;
        private var _optionBlink:BoxCheck;
        private var _optionRotating:BoxCheck;
        private var _optionRotateCW:BoxCheck;
        private var _optionRotateCCW:BoxCheck;
        private var _optionWave:BoxCheck;
        private var _optionDrunk:BoxCheck;
        private var _optionTornado:BoxCheck;
        private var _optionMiniResize:BoxCheck;
        private var _optionTapPulse:BoxCheck;
        private var _optionRandom:BoxCheck;
        private var _optionScramble:BoxCheck;
        private var _optionShuffle:BoxCheck;
        private var _optionReverse:BoxCheck;

        private var _optionMirror:BoxCheck;
        private var _optionDark:BoxCheck;
        private var _optionHide:BoxCheck;
        private var _optionMini:BoxCheck;
        private var _optionColumnColor:BoxCheck;
        private var _optionHalftime:BoxCheck;
        private var _optionNoBackground:BoxCheck;

        public function SettingsTabModifiers(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "game_modifiers";
        }

        override public function openTab():void
        {
            function addCheckOption(textLocalStringName:String, onCheck:Function):BoxCheck
            {

                new Text(container, xOff + 23, yOff, _lang.string(textLocalStringName));
                const checkBox:BoxCheck = new BoxCheck(container, xOff + 3, yOff + 3, onCheck);

                yOff += 20;

                _options[textLocalStringName] = checkBox;
                return checkBox;
            }

            container.graphics.lineStyle(1, 0xFFFFFF, 0.35);
            container.graphics.moveTo(295, 15);
            container.graphics.lineTo(295, 405);

            var xOff:int = 15;
            var yOff:int = 15;

            /// Col 1

            new Text(container, xOff, yOff, _lang.string("options_game_mods"), 14);
            yOff += 25;

            _optionHidden = addCheckOption("options_mod_hidden", onHiddenChecked);
            _optionSudden = addCheckOption("options_mod_sudden", onSuddenChecked);
            _optionBlink = addCheckOption("options_mod_blink", onBlinkChecked);

            yOff += drawSeperator(container, xOff, 200, yOff, 2, 3);

            _optionRotating = addCheckOption("options_mod_rotating", onRotatingChecked);
            _optionRotateCW = addCheckOption("options_mod_rotate_cw", onRotateCWChecked);
            _optionRotateCCW = addCheckOption("options_mod_rotate_ccw", onRotateCCWChecked);
            _optionWave = addCheckOption("options_mod_wave", onWaveChecked);
            _optionDrunk = addCheckOption("options_mod_drunk", onDrunkChecked);
            _optionTornado = addCheckOption("options_mod_tornado", onTornadoChecked);
            _optionMiniResize = addCheckOption("options_mod_mini_resize", onMiniResizeChecked);
            _optionTapPulse = addCheckOption("options_mod_tap_pulse", onTapPulseChecked);

            yOff += drawSeperator(container, xOff, 200, yOff, 2, 3);

            _optionRandom = addCheckOption("options_mod_random", onRandomChecked);
            _optionScramble = addCheckOption("options_mod_scramble", onScrambleChecked);
            _optionShuffle = addCheckOption("options_mod_shuffle", onShuffleChecked);
            _optionReverse = addCheckOption("options_mod_reverse", onReverseChecked);

            /// Col 2
            xOff = 310;
            yOff = 15;

            new Text(container, xOff, yOff, _lang.string("options_visual_mods"), 14);
            yOff += 25;

            _optionMirror = addCheckOption("options_mod_mirror", onMirrorChecked);
            _optionDark = addCheckOption("options_mod_dark", onDarkChecked);
            _optionHide = addCheckOption("options_mod_hide", onHideChecked);
            _optionMini = addCheckOption("options_mod_mini", onMiniChecked);
            _optionColumnColor = addCheckOption("options_mod_columncolour", onColumnColorChecked);
            _optionHalftime = addCheckOption("options_mod_halftime", onHalftimeChecked);

            yOff += drawSeperator(container, xOff, 200, yOff, 2, 3);

            _optionNoBackground = addCheckOption("options_mod_nobackground", onNoBackgroundChecked);
        }

        override public function setValues():void
        {
            // TODO: Refactor UserSettings to use well defined variables per mod
            _optionHidden.checked = _settings.activeMods.indexOf("hidden") != -1;
            _optionSudden.checked = _settings.activeMods.indexOf("sudden") != -1;
            _optionBlink.checked = _settings.activeMods.indexOf("blink") != -1;
            _optionRotating.checked = _settings.activeMods.indexOf("rotating") != -1;
            _optionRotateCW.checked = _settings.activeMods.indexOf("rotate_cw") != -1;
            _optionRotateCCW.checked = _settings.activeMods.indexOf("rotate_ccw") != -1;
            _optionWave.checked = _settings.activeMods.indexOf("wave") != -1;
            _optionDrunk.checked = _settings.activeMods.indexOf("drunk") != -1;
            _optionTornado.checked = _settings.activeMods.indexOf("tornado") != -1;
            _optionMiniResize.checked = _settings.activeMods.indexOf("mini_resize") != -1;
            _optionTapPulse.checked = _settings.activeMods.indexOf("tap_pulse") != -1;
            _optionRandom.checked = _settings.activeMods.indexOf("random") != -1;
            _optionScramble.checked = _settings.activeMods.indexOf("scramble") != -1;
            _optionShuffle.checked = _settings.activeMods.indexOf("shuffle") != -1;
            _optionReverse.checked = _settings.activeMods.indexOf("reverse") != -1;

            _optionMirror.checked = _settings.activeVisualMods.indexOf("mirror") != -1;
            _optionDark.checked = _settings.activeVisualMods.indexOf("dark") != -1;
            _optionHide.checked = _settings.activeVisualMods.indexOf("hide") != -1;
            _optionMini.checked = _settings.activeVisualMods.indexOf("mini") != -1;
            _optionColumnColor.checked = _settings.activeVisualMods.indexOf("columncolour") != -1;
            _optionHalftime.checked = _settings.activeVisualMods.indexOf("halftime") != -1;
            _optionNoBackground.checked = _settings.activeVisualMods.indexOf("nobackground") != -1;
        }

        private function toggleGameMod(modName:String):void
        {
            if (_settings.activeMods.indexOf(modName) != -1)
                ArrayUtil.removeValue(modName, _settings.activeMods);
            else
                _settings.activeMods.push(modName);
        }

        private function toggleVisualMod(modName:String):void
        {
            if (_settings.activeVisualMods.indexOf(modName) != -1)
                ArrayUtil.removeValue(modName, _settings.activeVisualMods);
            else
                _settings.activeVisualMods.push(modName);
        }

        private function onHiddenChecked(e:Event):void
        {
            toggleGameMod("hidden");
        }

        private function onSuddenChecked(e:Event):void
        {
            toggleGameMod("sudden");
        }

        private function onBlinkChecked(e:Event):void
        {
            toggleGameMod("blink");
        }

        private function onRotatingChecked(e:Event):void
        {
            toggleGameMod("rotating");
        }

        private function onRotateCWChecked(e:Event):void
        {
            toggleGameMod("rotate_cw");
        }

        private function onRotateCCWChecked(e:Event):void
        {
            toggleGameMod("rotate_ccw");
        }

        private function onWaveChecked(e:Event):void
        {
            toggleGameMod("wave");
        }

        private function onDrunkChecked(e:Event):void
        {
            toggleGameMod("drunk");
        }

        private function onTornadoChecked(e:Event):void
        {
            toggleGameMod("tornado");
        }

        private function onMiniResizeChecked(e:Event):void
        {
            toggleGameMod("mini_resize");
        }

        private function onTapPulseChecked(e:Event):void
        {
            toggleGameMod("tap_pulse");
        }

        private function onRandomChecked(e:Event):void
        {
            toggleGameMod("random");
            _parent.checkValidMods();
        }

        private function onScrambleChecked(e:Event):void
        {
            toggleGameMod("scramble");
            _parent.checkValidMods();
        }

        private function onShuffleChecked(e:Event):void
        {
            toggleGameMod("shuffle");
            _parent.checkValidMods();
        }

        private function onReverseChecked(e:Event):void
        {
            toggleGameMod("reverse");
            _gvars.removeSongFiles();
            _parent.checkValidMods();
        }

        private function onMirrorChecked(e:Event):void
        {
            toggleVisualMod("mirror");
        }

        private function onDarkChecked(e:Event):void
        {
            toggleVisualMod("dark");
        }

        private function onHideChecked(e:Event):void
        {
            toggleVisualMod("hide");
        }

        private function onMiniChecked(e:Event):void
        {
            toggleVisualMod("mini");
        }

        private function onColumnColorChecked(e:Event):void
        {
            toggleVisualMod("columncolour");
        }

        private function onHalftimeChecked(e:Event):void
        {
            toggleVisualMod("halftime");
            _parent.checkValidMods();
        }

        private function onNoBackgroundChecked(e:Event):void
        {
            toggleVisualMod("nobackground");
        }
    }
}
