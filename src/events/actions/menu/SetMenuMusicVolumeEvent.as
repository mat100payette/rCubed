package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class SetMenuMusicVolumeEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "LoadMenuMusicEvent";

        private var _volume:Number;

        public function SetMenuMusicVolumeEvent(volume:Number):void
        {
            super();

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
