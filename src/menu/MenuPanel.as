package menu
{
    import flash.display.Sprite;

    public class MenuPanel extends Sprite
    {
        private var _listeners:Array = [];
        public var hasInit:Boolean = false;

        public function MenuPanel()
        {
            super();
        }

        // Init status depended on use of switchTo in init function. If the function calls a switchTo, return false here. 
        public function init():Boolean
        {
            return true;
        }

        public function dispose():void
        {
        }

        public function stageAdd():void
        {
        }

        public function stageRemove():void
        {
        }

        public function draw():void
        {
        }

        override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            _listeners.push([type, listener]);
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {

            for (var i:int = 0; i < _listeners.length; i++)
            {
                if (_listeners[i][0] == type && _listeners[i][1] == listener)
                    _listeners.splice(i, 1);
            }
            super.removeEventListener(type, listener, useCapture);
        }
    }
}
