package classes
{

    public class Noteskin
    {
        public static const TYPE_SWF:uint = 0;
        public static const TYPE_BITMAP:uint = 1;

        private var _id:uint;
        private var _name:String;
        private var _type:uint;

        public var rotation:uint;
        public var width:uint;
        public var height:uint;

        public var notes:Object = {};
        public var hidden:Boolean = false;
        public var receptor:Object = null;

        public function Noteskin(id:uint, name:String, type:uint, rotation:uint = 0, width:uint = 0, height:uint = 0):void
        {
            _id = id;
            _name = name;
            _type = type;
            this.rotation = rotation;
            this.width = width;
            this.height = height;
        }

        public function toJSON():Object
        {
            return {"id": _id,
                    "name": _name,
                    "rotation": rotation,
                    "width": width,
                    "height": height}
        }

        public function get id():uint
        {
            return _id;
        }

        public function get name():String
        {
            return _name;
        }

        public function get type():uint
        {
            return _type;
        }
    }
}
