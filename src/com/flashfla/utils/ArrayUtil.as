package com.flashfla.utils
{

    public class ArrayUtil
    {

        public static function containsAny(array:Array, items:Array):Boolean
        {
            for (var y:int = 0; y < items.length; y++)
            {
                for (var x:int = 0; x < array.length; x++)
                {
                    if (array[x] == items[y])
                        return true;
                }
            }
            return false;
        }

        /**
         *	Remove first of the specified value from the array,
         *
         * 	@param arr The array from which the value will be removed
         *
         *	@param value The object that will be removed from the array.
         *
         * 	@langversion ActionScript 3.0
         *	@playerversion Flash 9.0
         *	@tiptext
         */
        public static function remove(value:Object, array:Array):Boolean
        {
            if (!array || array.length == 0)
                return false;

            var ind:int;
            if ((ind = array.indexOf(value)) != -1)
            {
                array.splice(ind, 1);
                return true;
            }
            return false;
        }

        /**
         *	Remove all instances of the specified value from the array,
         *
         * 	@param arr The array from which the value will be removed
         *
         *	@param value The object that will be removed from the array.
         *
         * 	@langversion ActionScript 3.0
         *	@playerversion Flash 9.0
         *	@tiptext
         */
        public static function removeValue(value:Object, array:Array):void
        {
            var len:uint = array.length;

            for (var i:Number = len; i > -1; i--)
            {
                if (array[i] === value)
                    array.splice(i, 1);
            }
        }

        public static function randomize(array:Array):Array
        {
            var newarr:Array = new Array(array.length);

            var randomPos:Number = 0;
            for (var i:int = 0; i < newarr.length; i++)
            {
                randomPos = int(Math.random() * array.length);
                newarr[i] = array.splice(randomPos, 1)[0];
            }

            return newarr;
        }

        public static function merge(array1:Array, array2:Array):void
        {
            var minArrLen:int = Math.min(array1.length, array2.length);
            for (var i:int = 0; i < minArrLen; i++)
                array1[i] = array2[i];
        }
    }
}
