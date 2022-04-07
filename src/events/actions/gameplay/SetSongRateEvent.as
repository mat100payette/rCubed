package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetSongRateEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetSongRateEvent";

        private var _rate:Number;

        public function SetSongRateEvent(rate:Number):void
        {
            super();

            _rate = rate;
        }

        public function get rate():Number
        {
            return _rate;
        }

        override public function clone():Event
        {
            return new SetSongRateEvent(_rate);
        }
    }
}
