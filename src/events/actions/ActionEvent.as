package events.actions
{

    import flash.events.Event;

    public class ActionEvent extends Event
    {
        public static const EVENT_TYPE:String = "ActionEvent";

        public function ActionEvent():void
        {
            super(EVENT_TYPE, true);
        }
    }
}
