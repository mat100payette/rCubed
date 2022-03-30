package events.state
{

    import flash.events.Event;
    import events.state.interfaces.IMenuStateEvent;

    public class SetPopupsEnabledEvent extends StateEvent implements IMenuStateEvent
    {
        public static const STATE:String = "SetPopupsEnabled";

        private var _enabled:Boolean;

        public function SetPopupsEnabledEvent(enabled:Boolean):void
        {
            super(STATE);

            _enabled = enabled;
        }

        public function get enabled():Boolean
        {
            return _enabled;
        }

        override public function clone():Event
        {
            return new SetPopupsEnabledEvent(_enabled);
        }
    }
}
