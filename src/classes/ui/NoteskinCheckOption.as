package classes.ui
{

    public class NoteskinCheckOption
    {
        private var _text:Text;
        private var _checkbox:BoxCheck;
        private var _noteskinId:uint;

        public function NoteskinCheckOption(text:Text, checkbox:BoxCheck, noteskinId:uint):void
        {
            _text = text;
            _checkbox = checkbox;
            _noteskinId = noteskinId;
        }

        public function get text():Text
        {
            return _text;
        }

        public function get checkbox():BoxCheck
        {
            return _checkbox;
        }

        public function get noteskinId():uint
        {
            return _noteskinId;
        }
    }
}
