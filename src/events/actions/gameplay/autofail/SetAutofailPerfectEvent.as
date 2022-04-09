package events.actions.gameplay.autofail
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetAutofailPerfectEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetAutofailPerfectEvent";

        private var _count:Number;

        public function SetAutofailPerfectEvent(count:Number):void
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
            return new SetAutofailPerfectEvent(_count);
        }
    }
}
