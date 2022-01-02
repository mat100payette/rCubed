package game.noteskins
{
    import classes.Noteskin;
    import flash.utils.ByteArray;

    public interface IEmbeddedNoteskin
    {
        function get noteskin():Noteskin;

        function get bytes():ByteArray;

        function get id():uint;
    }
}
