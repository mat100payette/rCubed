package classes.ui
{

    public class WindowState
    {
        public var x:int;
        public var y:int;
        public var width:int;
        public var height:int;

        public function WindowState(x:int = 0, y:int = 0, width:int = Main.GAME_WIDTH, height:int = Main.GAME_HEIGHT):void
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
        }

        public function clone():WindowState
        {
            var cloned:WindowState = new WindowState();
            cloned.x = x;
            cloned.y = y;
            cloned.width = width;
            cloned.height = height;

            return cloned;
        }

        // TODO: Check if needed
        public function toJSON(_:String):Object
        {
            return {"x": x, "y": y, "width": width, "height": height};
        }
    }
}
