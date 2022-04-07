package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetScrollDirectionEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetScrollDirectionEvent";

        private var _direction:String;

        public function SetScrollDirectionEvent(direction:String):void
        {
            super();

            _direction = direction;
        }

        public function get direction():String
        {
            return _direction;
        }

        override public function clone():Event
        {
            return new SetScrollDirectionEvent(_direction);
        }
    }
}
