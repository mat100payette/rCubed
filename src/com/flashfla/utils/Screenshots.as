/**
 * @author Zageron
 */

package com.flashfla.utils
{
    import by.blooddy.crypto.image.PNGEncoder;
    import classes.Alert;
    import classes.Language;
    import flash.display.BitmapData;
    import flash.display.Stage;
    import flash.net.FileReference;

    public class Screenshots
    {
        /**
         * Takes a screenshot of the stage and saves it to disk.
         */
        public static function takeScreenshot(stage:Stage, filename:String = null):void
        {
            // Create Bitmap of Stage
            var b:BitmapData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, false, 0x000000);
            b.draw(stage);

            try
            {
                var file:FileReference = new FileReference();

                var finalFilename:String = filename != null ? filename : "R^3 - " + DateUtil.toRFC822(new Date()).replace(/:/g, ".");

                file.save(PNGEncoder.encode(b), AirContext.createFileName(finalFilename) + ".png");
            }
            catch (e:Error)
            {
                Alert.add(Language.instance.string("save_image_error"), 120);
            }
        }
    }
}
