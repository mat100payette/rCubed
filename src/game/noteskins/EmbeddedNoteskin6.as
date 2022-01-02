package game.noteskins
{
    import classes.Noteskin;
    import flash.utils.ByteArray;

    public class EmbeddedNoteskin6 implements IEmbeddedNoteskin
    {
        [Embed(source = "Noteskin6.swf", mimeType = "application/octet-stream")]
        private static const EMBED_SWF:Class;
        private static const ID:int = 6;
        private static const NOTESKIN:Noteskin = new Noteskin(ID, "Delta", Noteskin.TYPE_SWF, 90, 64, 64);

        private static var _cachedSWF:ByteArray;

        public function get noteskin():Noteskin
        {
            return NOTESKIN;
        }

        public function get bytes():ByteArray
        {
            if (_cachedSWF != null)
                return _cachedSWF;

            _cachedSWF = new EMBED_SWF();
            return _cachedSWF;
        }

        public function get id():uint
        {
            return ID;
        }
    }
}
