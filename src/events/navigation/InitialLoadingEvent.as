package events.navigation
{

    public class InitialLoadingEvent extends ChangePanelEvent
    {
        private var _userLoggedIn:Boolean;

        public function InitialLoadingEvent(userLoggedIn:Boolean):void
        {
            _userLoggedIn = userLoggedIn;
            super(Routes.PANEL_INITIAL_LOADING);
        }

        public function get userLoggedIn():Boolean
        {
            return _userLoggedIn;
        }
    }
}
