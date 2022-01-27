package menu
{
    import flash.display.Sprite;
    import flash.display.DisplayObject;

    public class DisplayLayer extends Sprite implements IDisposable
    {
        private var _layerIndex:int;

        public var focus:Boolean = true;

        public function DisplayLayer()
        {
            super();
        }

        public function dispose():void
        {
            for (var i:int = numChildren - 1; i >= 0; i--)
            {
                var child:DisplayObject = getChildAt(i);
                if (child is IDisposable)
                    (child as IDisposable).dispose();

                removeChildAt(i);
            }
        }

        public function stageAdd():void
        {
        }
    }
}
