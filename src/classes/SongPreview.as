package classes
{
    import classes.replay.Replay;
    import state.AppState;

    public class SongPreview extends Replay
    {
        public function SongPreview(songId:int)
        {
            super(songId);
            level = songId;
        }

        public function setupSongPreview(songData:Object = null):void
        {
            var _gvars:GlobalVariables = GlobalVariables.instance;

            if (!songData)
                songData = AppState.instance.content.canonPlaylist.getSongInfoByLevelId(level);

            if (!songData)
                return;

            level = songData.level;

            user = new User(false);
            user.siteId = 1743546;
            user.name = "Song Preview";
            user.skillLevel = _gvars.MAX_DIFFICULTY;
            user.loadAvatar();

            timestamp = Math.floor((new Date()).getTime() / 1000);
            user.settings.update(_gvars.playerUser.settings);

            isPreview = true;
            isLoaded = true;
        }
    }

}
