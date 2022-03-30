package events.state.interfaces
{

    import flash.events.Event;

    public interface IStateEvent
    {
        function clone():Event;
    }
}
