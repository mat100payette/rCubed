package events.actions.gameplay.colors
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IGameplayEvent;

    public class GameBColorChangedEvent extends ActionEvent implements IGameplayEvent
    {
        public static const EVENT_TYPE:String = "GameBColorChangedEvent";

        public function GameBColorChangedEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new GameBColorChangedEvent();
        }
    }
}
