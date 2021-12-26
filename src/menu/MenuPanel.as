package menu
{
    import flash.display.Sprite;

    public class MenuPanel extends Sprite
    {
        private var _listeners:Array = [];
        public var parentPanel:MenuPanel;
        public var current_popup:MenuPanel;
        public var hasInit:Boolean = false;

        public function MenuPanel(parent:MenuPanel)
        {
            this.parentPanel = parent;
            super();
        }

        public function switchTo(panel:String, useNew:Boolean = false):Boolean
        {
            if (stage != null && this.stage != null)
            {
                stage.focus = this.stage;
            }
            return parentPanel.switchTo(panel, useNew);
        }

        public function addPopup(panel:*, newLayer:Boolean = false):void
        {
            return parentPanel.addPopup(panel, newLayer);
        }

        public function removePopup():void
        {
            return parentPanel.removePopup();
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
            // trace("Added Listener:", this, _listeners.length - 1, type);
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {

            for (var i:int = 0; i < _listeners.length; i++)
            {
                if (_listeners[i][0] == type && _listeners[i][1] == listener)
                {
                    _listeners.splice(i, 1);
                        // trace("Removed Listener:", this, i, type);
                }
            }
            super.removeEventListener(type, listener, useCapture);
        }
    }
}
