package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class GameCColorChangedEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "GameCColorChangedEvent";

        public function GameCColorChangedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new GameCColorChangedEvent();
        }
    }
}
