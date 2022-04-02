package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IMenuEvent;

    public class SetMenuMusicVolumeEvent extends StateEvent implements IMenuEvent
    {
        public static const STATE:String = "SetMenuMusicVolume";

        private var _volume:Number;

        public function SetMenuMusicVolumeEvent(volume:Number):void
        {
            super(STATE);

            _volume = volume;
        }

        public function get volume():Number
        {
            return _volume;
        }

        override public function clone():Event
        {
            return new SetMenuMusicVolumeEvent(_volume);
        }
    }
}
