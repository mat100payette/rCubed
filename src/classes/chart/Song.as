package classes.chart
{
    import arc.NoteMod;
    import by.blooddy.crypto.MD5;
    import classes.SongInfo;
    import classes.chart.parse.ChartFFRLegacy;
    import com.flashfla.media.MP3Extraction;
    import com.flashfla.media.SwfSilencer;
    import com.flashfla.net.ForcibleLoader;
    import com.flashfla.utils.Crypt;
    import com.flashfla.utils.TimeUtil;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SampleDataEvent;
    import flash.events.SecurityErrorEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import classes.UserSettings;
    import com.flashfla.utils.ArrayUtil;

    public class Song extends EventDispatcher
    {
        private static const LOAD_MUSIC:String = "music";
        private static const LOAD_CHART:String = "chart";

        private var _gvars:GlobalVariables = GlobalVariables.instance;

        public var musicLoader:*;
        private var _chartLoader:URLLoader;

        public var songInfo:SongInfo;
        public var type:String;
        public var chartType:String;
        private var _isPreview:Boolean;
        public var sound:Sound;
        public var music:MovieClip;
        public var chart:NoteChart;
        private var _noteMod:NoteMod;
        private var _soundChannel:SoundChannel;
        private var _musicPausePosition:int;
        public var musicIsPlaying:Boolean = false;
        public var mp3Frame:int = 0;
        private var _mp3Rate:Number = 1;

        public var isLoaded:Boolean = false;
        public var isChartLoaded:Boolean = false;
        public var isMusicLoaded:Boolean = false;
        public var isMusic2Loaded:Boolean = true;
        public var loadFail:Boolean = false;

        private var _isMusicLoaderLoading:Boolean = false;
        private var _isChartLoaderLoading:Boolean = false;

        public var bytesSWF:ByteArray = null;
        public var bytesLoaded:uint = 0;
        public var bytesTotal:uint = 0;

        private var musicForcibleLoader:ForcibleLoader;
        public var musicDelay:int = 0;

        private var _localFileData:ByteArray = null;
        private var _localFileHash:String = "";

        private var _frameRate:int;
        private var _isReverse:Boolean;
        private var _isIsolation:Boolean;
        private var _isolationOffset:int;

        private var _rate:Number = 1;
        private var _rateSound:Sound;
        private var _rateSample:int = 0;
        private var _rateSampleCount:int = 0;
        private var _rateSamples:ByteArray = new ByteArray();

        public function Song(songInfo:SongInfo, isPreview:Boolean, settings:UserSettings):void
        {
            this.songInfo = songInfo;
            _isPreview = isPreview;

            _rate = settings.songRate;
            _isReverse = ArrayUtil.containsAny(settings.activeMods, ["reverse"]);
            _frameRate = settings.frameRate;
            _isIsolation = settings.isolationOffset > 0 || settings.isolationLength > 0;
            _isolationOffset = settings.isolationOffset;

            type = songInfo.chart_type || NoteChart.FFR;
            chartType = songInfo.chart_type || NoteChart.FFR_LEGACY;
            _noteMod = new NoteMod(this, settings);

            if (type == "EDITOR")
            {
                var editorSongInfo:SongInfo = new SongInfo();
                editorSongInfo.chart_type = NoteChart.FFR_BEATBOX;
                editorSongInfo.level = songInfo.level;

                chart = NoteChart.parseChart(NoteChart.FFR_BEATBOX, editorSongInfo, "_root.beatBox = [];");
            }
            else if (_rate != 1 || settings.frameRate > 30 || _isReverse || settings.forceNewJudge)
                type = NoteChart.FFR_MP3;

            load();
        }

        public function get rate():Number
        {
            return _rate;
        }

        public function unload():void
        {
            removeLoaderListeners();
            isLoaded = isChartLoaded = isMusicLoaded = false;
            isMusic2Loaded = true;
            loadFail = true;
            if (musicLoader && _isMusicLoaderLoading)
            {
                musicLoader.close();
                _isMusicLoaderLoading = false;
            }
            if (_chartLoader && _isChartLoaderLoading)
            {
                _chartLoader.close();
                _isChartLoaderLoading = false;
            }
            music = null;
            chart = null;
        }

        private function load():void
        {
            if (type == NoteChart.FFR_MP3)
                musicLoader = new URLLoader();
            else
                musicLoader = new Loader();
            _chartLoader = new URLLoader();

            addLoaderListeners();

            // Load Stored SWF
            var url_file_hash:String = "";
            if ((_gvars.air_useLocalFileCache) && AirContext.doesFileExist(AirContext.getSongCachePath(this) + "data.bin"))
            {
                _localFileData = AirContext.readFile(AirContext.getAppFile(AirContext.getSongCachePath(this) + "data.bin"), (songInfo.engine ? 0 : songInfo.level));
                _localFileHash = MD5.hashBytes(_localFileData);
                url_file_hash = "hash=" + _localFileHash + "&";

                if (songInfo.engine && _localFileData && type == NoteChart.FFR_MP3)
                {
                    removeLoaderListeners();
                    musicLoader = new Loader();
                    addLoaderListeners(true);
                    musicLoader.loadBytes(_localFileData, AirContext.getLoaderContext());
                    return;
                }
            }

            switch (type)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_RAW:
                case NoteChart.FFR_LEGACY:
                    musicForcibleLoader = new ForcibleLoader(musicLoader);
                    musicForcibleLoader.load(new URLRequest(urlGen(LOAD_MUSIC)));
                    break;
                case NoteChart.FFR_MP3:
                    musicLoader.dataFormat = URLLoaderDataFormat.BINARY;
                    musicLoader.load(new URLRequest(urlGen(LOAD_MUSIC, url_file_hash)));
                    _isMusicLoaderLoading = true;
                    break;
                default:
                    break;
            }

            switch (chartType)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_BEATBOX:
                case NoteChart.FFR_RAW:
                    _chartLoader.load(new URLRequest(urlGen(LOAD_CHART)));
                    _isChartLoaderLoading = true;
                    break;
                default:
                    break;
            }
        }

        public function get progress():int
        {
            if (musicLoader != null)
            {
                return Math.floor(((bytesLoaded / bytesTotal) * 99) + (isChartLoaded ? 1 : 0));
            }

            return 0;
        }

        public function getMusicContentLoader(isLoader:Boolean = false):Object
        {
            if (isLoader)
                return musicLoader.contentLoaderInfo;
            return type == NoteChart.FFR_MP3 ? musicLoader : musicLoader.contentLoaderInfo;
        }

        private function urlGen(fileType:String, fileHash:String = ""):String
        {
            switch (songInfo.chart_type || type)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_RAW:
                case NoteChart.FFR_MP3:
                    return Constant.SONG_DATA_URL + "?" + fileHash + "id=" + (_isPreview ? songInfo.preview_hash : songInfo.play_hash) + (_isPreview ? "&mode=2" : "") + (_gvars.userSession != "0" ? "&session=" + _gvars.userSession : "") + "&type=" + NoteChart.FFR + "_" + fileType;

                case NoteChart.FFR_LEGACY:
                    return ChartFFRLegacy.songUrl(songInfo);

                default:
                    return Constant.SONG_DATA_URL;
            }
        }

        private function addLoaderListeners(isLoader:Boolean = false):void
        {
            var music:Object = getMusicContentLoader(isLoader);
            if (music)
            {
                music.addEventListener(Event.COMPLETE, musicCompleteHandler);
                music.addEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
                music.addEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
            }
            if (_chartLoader)
            {
                _chartLoader.addEventListener(Event.COMPLETE, chartLoadComplete);
                _chartLoader.addEventListener(IOErrorEvent.IO_ERROR, chartLoadError);
                _chartLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, chartLoadError);
            }
            if (musicLoader)
                musicLoader.addEventListener(ProgressEvent.PROGRESS, musicProgressHandler);
        }

        private function removeLoaderListeners():void
        {
            var music:Object = getMusicContentLoader();
            if (music)
            {
                music.removeEventListener(Event.COMPLETE, musicCompleteHandler);
                music.removeEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
                music.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
            }
            if (_chartLoader)
            {
                _chartLoader.removeEventListener(Event.COMPLETE, chartLoadComplete);
                _chartLoader.removeEventListener(IOErrorEvent.IO_ERROR, chartLoadError);
                _chartLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, chartLoadError);
            }
            if (musicLoader)
                musicLoader.removeEventListener(ProgressEvent.PROGRESS, musicProgressHandler);
        }

        public function loadComplete():void
        {
            if (isChartLoaded && isMusicLoaded && isMusic2Loaded)
            {
                removeLoaderListeners();
                isLoaded = true;
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private function musicProgressHandler(e:ProgressEvent):void
        {
            bytesLoaded = e.bytesLoaded;
            bytesTotal = e.bytesTotal;
        }

        private function musicCompleteHandler(e:Event):void
        {
            Logger.info(this, "Music Load Success");
            var chartData:ByteArray;
            if (type == NoteChart.FFR_MP3)
            {
                if (e.target is URLLoader)
                    chartData = e.target.data;
                else if (e.target is LoaderInfo)
                    chartData = e.target.bytes;

                bytesLoaded = bytesTotal = chartData.length; // Update Progress Bar in case.
                isMusic2Loaded = false;

                // Check 404 Response
                if (chartData.length == 3 && chartData.readUTFBytes(3) == "404")
                {
                    loadFail = true;
                    return;
                }

                // Check for server response for matching hash. Encode Compressed SWF Data
                var storeChartData:ByteArray;
                if (_gvars.air_useLocalFileCache)
                {
                    // Alt Engine has Data
                    if (songInfo.engine && _localFileData)
                    {

                    }
                    else if (chartData.length == 3)
                    {
                        chartData.position = 0;
                        var code:String = chartData.readUTFBytes(3);
                        if (code == "404")
                        {
                            loadFail = true;
                            return;
                        }
                        if (code == "403")
                        {
                            chartData = _localFileData;
                            bytesLoaded = bytesTotal = _localFileData.length;
                        }
                    }
                    else
                    {
                        storeChartData = AirContext.encodeData(chartData, (songInfo.engine ? 0 : songInfo.level));
                    }
                }

                // Generate SWF Containing a MP3 as class "SoundClass".
                var metadata:Object = {};
                var bytes:ByteArray = MP3Extraction.extractSound(chartData, metadata);
                bytes.position = 0;
                mp3Frame = metadata.frame - 2;
                _mp3Rate = MP3Extraction.formatRate(metadata.format) / 44100;
                sound = new Sound();
                sound.loadCompressedDataFromByteArray(bytes, bytes.length);
                if (_rate != 1 || _isReverse)
                {
                    _rateSound = sound;
                    sound = new Sound();
                    if (_isReverse)
                        sound.addEventListener("sampleData", onReverseSound);
                    else
                        sound.addEventListener("sampleData", onRateSound);
                }

                isMusic2Loaded = true;

                // Generate a SWF containing no audio, used as a background.
                var mloader:Loader = new Loader();
                var mbytes:ByteArray = SwfSilencer.stripSound(chartData);
                mloader.contentLoaderInfo.addEventListener(Event.COMPLETE, mp3MusicCompleteHandler);
                if (!mbytes)
                {
                    loadFail = true;
                    return;
                }
                mloader.loadBytes(mbytes, AirContext.getLoaderContext());

                // Store SWF
                if (_gvars.air_useLocalFileCache && storeChartData)
                {
                    try
                    {
                        Logger.info(this, "Saving Cache File for " + songInfo.level);
                        AirContext.writeFile(AirContext.getAppFile(AirContext.getSongCachePath(this) + "data.bin"), storeChartData);
                    }
                    catch (err:Error)
                    {
                        Logger.error(this, "Cache write failed: " + Logger.exception_error(err));
                    }
                }

                loadComplete();

            }
            else
            {
                music = e.target.content as MovieClip;

                stop();

                chartData = musicForcibleLoader.inputBytes;
                musicForcibleLoader = null;

                isMusicLoaded = true;
                loadComplete();
            }

            if (chartType == NoteChart.FFR_LEGACY)
            {
                chart = NoteChart.parseChart(chartType, songInfo, chartData);
                chartLoadComplete(e);
            }

            bytesSWF = chartData;
        }

        private function mp3MusicCompleteHandler(e:Event):void
        {
            var info:LoaderInfo = e.currentTarget as LoaderInfo;
            music = info.content as MovieClip;

            isMusicLoaded = true;
            loadComplete();
        }

        public function getSoundObject():Sound
        {
            if (_rate != 1 || _isReverse)
                return _rateSound;
            return sound;
        }

        private function onRateSound(e:SampleDataEvent):void
        {
            var osamples:int = 0;
            var sample:int = 0;
            var sampleDiff:int = 0;
            while (osamples < 4096)
            {
                sample = (e.position + osamples) * _rate;
                sampleDiff = sample - _rateSample;
                while (sampleDiff < 0 || sampleDiff >= _rateSampleCount)
                {
                    _rateSample += _rateSampleCount;
                    _rateSamples.position = 0;
                    sampleDiff = sample - _rateSample;
                    var seekExtract:Boolean = (sampleDiff < 0 || sampleDiff > 8192);
                    _rateSampleCount = (_rateSound as Object).extract(_rateSamples, 4096, seekExtract ? sample * _mp3Rate : -1);

                    if (seekExtract)
                    {
                        _rateSample = sample;
                        sampleDiff = sample - _rateSample;
                    }

                    if (_rateSampleCount <= 0)
                        return;
                }
                _rateSamples.position = 8 * sampleDiff;
                e.data.writeFloat(_rateSamples.readFloat());
                e.data.writeFloat(_rateSamples.readFloat());
                osamples++;
            }
        }

        private function onReverseSound(e:SampleDataEvent):void
        {
            var osamples:int = 0;
            while (osamples < 4096)
            {
                var sample:int = (e.position + osamples) * _rate;
                sample = (chart.notes[chart.notes.length - 1].frame * 1470) - sample + (63 - mp3Frame) * 1470 / _rate;
                if (sample < 0)
                    return;
                var sampleDiff:int = sample - _rateSample;
                if (sampleDiff < 0 || sampleDiff >= _rateSampleCount)
                {
                    _rateSample += _rateSampleCount;
                    _rateSamples.position = 0;
                    sampleDiff = sample - _rateSample;
                    var seekPosition:int = sample - 4095;
                    _rateSampleCount = (_rateSound as Object).extract(_rateSamples, 4096, seekPosition * _mp3Rate);
                    _rateSample = seekPosition;
                    sampleDiff = sample - _rateSample;

                    if (_rateSampleCount < 4096)
                    {
                        _rateSamples.position = _rateSampleCount * 8;
                        for (var i:int = _rateSampleCount; i < 4096; i++)
                        {
                            _rateSamples.writeFloat(0);
                            _rateSamples.writeFloat(0);
                        }
                        _rateSampleCount = 4096;
                    }
                }
                _rateSamples.position = 8 * sampleDiff;
                e.data.writeFloat(_rateSamples.readFloat());
                e.data.writeFloat(_rateSamples.readFloat());
                osamples++;
            }
        }

        private function stopSound(e:*):void
        {
            musicIsPlaying = false;
        }

        private function chartLoadComplete(e:Event):void
        {
            Logger.info(this, "Chart Load Success");
            _isChartLoaderLoading = false;
            switch (chartType)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_MP3:
                    chart = NoteChart.parseChart(NoteChart.FFR, songInfo, Crypt.ROT255(Crypt.B64Decode(e.target.data)));
                    break;

                case NoteChart.FFR_BEATBOX:
                case NoteChart.FFR_RAW:
                    chart = NoteChart.parseChart(chartType, songInfo, e.target.data);
                    break;

                case NoteChart.FFR_LEGACY:
                    if (songInfo.note_count == 0)
                        songInfo.note_count = chart.notes.length;
                    break;

                case NoteChart.THIRDSTYLE:
                    chart = NoteChart.parseChart(chartType, songInfo, e.target.data);
                    break;

                default:
                    throw Error("Unsupported NoteChart type!");
            }
            isChartLoaded = true;

            if (_noteMod.required() && chartType != NoteChart.FFR_LEGACY)
            {
                generateModNotes();
            }

            Logger.info(this, "Chart parsed with " + chart.notes.length + " notes, " + (chart.notes.length > 0 ? TimeUtil.convertToHHMMSS(chart.notes[chart.notes.length - 1].time) : "0:00") + " length.");

            loadComplete();
        }

        private function musicLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Music Load Error: " + Logger.event_error(err));
            _isMusicLoaderLoading = false;
            //_gvars.gameMain.addPopup(new PopupMessage(_gvars.gameMain, "An error occured while loading the music.", "ERROR"));
            removeLoaderListeners();
            loadFail = true;
        }

        private function chartLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Chart Load Error: " + Logger.event_error(err));
            //_gvars.gameMain.addPopup(new PopupMessage(_gvars.gameMain, "An error occured while loading the chart file.", "ERROR"));
            _isChartLoaderLoading = false;
            removeLoaderListeners();
            loadFail = true;
        }

        ///- Song Function
        public function start(seek:int = 0):void
        {
            updateMusicDelay();
            if (_soundChannel)
            {
                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
                _soundChannel.stop();
            }
            if (sound)
            {
                _soundChannel = sound.play(musicDelay * 1000 / _rate / 30 + seek);
                _soundChannel.soundTransform = SoundMixer.soundTransform;
                _soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
            }
            if (music)
                music.gotoAndPlay(2 + musicDelay + int(seek * 30 / 1000));
            musicIsPlaying = true;
        }

        public function stop():void
        {
            if (music)
                music.stop();
            if (_soundChannel)
            {
                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
                _soundChannel.stop();
                _musicPausePosition = 0;
                _soundChannel = null;
            }
            musicIsPlaying = false;
        }

        public function pause():void
        {
            var pausePosition:int = 0;
            if (_soundChannel)
                pausePosition = _soundChannel.position;
            stop();
            _musicPausePosition = pausePosition;
        }

        public function resume():void
        {
            if (music)
                music.play();
            if (sound)
            {
                _soundChannel = sound.play(_musicPausePosition);
                _soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
            }
            musicIsPlaying = true;
        }

        private function playClips(clip:MovieClip):void
        {
            clip.gotoAndPlay(2 + musicDelay);
            for (var i:int = 0; i < clip.numChildren; i++)
            {
                var subclip:MovieClip = clip.getChildAt(i) as MovieClip;
                if (subclip)
                    playClips(subclip);
            }
        }

        public function reset():void
        {
            stop();
            start();
            if (music)
                playClips(music);
        }

        ///- Note Functions
        private var _modNotes:Array = [];

        public function generateModNotes():void
        {
            for (var i:int = chart.notes.length - 1; i >= 0; i--)
                _modNotes[i] = _noteMod.transformNote(chart.notes[i]);
        }

        public function getNote(index:int):Note
        {
            if (_noteMod.required())
            {
                if (NoteChart.FFR_LEGACY)
                    return _noteMod.transformNote(index);

                return _modNotes[index];
            }
            else
                return chart.notes[index];
        }

        public function get totalNotes():int
        {
            if (_noteMod.required())
                return _noteMod.transformTotalNotes();

            if (!chart.notes)
                return 0;

            return chart.notes.length;
        }

        public function get chartTime():Number
        {
            if (_noteMod.required())
                return _noteMod.transformSongLength();

            if (!chart.notes || chart.notes.length <= 0)
                return 0;

            return getNote(totalNotes - 1).time + 1; // 1 second for fadeout.
        }

        public function get chartTimeFormatted():String
        {
            var totalSecs:int = chartTime;
            var minutes:String = Math.floor(totalSecs / 60).toString();
            var seconds:String = (totalSecs % 60).toString();

            if (seconds.length == 1)
                seconds = "0" + seconds;

            return minutes + ":" + seconds;
        }

        public function get noteSteps():int
        {
            if (!chart)
                return NaN;

            return chart.framerate + 1;
        }

        public function get frameRate():int
        {
            return type == NoteChart.FFR_MP3 ? _frameRate : chart.framerate;
        }

        public function updateMusicDelay():void
        {
            _noteMod.start();
            if (_isIsolation && totalNotes > 0)
            {
                if (_isReverse)
                    musicDelay = Math.max(0, chart.notes[chart.notes.length - 1].frame - chart.notes[Math.max(0, chart.notes.length - 1 - _isolationOffset)].frame - 60);
                else
                    musicDelay = Math.max(0, chart.notes[_isolationOffset].frame - 60);
            }
            else
                musicDelay = 0;
        }

        public function getPosition():int
        {
            switch (type)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_RAW:
                case NoteChart.FFR_LEGACY:
                    return (music.currentFrame - 2 - musicDelay) * 1000 / 30;

                case NoteChart.FFR_MP3:
                case NoteChart.THIRDSTYLE:
                    return _soundChannel ? _soundChannel.position - musicDelay / _rate * 1000 / 30 : 0;

                default:
                    return 0;
            }
        }
    }
}
