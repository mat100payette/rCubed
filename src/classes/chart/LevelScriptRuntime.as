package classes.chart
{
    import game.GameplayDisplay;
    import classes.UserSettings;

    /**
     * @author FictionVoid
     */
    public class LevelScriptRuntime implements ILevelScriptRuntime
    {
        private var _settings:UserSettings;
        private var _levelScript:ILevelScript;

        public function LevelScriptRuntime(settings:UserSettings, script:ILevelScript)
        {
            _settings = settings;
            _levelScript = script;
            _levelScript.init(this);
        }

        public function doProgressTick(frame:int):void
        {
            _levelScript.doFrameEvent(frame);
        }

        public function destroy():void
        {

        }

        public function registerNoteskin(json_data:String):Boolean
        {
            return true;
        }

        public function unregisterNoteskin(id:int):Boolean
        {
            return true;
        }

        public function addMod(mod:String):void
        {
            _settings.modCache[mod] = true;
        }

        public function removeMod(mod:String):void
        {
            delete _settings.modCache[mod];
        }

        public function setNotescale(value:Number):void
        {
            _settings.noteScale = value;
        }

        public function setNoteskin(id:int):void
        {
            _settings.noteskinId = id;
        }

        public function setNotePool(enabled:Boolean):void
        {
            options.disableNotePool = !enabled;
        }

    }

}
