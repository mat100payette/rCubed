package classes.ui
{
    import flash.text.TextField;
    import flash.text.AntiAliasType;

    public class EpilepsyWarning extends TextField
    {
        public function EpilepsyWarning(x:int, y:int, width:int)
        {
            //- Epilepsy Warning
            super();

            this.x = x;
            this.y = y;
            this.width = width;
            selectable = false;
            embedFonts = true;
            antiAliasType = AntiAliasType.ADVANCED;
            defaultTextFormat = Constant.TEXT_FORMAT_CENTER;
            textColor = 0xFFFFFF;
            alpha = 0.2;
            text = "WARNING: This game may potentially trigger seizures for people with photosensitive epilepsy.\nGamer discretion is advised.";
        }
    }
}
