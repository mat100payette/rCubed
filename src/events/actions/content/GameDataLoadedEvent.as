package events.actions.content
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IContentEvent;

    public class GameDataLoadedEvent extends ActionEvent implements IContentEvent
    {
        public static const EVENT_TYPE:String = "GameDataLoadedEvent";

        public function GameDataLoadedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new GameDataLoadedEvent();
        }
    }
}
