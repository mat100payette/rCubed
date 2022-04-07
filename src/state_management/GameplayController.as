package state_management
{
    import classes.User;
    import classes.UserSettings;
    import com.flashfla.utils.ArrayUtil;
    import com.flashfla.utils.ColorUtil;
    import events.actions.gameplay.ClearSongQueueEvent;
    import events.actions.gameplay.CustomNoteskinToggledEvent;
    import events.actions.gameplay.NoteColorChangedEvent;
    import events.actions.gameplay.SetAutofailAmazingEvent;
    import events.actions.gameplay.SetAutofailAverageEvent;
    import events.actions.gameplay.SetAutofailBooEvent;
    import events.actions.gameplay.SetAutofailGoodEvent;
    import events.actions.gameplay.SetAutofailMissEvent;
    import events.actions.gameplay.SetAutofailPerfectEvent;
    import events.actions.gameplay.SetAutofailRawGoodsEvent;
    import events.actions.gameplay.SetGlobalOffsetEvent;
    import events.actions.gameplay.SetJudgeOffsetEvent;
    import events.actions.gameplay.SetNoteScaleEvent;
    import events.actions.gameplay.SetNoteskinIdEvent;
    import events.actions.gameplay.SetReceptorGapEvent;
    import events.actions.gameplay.SetScrollDirectionEvent;
    import events.actions.gameplay.SetScrollSpeedEvent;
    import events.actions.gameplay.SetSongRateEvent;
    import events.actions.gameplay.ToggleAutoJudgeOffsetEvent;
    import events.actions.gameplay.ToggleCustomNoteskinEvent;
    import events.actions.gameplay.ToggleMirrorEvent;
    import events.actions.gameplay.colors.GameAColorChangedEvent;
    import events.actions.gameplay.colors.GameBColorChangedEvent;
    import events.actions.gameplay.colors.GameCColorChangedEvent;
    import events.actions.gameplay.colors.SetAAAComboColorEvent;
    import events.actions.gameplay.colors.SetAvflagComboColorEvent;
    import events.actions.gameplay.colors.SetBlackflagComboColorEvent;
    import events.actions.gameplay.colors.SetBooflagComboColorEvent;
    import events.actions.gameplay.colors.SetFCComboColorEvent;
    import events.actions.gameplay.colors.SetGameAColorEvent;
    import events.actions.gameplay.colors.SetGameBColorEvent;
    import events.actions.gameplay.colors.SetGameCColorEvent;
    import events.actions.gameplay.colors.SetJudgeColorEvent;
    import events.actions.gameplay.colors.SetMissflagComboColorEvent;
    import events.actions.gameplay.colors.SetNormalComboColorEvent;
    import events.actions.gameplay.colors.SetNoteColorEvent;
    import events.actions.gameplay.colors.SetSDGComboColorEvent;
    import events.actions.gameplay.colors.ToggleAAAComboColorEvent;
    import events.actions.gameplay.colors.ToggleAvflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleBlackflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleBooflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleFCComboColorEvent;
    import events.actions.gameplay.colors.ToggleMissflagComboColorEvent;
    import events.actions.gameplay.colors.ToggleSDGComboColorEvent;
    import events.actions.gameplay.input.SetKeyDownEvent;
    import events.actions.gameplay.input.SetKeyLeftEvent;
    import events.actions.gameplay.input.SetKeyOptionsEvent;
    import events.actions.gameplay.input.SetKeyQuitEvent;
    import events.actions.gameplay.input.SetKeyRestartEvent;
    import events.actions.gameplay.input.SetKeyRightEvent;
    import events.actions.gameplay.input.SetKeyUpEvent;
    import flash.events.IEventDispatcher;
    import state.AppState;
    import events.actions.gameplay.AutoJudgeOffsetToggledEvent;
    import events.actions.gameplay.SetRawGoodTrackerEvent;
    import events.actions.gameplay.ToggleGameModEvent;
    import events.actions.gameplay.ToggleVisualModEvent;

    public class GameplayController extends Controller
    {
        public function GameplayController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);

            addListeners();
        }

        private function addListeners():void
        {
            target.addEventListener(ClearSongQueueEvent.EVENT_TYPE, clearSongQueue);
            target.addEventListener(SetScrollSpeedEvent.EVENT_TYPE, setScrollSpeed);
            target.addEventListener(SetReceptorGapEvent.EVENT_TYPE, setReceptorGap);
            target.addEventListener(SetNoteScaleEvent.EVENT_TYPE, setNoteScale);
            target.addEventListener(SetGlobalOffsetEvent.EVENT_TYPE, setGlobalOffset);
            target.addEventListener(SetJudgeOffsetEvent.EVENT_TYPE, setJudgeOffset);
            target.addEventListener(ToggleAutoJudgeOffsetEvent.EVENT_TYPE, toggleAutoJudgeOffset);
            target.addEventListener(SetAutofailAmazingEvent.EVENT_TYPE, setAutofailAmazing);
            target.addEventListener(SetAutofailPerfectEvent.EVENT_TYPE, setAutofailPerfect);
            target.addEventListener(SetAutofailGoodEvent.EVENT_TYPE, setAutofailGood);
            target.addEventListener(SetAutofailAverageEvent.EVENT_TYPE, setAutofailAverage);
            target.addEventListener(SetAutofailMissEvent.EVENT_TYPE, setAutofailMiss);
            target.addEventListener(SetAutofailBooEvent.EVENT_TYPE, setAutofailBoo);
            target.addEventListener(SetAutofailRawGoodsEvent.EVENT_TYPE, setAutofailRawGoods);
            target.addEventListener(SetScrollDirectionEvent.EVENT_TYPE, setScrollDirection);
            target.addEventListener(ToggleMirrorEvent.EVENT_TYPE, toggleMirror);
            target.addEventListener(SetSongRateEvent.EVENT_TYPE, setSongRate);

            target.addEventListener(SetKeyLeftEvent.EVENT_TYPE, setKeyLeft);
            target.addEventListener(SetKeyDownEvent.EVENT_TYPE, setKeyDown);
            target.addEventListener(SetKeyUpEvent.EVENT_TYPE, setKeyUp);
            target.addEventListener(SetKeyRightEvent.EVENT_TYPE, setKeyRight);
            target.addEventListener(SetKeyRestartEvent.EVENT_TYPE, setKeyRestart);
            target.addEventListener(SetKeyQuitEvent.EVENT_TYPE, setKeyQuit);
            target.addEventListener(SetKeyOptionsEvent.EVENT_TYPE, setKeyOptions);

            target.addEventListener(SetNoteColorEvent.EVENT_TYPE, setNoteColor);
            target.addEventListener(SetNoteskinIdEvent.EVENT_TYPE, setNoteskinId);
            target.addEventListener(ToggleCustomNoteskinEvent.EVENT_TYPE, toggleCustomNoteskin);

            target.addEventListener(SetJudgeColorEvent.EVENT_TYPE, setJudgeColor);

            target.addEventListener(SetGameAColorEvent.EVENT_TYPE, setGameAColor);
            target.addEventListener(SetGameBColorEvent.EVENT_TYPE, setGameBColor);
            target.addEventListener(SetGameCColorEvent.EVENT_TYPE, setGameCColor);

            target.addEventListener(SetNormalComboColorEvent.EVENT_TYPE, setNormalComboColor);
            target.addEventListener(SetFCComboColorEvent.EVENT_TYPE, setFCComboColor);
            target.addEventListener(SetAAAComboColorEvent.EVENT_TYPE, setAAAComboColor);
            target.addEventListener(SetSDGComboColorEvent.EVENT_TYPE, setSDGComboColor);
            target.addEventListener(SetBlackflagComboColorEvent.EVENT_TYPE, setBlackflagComboColor);
            target.addEventListener(SetAvflagComboColorEvent.EVENT_TYPE, setAvflagComboColor);
            target.addEventListener(SetBooflagComboColorEvent.EVENT_TYPE, setBooflagComboColor);
            target.addEventListener(SetMissflagComboColorEvent.EVENT_TYPE, setMissflagComboColor);

            target.addEventListener(ToggleFCComboColorEvent.EVENT_TYPE, toggleFCComboColor);
            target.addEventListener(ToggleAAAComboColorEvent.EVENT_TYPE, toggleAAAComboColor);
            target.addEventListener(ToggleSDGComboColorEvent.EVENT_TYPE, toggleSDGComboColor);
            target.addEventListener(ToggleBlackflagComboColorEvent.EVENT_TYPE, toggleBlackflagComboColor);
            target.addEventListener(ToggleAvflagComboColorEvent.EVENT_TYPE, toggleAvflagComboColor);
            target.addEventListener(ToggleBooflagComboColorEvent.EVENT_TYPE, toggleBooflagComboColor);
            target.addEventListener(ToggleMissflagComboColorEvent.EVENT_TYPE, toggleMissflagComboColor);

            target.addEventListener(SetRawGoodTrackerEvent.EVENT_TYPE, setRawGoodTracker);

            target.addEventListener(ToggleGameModEvent.EVENT_TYPE, toggleGameMod);
            target.addEventListener(ToggleVisualModEvent.EVENT_TYPE, toggleVisualMod);
        }

        private function clearSongQueue():void
        {
            var newState:AppState = AppState.clone(owner);
            newState.gameplay.songQueue = [];
            newState.gameplay.songQueueIndex = 0;

            updateState(newState);
        }

        private function setScrollSpeed(event:SetScrollSpeedEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.scrollSpeed = event.speed;

            updateState(newState);
        }

        private function setReceptorGap(event:SetReceptorGapEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.receptorGap = event.gap;

            updateState(newState);
        }

        private function setNoteScale(event:SetNoteScaleEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.noteScale = event.scale;

            updateState(newState);
        }

        private function setGlobalOffset(event:SetGlobalOffsetEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.globalOffset = event.offset;

            updateState(newState);
        }

        private function setJudgeOffset(event:SetJudgeOffsetEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.judgeOffset = event.offset;

            updateState(newState);
        }

        private function toggleAutoJudgeOffset(event:ToggleAutoJudgeOffsetEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autoJudgeOffset = !newState.auth.user.settings.autoJudgeOffset;

            updateState(newState);

            target.dispatchEvent(new AutoJudgeOffsetToggledEvent());
        }

        private function setAutofailAmazing(event:SetAutofailAmazingEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailAmazing = event.count;

            updateState(newState);
        }

        private function setAutofailPerfect(event:SetAutofailPerfectEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailPerfect = event.count;

            updateState(newState);
        }

        private function setAutofailGood(event:SetAutofailGoodEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailGood = event.count;

            updateState(newState);
        }

        private function setAutofailAverage(event:SetAutofailAverageEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailAverage = event.count;

            updateState(newState);
        }

        private function setAutofailMiss(event:SetAutofailMissEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailMiss = event.count;

            updateState(newState);
        }

        private function setAutofailBoo(event:SetAutofailBooEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailBoo = event.count;

            updateState(newState);
        }

        private function setAutofailRawGoods(event:SetAutofailRawGoodsEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.autofailRawGoods = event.count;

            updateState(newState);
        }

        private function setScrollDirection(event:SetScrollDirectionEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.scrollDirection = event.direction;

            updateState(newState);
        }

        private function toggleMirror(event:ToggleMirrorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var userSettings:UserSettings = newState.auth.user.settings;

            if (userSettings.activeVisualMods.indexOf("mirror") != -1)
                ArrayUtil.removeValue("mirror", userSettings.activeVisualMods);
            else
                userSettings.activeVisualMods.push("mirror");

            updateState(newState);
        }

        private function setSongRate(event:SetSongRateEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.songRate = event.rate;

            updateState(newState);
        }

        private function setKeyLeft(event:SetKeyLeftEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyLeft = event.keyCode;

            updateState(newState);
        }

        private function setKeyDown(event:SetKeyDownEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyDown = event.keyCode;

            updateState(newState);
        }

        private function setKeyUp(event:SetKeyUpEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyUp = event.keyCode;

            updateState(newState);
        }

        private function setKeyRight(event:SetKeyRightEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyRight = event.keyCode;

            updateState(newState);
        }

        private function setKeyRestart(event:SetKeyRestartEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyRestart = event.keyCode;

            updateState(newState);
        }

        private function setKeyQuit(event:SetKeyQuitEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyQuit = event.keyCode;

            updateState(newState);
        }

        private function setKeyOptions(event:SetKeyOptionsEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.keyOptions = event.keyCode;

            updateState(newState);
        }

        private function setNoteColor(event:SetNoteColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.noteColors[event.colorIndex] = event.color;

            updateState(newState);

            target.dispatchEvent(new NoteColorChangedEvent());
        }

        private function setNoteskinId(event:SetNoteskinIdEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var noteskinIdChanged:Boolean = newState.auth.user.settings.noteskinId == event.noteskinId;

            if (!noteskinIdChanged)
                return;

            newState.auth.user.settings.noteskinId = event.noteskinId;
            updateState(newState);

            target.dispatchEvent(new CustomNoteskinToggledEvent());
        }

        private function toggleCustomNoteskin(event:ToggleCustomNoteskinEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.noteskinId = 0;

            updateState(newState);

            target.dispatchEvent(new CustomNoteskinToggledEvent());
        }

        private function setJudgeColor(event:SetJudgeColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.auth.user.settings.judgeColors[event.judgeIndex] = event.color;

            updateState(newState);
        }

        private function setGameAColor(event:SetGameAColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.gameColors[0] = event.color;
            user.settings.gameColors[2] = ColorUtil.darkenColor(event.color, 0.27);

            updateState(newState);

            target.dispatchEvent(new GameAColorChangedEvent());
        }

        private function setGameBColor(event:SetGameBColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.gameColors[1] = event.color;
            user.settings.gameColors[3] = ColorUtil.brightenColor(event.color, 0.08);

            updateState(newState);

            target.dispatchEvent(new GameBColorChangedEvent());
        }

        private function setGameCColor(event:SetGameCColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.gameColors[4] = event.color;

            updateState(newState);

            target.dispatchEvent(new GameCColorChangedEvent());
        }

        private function setNormalComboColor(event:SetNormalComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[0] = event.color;

            updateState(newState);
        }

        private function setFCComboColor(event:SetFCComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[1] = event.color;

            updateState(newState);
        }

        private function toggleFCComboColor(event:ToggleFCComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[1] = !user.settings.enableComboColors[1];

            updateState(newState);
        }

        private function setAAAComboColor(event:SetAAAComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[2] = event.color;

            updateState(newState);
        }

        private function toggleAAAComboColor(event:ToggleAAAComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[2] = !user.settings.enableComboColors[2];

            updateState(newState);
        }

        private function setSDGComboColor(event:SetSDGComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[3] = event.color;

            updateState(newState);
        }

        private function toggleSDGComboColor(event:ToggleSDGComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[3] = !user.settings.enableComboColors[3];

            updateState(newState);
        }

        private function setBlackflagComboColor(event:SetBlackflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[4] = event.color;

            updateState(newState);
        }

        private function toggleBlackflagComboColor(event:ToggleBlackflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[4] = !user.settings.enableComboColors[4];

            updateState(newState);
        }

        private function setAvflagComboColor(event:SetAvflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[5] = event.color;

            updateState(newState);
        }

        private function toggleAvflagComboColor(event:ToggleAvflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[5] = !user.settings.enableComboColors[5];

            updateState(newState);
        }

        private function setBooflagComboColor(event:SetBooflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[6] = event.color;

            updateState(newState);
        }

        private function toggleBooflagComboColor(event:ToggleBooflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[6] = !user.settings.enableComboColors[6];

            updateState(newState);
        }

        private function setMissflagComboColor(event:SetMissflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.comboColors[7] = event.color;

            updateState(newState);
        }

        private function toggleMissflagComboColor(event:ToggleMissflagComboColorEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.enableComboColors[7] = !user.settings.enableComboColors[7];

            updateState(newState);
        }

        private function setRawGoodTracker(event:SetRawGoodTrackerEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var user:User = newState.auth.user;

            user.settings.rawGoodTracker = event.count;

            updateState(newState);
        }

        private function toggleGameMod(event:ToggleGameModEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var settings:UserSettings = newState.auth.user.settings;
            var mod:String = event.mod;

            if (settings.activeMods.indexOf(mod) != -1)
                ArrayUtil.removeValue(mod, settings.activeMods);
            else
                settings.activeMods.push(mod);

            updateState(newState);
        }

        private function toggleVisualMod(event:ToggleVisualModEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var settings:UserSettings = newState.auth.user.settings;
            var mod:String = event.mod;

            if (settings.activeVisualMods.indexOf(mod) != -1)
                ArrayUtil.removeValue(mod, settings.activeVisualMods);
            else
                settings.activeVisualMods.push(mod);

            updateState(newState);
        }
    }
}
