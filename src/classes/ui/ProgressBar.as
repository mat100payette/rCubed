/**
 * @author Jonathan (Velocity)
 */

package classes.ui
{
    import com.greensock.TweenLite;
    import flash.display.Sprite;
    import flash.events.Event;

    public class ProgressBar extends Sprite
    {
        public static const LOADER_COMPLETE:String = "LoaderComplete";

        private var topMC:Sprite = new Sprite();
        private var progressMC:Sprite = new Sprite();

        private var _curPercent:Number = 0;
        private var _onComplete:Function;

        public var isComplete:Boolean = false;
        public var barWidth:int;
        public var barHeight:int;

        public function ProgressBar(xpos:Number = 0, ypos:Number = 0, bWidth:uint = 450, bHeight:uint = 20, bSplits:uint = 0, borColor:uint = 0x000000, borSize:Number = 2, bColor:uint = 0x00BFFF)
        {
            x = xpos;
            y = ypos;

            // Draw Background
            topMC.graphics.beginFill(0xFFFFFF, 0.0);
            topMC.graphics.lineStyle(0);
            topMC.graphics.drawRect(0, 0, bWidth, bHeight);
            topMC.graphics.endFill();

            // Draw Gloss
            topMC.graphics.beginFill(0xFFFFFF, 0.5);
            topMC.graphics.lineStyle(1, 0x000000, 0);
            topMC.graphics.drawRect(1, 1, bWidth - 2, (bHeight - 2) / 2);
            topMC.graphics.endFill();

            // Draw Border
            topMC.graphics.lineStyle(borSize, borColor, 1);
            topMC.graphics.drawRect(0, 0, bWidth, bHeight);
            if (bSplits > 0)
            {
                topMC.graphics.lineStyle(borSize, borColor, 0.75);
                var spacing:Number = bWidth / bSplits;
                for (var sX:int = 0; sX < bSplits; sX++)
                {
                    topMC.graphics.moveTo(spacing * sX, 0);
                    topMC.graphics.lineTo(spacing * sX, bHeight);
                }
            }

            // Draw Progress Bar
            progressMC.graphics.beginFill(bColor);
            progressMC.graphics.lineStyle(1, 0x000000, 0);
            progressMC.graphics.drawRect(0, 0, bWidth, bHeight);
            progressMC.graphics.endFill();
            progressMC.width = 0;

            // Add the clips to the stage
            addChild(progressMC);
            addChild(topMC);

            mouseChildren = false;
            barWidth = bWidth;
            barHeight = height;
        }

        public function setOnComplete(callback:Function):void
        {
            _onComplete = callback;
        }

        public function update(percent:Number = 0, useTween:Boolean = true):void
        {
            if (percent < 0)
                percent = 0;
            if (percent > 1)
                percent = 1;

            if (_curPercent != percent)
            {
                if (useTween)
                    TweenLite.to(progressMC, 0.25, {width: percent * barWidth});
                else
                    progressMC.width = percent * barWidth;

                if (percent >= 1)
                {
                    dispatchEvent(new Event(LOADER_COMPLETE));
                    this.isComplete = true;
                }
            }
        }

        public function remove(time:Number = 0.5):void
        {
            TweenLite.to(this, time, {alpha: 0, onComplete: _onComplete});
        }
    }
}
