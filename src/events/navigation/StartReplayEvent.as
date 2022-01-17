package events.navigation
{

    import flash.events.Event;
    import classes.replay.Replay;

    public class StartReplayEvent extends ChangePanelEvent
    {
        private var _replay:Replay;

        public function StartReplayEvent(replay:Replay):void
        {
            _replay = replay;

            super(Routes.PANEL_GAMEPLAY);
        }

        public function get replay():Replay
        {
            return _replay;
        }

        override public function clone():Event
        {
            return new StartReplayEvent(_replay);
        }
    }
}
