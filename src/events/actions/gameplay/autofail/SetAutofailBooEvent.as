package events.actions.gameplay.autofail
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetAutofailBooEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetAutofailBooEvent";

        private var _count:Number;

        public function SetAutofailBooEvent(count:Number):void
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
            return new SetAutofailBooEvent(_count);
        }
    }
}
