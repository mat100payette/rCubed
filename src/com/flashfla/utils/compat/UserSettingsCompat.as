package com.flashfla.utils.compat
{

    import classes.UserSettings;
    import arc.ArcGlobals;
    import com.flashfla.utils.ArrayUtil;
    import com.flashfla.utils.VectorUtil;

    public class UserSettingsCompat
    {
        public static const R3_v1_4_REPLAY:String = "R3_1.4_REPLAY";

        public static function update(settings:UserSettings, newSettings:Object, versionFlag:String):void
        {
            if (versionFlag == R3_v1_4_REPLAY)
                _updateSettingsR3v13(settings, newSettings);
        }

        /**
         * Updates a modern `UserSettings` object with an R^3 pre-1.4 replay version.
         * @param settings
         * @param newSettings
         */
        private static function _updateSettingsR3v13(settings:UserSettings, newSettings:Object):void
        {
            if (newSettings == null)
                return;

            if (newSettings.language != null)
                settings.language = newSettings.language;

            if (newSettings.viewOffset != null)
                settings.GLOBAL_OFFSET = newSettings.viewOffset;

            if (newSettings.judgeOffset != null)
                settings.JUDGE_OFFSET = newSettings.judgeOffset;

            if (newSettings.autoJudgeOffset != null)
                settings.AUTO_JUDGE_OFFSET = newSettings.autoJudgeOffset;

            if (newSettings.viewHealth != null)
                settings.DISPLAY_HEALTH = newSettings.viewHealth;

            if (newSettings.viewCombo != null)
                settings.DISPLAY_COMBO = newSettings.viewCombo;

            if (newSettings.viewPACount != null)
                settings.DISPLAY_PACOUNT = newSettings.viewPACount;

            if (newSettings.viewAmazing != null)
                settings.DISPLAY_AMAZING = newSettings.viewAmazing;

            if (newSettings.viewTotal != null)
                settings.DISPLAY_TOTAL = newSettings.viewTotal;

            if (newSettings.viewScreencut != null)
                settings.DISPLAY_SCREENCUT = newSettings.viewScreencut;

            if (newSettings.keys != null)
            {
                if (newSettings.keys[0] != null)
                    settings.keyLeft = newSettings.keys[0];

                if (newSettings.keys[1] != null)
                    settings.keyDown = newSettings.keys[1];

                if (newSettings.keys[2] != null)
                    settings.keyUp = newSettings.keys[2];

                if (newSettings.keys[3] != null)
                    settings.keyRight = newSettings.keys[3];

                if (newSettings.keys[4] != null)
                    settings.keyRestart = newSettings.keys[4];

                if (newSettings.keys[5] != null)
                    settings.keyQuit = newSettings.keys[5];

                if (newSettings.keys[6] != null)
                    settings.keyOptions = newSettings.keys[6];
            }

            if (newSettings.noteskin != null)
                settings.activeNoteskin = newSettings.noteskin;

            if (newSettings.direction != null)
                settings.scrollDirection = newSettings.direction;

            if (newSettings.speed != null)
                settings.scrollSpeed = newSettings.speed;

            if (newSettings.gap != null)
                settings.receptorGap = newSettings.gap;

            if (newSettings.noteScale != null)
                settings.noteScale = newSettings.noteScale;

            if (newSettings.screencutPosition != null)
                settings.screencutPosition = newSettings.screencutPosition;

            if (newSettings.frameRate != null)
                settings.frameRate = newSettings.frameRate;

            if (newSettings.songRate != null)
                settings.songRate = newSettings.songRate;

            if (newSettings.forceNewJudge != null)
                settings.forceNewJudge = newSettings.forceNewJudge;

            if (newSettings.visual != null)
                settings.activeVisualMods = newSettings.visual;

            if (newSettings.judgeColors != null)
                ArrayUtil.merge(settings.judgeColors, newSettings.judgeColors);

            if (newSettings.comboColors != null)
                ArrayUtil.merge(settings.comboColors, newSettings.comboColors);

            if (newSettings.enableComboColors != null)
                VectorUtil.mergeArray(settings.enableComboColors, newSettings.enableComboColors);

            if (newSettings.gameColors != null)
                ArrayUtil.merge(settings.gameColors, newSettings.gameColors);

            if (newSettings.noteColors != null)
                ArrayUtil.merge(settings.noteColors, newSettings.noteColors);

            if (newSettings.rawGoodTracker != null)
                settings.rawGoodTracker = newSettings.rawGoodTracker;

            if (newSettings.gameVolume != null)
                settings.gameVolume = newSettings.gameVolume;

            if (newSettings.isolationOffset != null)
                settings.isolationOffset = newSettings.isolationOffset;

            if (newSettings.isolationLength != null)
                settings.isolationLength = newSettings.isolationLength;
        }
    }
}
