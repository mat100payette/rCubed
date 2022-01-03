package com.flashfla.utils
{

    public class VectorUtil
    {

        public static function fromArray(arr:Array):Vector.<*>
        {
            const vec:Vector.<*> = new <*>[];
            for each (var value:* in arr)
                vec.push(value);
            return vec;
        }

        public static function toArray(vec:*):Array
        {
            if (!(vec is Vector.<*>))
                throw new Error("Expected a Vector.");

            const array:Array = [];
            for each (var value:* in vec)
                array.push(value);

            return array;
        }

        public static function inVector(vec:*, items:*):Boolean
        {
            const _vec:Vector.<*> = Vector.<*>(vec);
            const _items:Vector.<*> = Vector.<*>(items);

            if (!(vec.length) || !(items.length) || vec.length < items.length)
                return false;

            for (var y:int = 0; y < _items.length; y++)
            {
                for (var x:int = 0; x < _vec.length; x++)
                {
                    if (_vec[x] == _items[y])
                        return true;
                }
            }
            return false;
        }


        public static function removeFirst(value:Object, vec:*):Boolean
        {
            if (!(vec is Vector.<*>))
                throw new Error("Expected a Vector.");

            const _vec:Vector.<*> = vec as Vector.<*>;

            if (_vec.length == 0)
                return false;

            var ind:int;
            if ((ind = _vec.indexOf(value)) != -1)
            {
                _vec.removeAt(ind);
                return true;
            }
            return false;
        }

        public static function mergeArray(vec:*, arr:Array):void
        {
            if (!(vec is Vector.<*>))
                throw new Error("Expected a Vector.");

            const minArrLen:int = Math.min(vec.length, arr.length);
            for (var i:int = 0; i < minArrLen; i++)
                vec[i] = arr[i];
        }
    }
}
