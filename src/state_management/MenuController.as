package state_management
{

    import classes.SoundPlayer;
    import events.actions.menu.LoadMenuMusicEvent;
    import events.actions.menu.SetMenuMusicVolumeEvent;
    import events.actions.menu.SetPopupsEnabledEvent;
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;
    import singletons.MenuMusicPlayer;
    import state.AppState;

    public class MenuController extends Controller
    {
        private var _target:IEventDispatcher;

        public function MenuController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);

            addListeners();
        }

        private function addListeners():void
        {
            target.addEventListener(SetPopupsEnabledEvent.EVENT_TYPE, setPopupsEnabled);
            target.addEventListener(SetMenuMusicVolumeEvent.EVENT_TYPE, setMenuMusicVolume);
            target.addEventListener(LoadMenuMusicEvent.EVENT_TYPE, loadMenuMusic);
        }

        private function setPopupsEnabled(e:SetPopupsEnabledEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.menu.disablePopups = e.enabled;

            updateState(newState);
        }

        private function setMenuMusicVolume(e:SetMenuMusicVolumeEvent):void
        {
            var menuPlayer:SoundPlayer = MenuMusicPlayer.getPlayer(this);

            var volume:Number = e.volume;
            menuPlayer.volume = volume;

            LocalOptions.setVariable("menu_music_volume", 1);
        }

        public function loadMenuMusic():void
        {
            var menuPlayer:SoundPlayer = MenuMusicPlayer.getPlayer(this);

            menuPlayer.soundTransform.volume = LocalOptions.getVariable("menu_music_volume", 1);

            // Load Existing Menu Music SWF
            if (AirContext.doesFileExist(Constant.MENU_MUSIC_PATH))
            {
                var fileBytes:ByteArray = AirContext.readFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH));
                if (fileBytes && fileBytes.length > 0)
                    menuPlayer.setBytes(fileBytes);
            }
            // Convert MP3 if exist.
            else if (AirContext.doesFileExist(Constant.MENU_MUSIC_MP3_PATH))
            {
                var mp3Bytes:ByteArray = AirContext.readFile(AirContext.getAppFile(Constant.MENU_MUSIC_MP3_PATH));
                if (mp3Bytes && mp3Bytes.length > 0)
                {
                    menuPlayer.setBytes(mp3Bytes, true);
                    LocalStore.setVariable("menu_music", "External MP3");
                }
            }
        }

        private function deleteMenuMusic():void
        {
            var menuPlayer:SoundPlayer = MenuMusicPlayer.getPlayer(this);

            menuPlayer.userStop();

            menuMusicControls.parent.removeChild(menuMusicControls);

            AirContext.deleteFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH));
        }
    }
}
