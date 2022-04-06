package classes
{

    import state.AppState;

    public class SongInfo
    {
        private static const SONG_ICON_NO_SCORE:int = 0;
        private static const SONG_ICON_PLAYED:int = 1;
        private static const SONG_ICON_FC:int = 2;
        private static const SONG_ICON_SDG:int = 3;
        private static const SONG_ICON_BLACKFLAG:int = 4;
        private static const SONG_ICON_BOOFLAG:int = 5;
        private static const SONG_ICON_AAA:int = 6;
        private static const SONG_ICON_FC_STAR:int = 7;

        public static const SONG_ICON_TEXT:Array = ["<font color=\"#9C9C9C\">UNPLAYED</font>", "", "<font color=\"#00FF00\">FC</font>",
            "<font color=\"#f2a254\">SDG</font>", "<font color=\"#2C2C2C\">BLACKFLAG</font>",
            "<font color=\"#473218\">BOOFLAG</font>", "<font color=\"#FFFF38\">AAA</font>", "<font color=\"#00FF00\">FC*</font>"];

        public static const SONG_ICON_COLOR:Array = ["#9C9C9C", "#FFFFFF", "#00FF00", "#f2a254", "#2C2C2C", "#473218", "#FFFF38", "#00FF00"];

        public static const SONG_ICON_TEXT_FLAG:Array = ["Unplayed", "Played", "Full Combo",
            "Single Digit Good", "Blackflag", "Booflag", "AAA", "Full Combo*"];

        public static const SONG_ACCESS_PLAYABLE:int = 0;
        public static const SONG_ACCESS_CREDITS:int = 1;
        public static const SONG_ACCESS_PURCHASED:int = 2;
        public static const SONG_ACCESS_TOKEN:int = 3;
        public static const SONG_ACCESS_VETERAN:int = 4;
        public static const SONG_ACCESS_BANNED:int = 5;

        public static const SONG_TYPE_PUBLIC:int = 0;
        public static const SONG_TYPE_TOKEN:int = 1;
        public static const SONG_TYPE_PURCHASED:int = 2;
        public static const SONG_TYPE_SECRET:int = 3;

        // Engine Variables
        public var access:int;
        public var chart_type:String;
        public var song_type:int;
        public var index:int;

        public var score_raw:int;
        public var score_total:int;

        // Song Variables
        public var genre:int;
        public var level:int;
        public var name:String;
        public var difficulty:int;
        public var noteCount:int;
        public var order:int;
        public var style:String;

        public var author:String;
        public var authorUrl:String;
        public var authorHtml:String;

        public var stepauthor:String;
        public var stepauthorUrl:String;
        public var stepauthorHtml:String;

        public var playHash:String;
        public var previewHash:String;

        public var prerelease:Boolean;
        public var release_Date:uint;

        public var minNps:int;
        public var maxNps:int;

        public var time:String;
        public var timeSecs:int;

        // Song - Optional
        public var price:int;
        public var credits:int;
        public var songRating:Number;

        // Alt Engines Variables
        public var engine:Object;
        public var levelId:String;
        public var sync:int;

        public function SongInfo()
        {

        }

        public function compareTo(s2:SongInfo):Boolean
        {
            return compare(this, s2);
        }

        public static function compare(s1:SongInfo, s2:SongInfo):Boolean
        {
            if (!s1 || !s2)
                return false;

            if (s1.engine && s2.engine && s1.engine.id != s2.engine.id)
                return false;

            if (s1.level > 0 && s2.level > 0 && s1.level != s2.level)
                return false;

            if (s1.levelId && s2.levelId && s1.levelId != s2.levelId)
                return false;

            return true;
        }

        public function checkSongAccess(user:User):int
        {
            // Not allowed access types
            if (isNaN(level))
                return SONG_ACCESS_BANNED;

            if (credits > 0 && user.credits < credits)
                return SONG_ACCESS_CREDITS;

            if (price > 0 && (index >= user.purchased.length || !user.purchased[index]))
                return SONG_ACCESS_PURCHASED;

            var tokens:Object = AppState.instance.content.tokens;
            if (engine == null && tokens[level] != null && tokens[level].unlock == 0)
                return SONG_ACCESS_TOKEN;

            if (prerelease && !user.isVeteran)
                return SONG_ACCESS_VETERAN;

            // Allowed access type
            return SONG_ACCESS_PLAYABLE;
        }

        public static function getSongIconIndex(songInfo:SongInfo, rank:Object):int
        {
            var songIcon:int = SONG_ICON_NO_SCORE;

            if (rank == null)
                return songIcon;

            var arrows:int = songInfo.noteCount;
            var scoreRaw:int = songInfo.score_raw;

            // TODO: Invert this if chain into early returns

            if (rank.arrows > 0)
            {
                arrows = rank.arrows;
                scoreRaw = arrows * 50;
            }

            // No Score
            if (rank.score == 0)
                return SONG_ICON_NO_SCORE;

            // Played
            else if (rank.score > 0)
                songIcon = SONG_ICON_PLAYED;

            // FC* - When current score isn't FC but a FC has been achieved before.
            if (rank.fcs > 0)
                songIcon = SONG_ICON_FC_STAR;

            // FC
            if (rank.perfect + rank.good + rank.average == arrows && rank.miss == 0 && rank.maxcombo == arrows)
                songIcon = SONG_ICON_FC;

            // SDG
            if (scoreRaw - rank.rawscore < 250)
                songIcon = SONG_ICON_SDG;

            // BlackFlag
            if (rank.perfect == arrows - 1 && rank.good == 1 && rank.average == 0 && rank.miss == 0 && rank.boo == 0 && rank.maxcombo == arrows)
                songIcon = SONG_ICON_BLACKFLAG;

            // BooFlag
            if (rank.perfect == arrows && rank.good == 0 && rank.average == 0 && rank.miss == 0 && rank.boo == 1 && rank.maxcombo == arrows)
                songIcon = SONG_ICON_BOOFLAG;

            // AAA
            if (rank.rawscore == scoreRaw)
                songIcon = SONG_ICON_AAA;

            return songIcon;
        }

        public static function getSongIconIndexBitmask(songInfo:SongInfo, rank:Object):int
        {
            var songIcon:int = SONG_ICON_NO_SCORE;

            if (rank == null)
                return songIcon;

            var arrows:int = songInfo.noteCount;
            var scoreRaw:int = songInfo.score_raw;

            if (rank.arrows > 0)
            {
                arrows = rank.arrows;
                scoreRaw = arrows * 50;
            }

            // Played
            if (rank.score > 0)
                songIcon |= (1 << SONG_ICON_PLAYED);

            // FC* - When current score isn't FC but a FC has been achieved before.
            if (rank.fcs > 0)
                songIcon |= (1 << SONG_ICON_FC_STAR);

            // FC
            if (rank.perfect + rank.good + rank.average == arrows && rank.miss == 0 && rank.maxcombo == arrows)
                songIcon |= (1 << SONG_ICON_FC);

            // SDG
            if (scoreRaw - rank.rawscore < 250)
                songIcon |= (1 << SONG_ICON_SDG);

            // BlackFlag
            if (rank.perfect == arrows - 1 && rank.good == 1 && rank.average == 0 && rank.miss == 0 && rank.boo == 0 && rank.maxcombo == arrows)
                songIcon |= (1 << SONG_ICON_BLACKFLAG);

            // BooFlag
            if (rank.perfect == arrows && rank.good == 0 && rank.average == 0 && rank.miss == 0 && rank.boo == 1 && rank.maxcombo == arrows)
                songIcon |= (1 << SONG_ICON_BOOFLAG);

            // AAA
            if (rank.rawscore == scoreRaw)
                songIcon |= (1 << SONG_ICON_AAA);

            return songIcon;
        }

        public static function getSongIcon(songInfo:SongInfo, rank:Object):String
        {
            return SONG_ICON_TEXT[getSongIconIndex(songInfo, rank)];
        }
    }
}
