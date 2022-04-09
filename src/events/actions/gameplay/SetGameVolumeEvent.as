package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetGameVolumeEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetGameVolumeEvent";

        private var _volume:Number;

        public function SetGameVolumeEvent(volume:Number):void
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
            return new SetGameVolumeEvent(_volume);
        }
    }
}
