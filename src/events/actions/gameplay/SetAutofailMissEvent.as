package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetAutofailMissEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetAutofailMissEvent";

        private var _count:Number;

        public function SetAutofailMissEvent(count:Number):void
        {
            super();

            _count = count;
        }

        public function get count():Number
        {
            return _count;
        }

        override public function clone():Event
        {
            return new SetAutofailMissEvent(_count);
        }
    }
}
