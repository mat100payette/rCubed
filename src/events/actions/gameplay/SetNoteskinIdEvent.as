package events.actions.gameplay
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class SetNoteskinIdEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "SetNoteskinIdEvent";

        private var _noteskinId:int;

        public function SetNoteskinIdEvent(noteskinId:Number):void
        {
            super();

            _noteskinId = noteskinId;
        }

        public function get noteskinId():Number
        {
            return _noteskinId;
        }

        override public function clone():Event
        {
            return new SetNoteskinIdEvent(_noteskinId);
        }
    }
}
