package state
{

    public class MenuState extends State implements IState
    {
        private var _disablePopups:Boolean;
        private var _menuMusicSoundVolume:Number;

        public function MenuState(frozen:Boolean = false)
        {
            super(frozen);

            _disablePopups = true;
            _menuMusicSoundVolume = 1;
        }

        public function freeze():void
        {
            super.internalFreeze();
        }

        public function clone():State
        {
            var cloned:MenuState = new MenuState(false);

            cloned._disablePopups = _disablePopups;
            cloned._menuMusicSoundVolume = _menuMusicSoundVolume;

            return cloned;
        }

        public function get disablePopups():Boolean
        {
            return _disablePopups;
        }

        public function set disablePopups(value:Boolean):void
        {
            throwIfFrozen();
            _disablePopups = value;
        }

        public function get menuMusicSoundVolume():Number
        {
            return _menuMusicSoundVolume;
        }

        public function set menuMusicSoundVolume(value:Number):void
        {
            throwIfFrozen();
            _menuMusicSoundVolume = value;
        }
    }
}
