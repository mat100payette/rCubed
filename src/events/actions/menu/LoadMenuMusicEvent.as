package events.actions.menu
{

    import flash.events.Event;
    import events.actions.ActionEvent;
    import events.interfaces.IMenuEvent;

    public class LoadMenuMusicEvent extends ActionEvent implements IMenuEvent
    {
        public static const EVENT_TYPE:String = "LoadMenuMusicEvent";

        public function LoadMenuMusicEvent():void
        {
            super();
        }

        override public function clone():Event
        {
            return new LoadMenuMusicEvent();
        }
    }
}
