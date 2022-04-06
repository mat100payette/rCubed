package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class SetPopupsEnabledEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "SetPopupsEnabledEvent";

        private var _enabled:Boolean;

        public function SetPopupsEnabledEvent(enabled:Boolean):void
        {
            super();

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
