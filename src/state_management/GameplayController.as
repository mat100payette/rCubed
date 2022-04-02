package state_management
{
    import events.state.LogoutEvent;
    import events.state.StateEvent;
    import flash.events.IEventDispatcher;

    public class GameplayController extends Controller
    {
        public function GameplayController(target:IEventDispatcher, owner:Object, updateStateCallback:Function)
        {
            super(target, owner, updateStateCallback);
        }

        override public function onStateEvent(e:StateEvent):void
        {
            var stateName:String = e.stateName;

            switch (stateName)
            {
                case LogoutEvent.STATE:
                    break;
            }
        }
    }
}
