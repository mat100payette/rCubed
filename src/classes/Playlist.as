package classes
{

    public class Playlist
    {
        private var _playlistLoader:PlaylistLoader;

        private var _generatedQueues:Array;
        private var _genreList:Array;
        private var _playList:Array;
        private var _indexList:Vector.<SongInfo>;

        private var _engine:Object;

        public function Playlist()
        {
            _playlistLoader = new PlaylistLoader(null, onLoaded);
        }

        public function get generatedQueues():Array
        {
            return _generatedQueues;
        }

        public function get genreList():Array
        {
            return _genreList;
        }

        public function get songList():Array
        {
            return _playList;
        }

        public function get indexList():Vector.<SongInfo>
        {
            return _indexList;
        }

        // TODO: Type this
        public function get engineId():*
        {
            return _engine.id;
        }

        public function getSongInfoByLevelId(level:*):SongInfo
        {
            return _playList[level];
        }

        public function getSongInfoBySongId(songId:int):SongInfo
        {
            return _playList[songId];
        }

        public function isLoaded():Boolean
        {
            return _playlistLoader.isLoaded();
        }

        public function isError():Boolean
        {
            return _playlistLoader.isError();
        }

        public function load():void
        {
            _playlistLoader.load();
        }

        private function onLoaded(generatedQueues:Array, genreList:Array, playList:Array, indexList:Vector.<SongInfo>):void
        {
            // TODO: Change this to possibly an event
            generatedQueues = generatedQueues;
        }

        public function getSongInfo(genre:int, index:int = -1):SongInfo
        {
            // Returns the indexed song for the All genre
            if (genre <= -1 && index >= 0 && index < _indexList.length && _indexList[index] != null)
                return _indexList[index];

            // If an index is set, use the genre list to get the correct song.
            else if (index >= 0 && _genreList[genre] != null && _genreList[genre][index] != null)
                return _genreList[genre][index];

            // Return the song from the playlist, using the levelid as the default.
            else if (_playList[genre] != null)
                return _playList[genre];

            return null;
        }

        public function get totalSongs():int
        {
            return _indexList.length;
        }
    }
}
