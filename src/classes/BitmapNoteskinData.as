package classes
{

    public class BitmapNoteskinData
    {
        private var _name:String;
        private var _data:String;
        private var _rects:Object;

        public function BitmapNoteskinData(name:String, data:String, rects:Object):void
        {
            _name = name;
            _data = data;
            _rects = rects;
        }

        public function get name():String
        {
            return _name;
        }

        public function get data():String
        {
            return _data;
        }

        public function get rects():Object
        {
            return _rects;
        }
    }
}
