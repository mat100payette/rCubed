package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetReceptorGapEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetReceptorGapEvent";

        private var _gap:Number;

        public function SetReceptorGapEvent(gap:Number):void
        {
            super();

            _gap = gap;
        }

        public function get gap():Number
        {
            return _gap;
        }

        override public function clone():Event
        {
            return new SetReceptorGapEvent(_gap);
        }
    }
}
