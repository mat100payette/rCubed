package state_management
{

    import events.state.SetMenuMusicVolumeEvent;
    import events.state.SetPopupsEnabledEvent;
    import events.state.StateEvent;
    import flash.events.IEventDispatcher;
    import state.AppState;
    import state.MenuState;

    public class MenuController extends Controller
    {
        private var _target:IEventDispatcher;

        public function MenuController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case SetPopupsEnabledEvent.STATE:
                    onSetPopupsEnabled(e as SetPopupsEnabledEvent);
                    break;
                case SetMenuMusicVolumeEvent.STATE:
                    setMenuMusicVolume(e as SetMenuMusicVolumeEvent);
                    break;
            }
        }

        private function onSetPopupsEnabled(e:SetPopupsEnabledEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            newState.menu.disablePopups = e.enabled;

            updateState(newState);
        }

        private function setMenuMusicVolume(e:SetMenuMusicVolumeEvent):void
        {
            var newState:AppState = AppState.clone(owner);
            var menuState:MenuState = newState.menu;

            var volume:Number = e.volume;
            if (isNaN(volume))
                volume = 1;

            menuState.menuMusicSoundVolume = volume;
            menuState.menuMusicSoundTransform.volume = volume;

            if (_gvars.menuMusic && _gvars.menuMusic.isPlaying)
                _gvars.menuMusic.soundChannel.soundTransform = _gvars.menuMusicSoundTransform;

            updateState(newState);
        }

        public function loadMenuMusic():void
        {
            menuMusicSoundVolume = menuMusicSoundTransform.volume = LocalOptions.getVariable("menu_music_volume", 1);

            // Load Existing Menu Music SWF
            if (AirContext.doesFileExist(Constant.MENU_MUSIC_PATH))
            {
                var file_bytes:ByteArray = AirContext.readFile(AirContext.getAppFile(Constant.MENU_MUSIC_PATH));
                if (file_bytes && file_bytes.length > 0)
                {
                    menuMusic = new SongBytes(file_bytes);
                }
            }
            // Convert MP3 if exist.
            else if (AirContext.doesFileExist(Constant.MENU_MUSIC_MP3_PATH))
            {
                var mp3Bytes:ByteArray = AirContext.readFile(AirContext.getAppFile(Constant.MENU_MUSIC_MP3_PATH));
                if (mp3Bytes && mp3Bytes.length > 0)
                {
                    menuMusic = new SongBytes(mp3Bytes, true);
                    LocalStore.setVariable("menu_music", "External MP3");
                }
            }
        }
    }
}
