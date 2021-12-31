package popups.settings
{

    import classes.UserSettings;

    public class SettingsTabDebug extends SettingsTabBase
    {

        public function SettingsTabDebug(settingsWindow:SettingsWindow, settings:UserSettings):void
        {
            super(settingsWindow, settings);
        }

        override public function get name():String
        {
            return "debug";
        }

        override public function openTab():void
        {

        }

        override public function setValues():void
        {

        }
    }
}
