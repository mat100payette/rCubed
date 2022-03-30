package state
{

    public interface IState
    {
        function freeze():void;

        function clone():State;
    }
}
