package classes.ui
{

    public class WindowProperties
    {
        public var x:int;
        public var y:int;
        public var width:int;
        public var height:int;

        public function WindowProperties(x:int = 0, y:int = 0, width:int = Main.GAME_WIDTH, height:int = Main.GAME_HEIGHT):void
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
        }

        // TODO: Check if needed
        public function toJSON(_:String):Object
        {
            return {"x": x, "y": y, "width": width, "height": height};
        }
    }
}
