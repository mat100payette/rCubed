package game.controls
{
    import assets.GameBackgroundColor;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    public class ScreenCut extends Sprite
    {
        private var self:ScreenCut;

        public function ScreenCut(isEditor:Boolean, scrollDirection:String, position:Number):void
        {
            self = this;
            graphics.lineStyle(3, GameBackgroundColor.BG_STATIC, 1);
            graphics.beginFill(0x000000);

            switch (scrollDirection)
            {
                case "down":
                    x = 0;
                    y = position * Main.GAME_HEIGHT;
                    graphics.drawRect(-Main.GAME_WIDTH, -(Main.GAME_HEIGHT * 3), Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);

                    if (isEditor)
                    {
                        addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
                        {
                            self.startDrag(false, new Rectangle(0, 5, 0, Main.GAME_HEIGHT - 7));
                        });
                        addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
                        {
                            self.stopDrag();
                            position = (self.y / Main.GAME_HEIGHT);
                        });
                    }
                    break;

                case "right":
                    x = position * Main.GAME_WIDTH;
                    y = 0;
                    graphics.drawRect(-Main.GAME_WIDTH * 3, -Main.GAME_HEIGHT, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);

                    if (isEditor)
                    {
                        addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
                        {
                            self.startDrag(false, new Rectangle(0, 0, Main.GAME_WIDTH - 7, 0));
                        });
                        addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
                        {
                            self.stopDrag();
                            position = (self.x / Main.GAME_WIDTH);
                        });
                    }
                    break;

                case "left":
                    x = Main.GAME_WIDTH - (position * Main.GAME_WIDTH);
                    y = 0;
                    graphics.drawRect(0, -Main.GAME_HEIGHT, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);

                    if (isEditor)
                    {
                        addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
                        {
                            self.startDrag(false, new Rectangle(0, 0, Main.GAME_WIDTH - 7, 0));
                        });
                        addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
                        {
                            self.stopDrag();
                            position = 1 - (self.x / Main.GAME_WIDTH);
                        });
                    }
                    break;

                default:
                    x = 0;
                    y = Main.GAME_HEIGHT - (position * Main.GAME_HEIGHT);
                    graphics.drawRect(-Main.GAME_WIDTH, 0, Main.GAME_WIDTH * 3, Main.GAME_HEIGHT * 3);

                    if (isEditor)
                    {
                        addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
                        {
                            self.startDrag(false, new Rectangle(0, 5, 0, Main.GAME_HEIGHT - 7));
                        });
                        addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
                        {
                            self.stopDrag();
                            position = 1 - (self.y / Main.GAME_HEIGHT);
                        });
                    }
                    break;
            }

            graphics.endFill();

            if (isEditor)
            {
                buttonMode = true;
                useHandCursor = true;
            }
        }
    }
}
