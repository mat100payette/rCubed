package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class GameAColorChangedEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "GameAColorChangedEvent";

        public function GameAColorChangedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new GameAColorChangedEvent();
        }
    }
}
