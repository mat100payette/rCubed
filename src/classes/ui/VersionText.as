package classes.ui
{
    import flash.system.Capabilities;
    import flash.text.TextFormatAlign;

    public class VersionText extends Text
    {
        private const TEXT:String = Capabilities.version.replace(/,/g, ".") + " - Build " + CONFIG::timeStamp + " - " + Constant.AIR_VERSION;

        public function VersionText(x:int, y:int)
        {
            //- Epilepsy Warning
            super(null, x, y, TEXT);

            alpha = 0.15;
            align = TextFormatAlign.RIGHT;
            mouseEnabled = false;
            cacheAsBitmap = true;

            // Holidays!
            var d:Date = new Date();
            if (d.getMonth() == 0 && d.getDate() == 1)
                text = "Happy New Year! - " + text;
            if (d.getMonth() == 9 && d.getDate() == 31)
                text = "Happy Halloween! - " + text;
            if (d.getMonth() == 11 && d.getDate() == 25)
                text = "Merry Christmas! - " + text;
            if (d.getMonth() == 10 && d.getDate() == 6)
                text = "Happy Birthday Velocity! - " + text;
        }
    }
}
