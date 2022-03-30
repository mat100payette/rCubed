package classes
{

    import state.AppState;

    public class SongInfo
    {
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
    }
}
