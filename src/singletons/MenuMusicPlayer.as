package singletons
{

    import classes.SoundPlayer;
    import flash.media.SoundTransform;

    public class MenuMusicPlayer
    {
        private static var _instance:MenuMusicPlayer = null;

        private var _owner:Object;

        private var _menuMusicPlayer:SoundPlayer;

        public function MenuMusicPlayer(owner:Object)
        {
            if (_instance != null && owner != _instance._owner)
                throw new Error("Multiple state instances not allowed");

            _owner = owner;
            _instance = this;
        }

        public static function get instance():MenuMusicPlayer
        {
            return _instance;
        }

        public static function getPlayer(owner:Object):SoundPlayer
        {
            if (_instance == null || owner != _instance._owner)
                throw new Error("Arbitrary modification of state");

            return _instance._menuMusicPlayer;
        }
    }
}
