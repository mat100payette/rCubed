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
    import state.AppState;

    public class Song extends EventDispatcher
    {
        private static const LOAD_MUSIC:String = "music";
        private static const LOAD_CHART:String = "chart";

        private var _clipLoader:*;
        private var _chartLoader:URLLoader;

        private var _modNotes:Array = [];
        private var _songInfo:SongInfo;
        private var _type:String;
        private var _chartType:String;
        private var _isPreview:Boolean;
        private var _sound:Sound;
        private var _clip:MovieClip;
        private var _chart:NoteChart;
        private var _noteMod:NoteMod;
        private var _soundChannel:SoundChannel;
        private var _musicPausePosition:int;
        private var _musicIsPlaying:Boolean = false;
        private var _mp3Frame:int = 0;
        private var _mp3Rate:Number = 1;

        private var _isLoaded:Boolean = false;
        private var _loadFailed:Boolean = false;

        private var _isChartLoaded:Boolean = false;
        private var _isClipLoaded:Boolean = false;
        private var _isSoundLoaded:Boolean = true;

        private var _isMusicLoaderLoading:Boolean = false;
        private var _isChartLoaderLoading:Boolean = false;

        public var bytesSWF:ByteArray = null;
        public var bytesLoaded:uint = 0;
        public var bytesTotal:uint = 0;

        private var _musicForcibleLoader:ForcibleLoader;
        private var _musicDelay:int = 0;

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
            _songInfo = songInfo;
            _isPreview = isPreview;

            _rate = settings.songRate;
            _isReverse = ArrayUtil.containsAny(settings.activeMods, ["reverse"]);
            _frameRate = settings.frameRate;
            _isIsolation = settings.isolationOffset > 0 || settings.isolationLength > 0;
            _isolationOffset = settings.isolationOffset;

            _type = songInfo.chart_type || NoteChart.FFR;
            _chartType = songInfo.chart_type || NoteChart.FFR_LEGACY;
            _noteMod = new NoteMod(this, settings);

            if (_type == "EDITOR")
            {
                var editorSongInfo:SongInfo = new SongInfo();
                editorSongInfo.chart_type = NoteChart.FFR_BEATBOX;
                editorSongInfo.level = songInfo.level;

                _chart = NoteChart.parseChart(NoteChart.FFR_BEATBOX, editorSongInfo, "_root.beatBox = [];");
            }
            else if (_rate != 1 || settings.frameRate > 30 || _isReverse || settings.forceNewJudge)
                _type = NoteChart.FFR_MP3;

            load();
        }

        public function get songInfo():SongInfo
        {
            return _songInfo;
        }

        public function get rate():Number
        {
            return _rate;
        }

        public function get musicDelay():int
        {
            return _musicDelay;
        }

        public function get clip():MovieClip
        {
            return _clip;
        }

        public function get type():String
        {
            return _type;
        }

        public function get chart():NoteChart
        {
            return _chart;
        }

        public function get notes():Array
        {
            return _chart.notes;
        }

        public function get musicIsPlaying():Boolean
        {
            return _musicIsPlaying;
        }

        public function get mp3Frame():int
        {
            return _mp3Frame;
        }

        public function get isLoaded():Boolean
        {
            return _isLoaded;
        }

        public function get loadFailed():Boolean
        {
            return _loadFailed;
        }

        public function unload():void
        {
            removeLoaderListeners();
            _isLoaded = _isChartLoaded = _isClipLoaded = false;
            _isSoundLoaded = true;
            _loadFailed = true;

            if (_clipLoader && _isMusicLoaderLoading)
            {
                _clipLoader.close();
                _isMusicLoaderLoading = false;
            }

            if (_chartLoader && _isChartLoaderLoading)
            {
                _chartLoader.close();
                _isChartLoaderLoading = false;
            }

            _clip = null;
            _chart = null;
        }

        private function load():void
        {
            if (_type == NoteChart.FFR_MP3)
                _clipLoader = new URLLoader();
            else
                _clipLoader = new Loader();

            _chartLoader = new URLLoader();

            addLoaderListeners();

            // Load Stored SWF
            var urlFileHash:String = "";
            var binDataPath:String = AirContext.getSongCachePath(this) + "data.bin";

            if ((AppState.instance.air.useLocalFileCache) && AirContext.doesFileExist(binDataPath))
            {
                var fileKey:int = _songInfo.engine ? 0 : _songInfo.level;

                _localFileData = AirContext.readFile(AirContext.getAppFile(binDataPath), fileKey);
                _localFileHash = MD5.hashBytes(_localFileData);
                urlFileHash = "hash=" + _localFileHash + "&";

                if (_songInfo.engine && _localFileData && _type == NoteChart.FFR_MP3)
                {
                    removeLoaderListeners();
                    _clipLoader = new Loader();
                    addLoaderListeners(true);
                    _clipLoader.loadBytes(_localFileData, AirContext.getLoaderContext());
                    return;
                }
            }

            switch (_type)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_RAW:
                case NoteChart.FFR_LEGACY:
                    _musicForcibleLoader = new ForcibleLoader(_clipLoader);
                    _musicForcibleLoader.load(new URLRequest(urlGen(LOAD_MUSIC)));
                    break;
                case NoteChart.FFR_MP3:
                    _clipLoader.dataFormat = URLLoaderDataFormat.BINARY;
                    _clipLoader.load(new URLRequest(urlGen(LOAD_MUSIC, urlFileHash)));
                    _isMusicLoaderLoading = true;
                    break;
                default:
                    break;
            }

            switch (_chartType)
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
            if (_clipLoader != null)
                return Math.floor(((bytesLoaded / bytesTotal) * 99) + (_isChartLoaded ? 1 : 0));

            return 0;
        }

        public function getMusicContentLoader(isLoader:Boolean = false):Object
        {
            if (isLoader)
                return _clipLoader.contentLoaderInfo;

            return _type == NoteChart.FFR_MP3 ? _clipLoader : _clipLoader.contentLoaderInfo;
        }

        private function urlGen(fileType:String, fileHash:String = ""):String
        {
            var userSession:String = AppState.instance.auth.userSession;

            switch (_songInfo.chart_type || _type)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_RAW:
                case NoteChart.FFR_MP3:
                    return Constant.SONG_DATA_URL + "?" + fileHash + "id=" + (_isPreview ? songInfo.previewHash : songInfo.playHash) + (_isPreview ? "&mode=2" : "") + (userSession != "0" ? "&session=" + userSession : "") + "&type=" + NoteChart.FFR + "_" + fileType;

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
                music.addEventListener(Event.COMPLETE, clipCompleteHandler);
                music.addEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
                music.addEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
            }

            if (_chartLoader)
            {
                _chartLoader.addEventListener(Event.COMPLETE, chartLoadComplete);
                _chartLoader.addEventListener(IOErrorEvent.IO_ERROR, chartLoadError);
                _chartLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, chartLoadError);
            }

            if (_clipLoader)
                _clipLoader.addEventListener(ProgressEvent.PROGRESS, clipProgressHandler);
        }

        private function removeLoaderListeners():void
        {
            var music:Object = getMusicContentLoader();

            if (music)
            {
                music.removeEventListener(Event.COMPLETE, clipCompleteHandler);
                music.removeEventListener(IOErrorEvent.IO_ERROR, musicLoadError);
                music.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, musicLoadError);
            }

            if (_chartLoader)
            {
                _chartLoader.removeEventListener(Event.COMPLETE, chartLoadComplete);
                _chartLoader.removeEventListener(IOErrorEvent.IO_ERROR, chartLoadError);
                _chartLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, chartLoadError);
            }

            if (_clipLoader)
                _clipLoader.removeEventListener(ProgressEvent.PROGRESS, clipProgressHandler);
        }

        public function loadComplete():void
        {
            if (_isChartLoaded && _isClipLoaded && _isSoundLoaded)
            {
                removeLoaderListeners();
                _isLoaded = true;
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private function clipProgressHandler(e:ProgressEvent):void
        {
            bytesLoaded = e.bytesLoaded;
            bytesTotal = e.bytesTotal;
        }

        private function clipCompleteHandler(e:Event):void
        {
            Logger.info(this, "Music Load Success");
            var chartData:ByteArray;

            if (_type == NoteChart.FFR_MP3)
            {
                if (e.target is URLLoader)
                    chartData = e.target.data;
                else if (e.target is LoaderInfo)
                    chartData = e.target.bytes;

                bytesLoaded = bytesTotal = chartData.length; // Update Progress Bar in case.
                _isSoundLoaded = false;

                // Check 404 Response
                if (chartData.length == 3 && chartData.readUTFBytes(3) == "404")
                {
                    _loadFailed = true;
                    return;
                }

                // Check for server response for matching hash. Encode Compressed SWF Data
                var storeChartData:ByteArray;
                if (AppState.instance.air.useLocalFileCache)
                {
                    // Alt Engine has Data
                    if (_songInfo.engine && _localFileData)
                    {

                    }
                    else if (chartData.length == 3)
                    {
                        chartData.position = 0;
                        var code:String = chartData.readUTFBytes(3);

                        if (code == "404")
                        {
                            _loadFailed = true;
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
                        storeChartData = AirContext.encodeData(chartData, (_songInfo.engine ? 0 : _songInfo.level));
                    }
                }

                // Generate SWF Containing a MP3 as class "SoundClass".
                var metadata:Object = {};
                var bytes:ByteArray = MP3Extraction.extractSound(chartData, metadata);
                bytes.position = 0;

                _mp3Frame = metadata.frame - 2;
                _mp3Rate = MP3Extraction.formatRate(metadata.format) / 44100;
                _sound = new Sound();
                _sound.loadCompressedDataFromByteArray(bytes, bytes.length);

                if (_rate != 1 || _isReverse)
                {
                    _rateSound = _sound;
                    _sound = new Sound();
                    if (_isReverse)
                        _sound.addEventListener("sampleData", onReverseSound);
                    else
                        _sound.addEventListener("sampleData", onRateSound);
                }

                _isSoundLoaded = true;

                // Generate a SWF containing no audio, used as a background.
                var mloader:Loader = new Loader();
                var mbytes:ByteArray = SwfSilencer.stripSound(chartData);
                mloader.contentLoaderInfo.addEventListener(Event.COMPLETE, mp3MusicCompleteHandler);

                if (!mbytes)
                {
                    _loadFailed = true;
                    return;
                }

                mloader.loadBytes(mbytes, AirContext.getLoaderContext());

                // Store SWF
                if (AppState.instance.air.useLocalFileCache && storeChartData)
                {
                    try
                    {
                        Logger.info(this, "Saving Cache File for " + _songInfo.level);
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
                _clip = e.target.content as MovieClip;

                stop();

                chartData = _musicForcibleLoader.inputBytes;
                _musicForcibleLoader = null;

                _isClipLoaded = true;
                loadComplete();
            }

            if (_chartType == NoteChart.FFR_LEGACY)
            {
                _chart = NoteChart.parseChart(_chartType, _songInfo, chartData);
                chartLoadComplete(e);
            }

            bytesSWF = chartData;
        }

        private function mp3MusicCompleteHandler(e:Event):void
        {
            var info:LoaderInfo = e.currentTarget as LoaderInfo;
            _clip = info.content as MovieClip;

            _isClipLoaded = true;
            loadComplete();
        }

        public function getSoundObject():Sound
        {
            if (_rate != 1 || _isReverse)
                return _rateSound;
            return _sound;
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
                sample = (notes[notes.length - 1].frame * 1470) - sample + (63 - _mp3Frame) * 1470 / _rate;
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

        private function stopSound(e:Event):void
        {
            _musicIsPlaying = false;
        }

        private function chartLoadComplete(e:Event):void
        {
            Logger.info(this, "Chart Load Success");
            _isChartLoaderLoading = false;
            switch (_chartType)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_MP3:
                    _chart = NoteChart.parseChart(NoteChart.FFR, _songInfo, Crypt.ROT255(Crypt.B64Decode(e.target.data)));
                    break;

                case NoteChart.FFR_BEATBOX:
                case NoteChart.FFR_RAW:
                    _chart = NoteChart.parseChart(_chartType, _songInfo, e.target.data);
                    break;

                case NoteChart.FFR_LEGACY:
                    if (_songInfo.noteCount == 0)
                        _songInfo.noteCount = notes.length;
                    break;

                case NoteChart.THIRDSTYLE:
                    _chart = NoteChart.parseChart(_chartType, _songInfo, e.target.data);
                    break;

                default:
                    throw Error("Unsupported NoteChart type!");
            }

            _isChartLoaded = true;

            if (_noteMod.required() && _chartType != NoteChart.FFR_LEGACY)
                generateModNotes();

            Logger.info(this, "Chart parsed with " + notes.length + " notes, " + (notes.length > 0 ? TimeUtil.convertToHHMMSS(notes[notes.length - 1].time) : "0:00") + " length.");

            loadComplete();
        }

        private function musicLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Music Load Error: " + Logger.event_error(err));
            _isMusicLoaderLoading = false;
            //_gvars.gameMain.addPopup(new PopupMessage(_gvars.gameMain, "An error occured while loading the music.", "ERROR"));
            removeLoaderListeners();
            _loadFailed = true;
        }

        private function chartLoadError(err:ErrorEvent = null):void
        {
            Logger.error(this, "Chart Load Error: " + Logger.event_error(err));
            //_gvars.gameMain.addPopup(new PopupMessage(_gvars.gameMain, "An error occured while loading the chart file.", "ERROR"));
            _isChartLoaderLoading = false;
            removeLoaderListeners();
            _loadFailed = true;
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

            if (_sound)
            {
                _soundChannel = _sound.play(_musicDelay * 1000 / _rate / 30 + seek);
                _soundChannel.soundTransform = SoundMixer.soundTransform;
                _soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
            }

            if (_clip)
                _clip.gotoAndPlay(2 + _musicDelay + int(seek * 30 / 1000));

            _musicIsPlaying = true;
        }

        public function stop():void
        {
            if (_clip)
                _clip.stop();

            if (_soundChannel)
            {
                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, stopSound);
                _soundChannel.stop();
                _musicPausePosition = 0;
                _soundChannel = null;
            }

            _musicIsPlaying = false;
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
            if (_clip)
                _clip.play();

            if (_sound)
            {
                _soundChannel = _sound.play(_musicPausePosition);
                _soundChannel.addEventListener(Event.SOUND_COMPLETE, stopSound);
            }

            _musicIsPlaying = true;
        }

        private function playClips(clip:MovieClip):void
        {
            clip.gotoAndPlay(2 + _musicDelay);

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

            if (_clip)
                playClips(_clip);
        }

        public function generateModNotes():void
        {
            for (var i:int = notes.length - 1; i >= 0; i--)
                _modNotes[i] = _noteMod.transformNote(notes[i]);
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
                return notes[index];
        }

        public function get totalNotes():int
        {
            if (_noteMod.required())
                return _noteMod.transformTotalNotes();

            if (!notes)
                return 0;

            return notes.length;
        }

        public function get chartTime():Number
        {
            if (_noteMod.required())
                return _noteMod.transformSongLength();

            if (!notes || notes.length <= 0)
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

        public function get frameRate():int
        {
            return _type == NoteChart.FFR_MP3 ? _frameRate : _chart.framerate;
        }

        public function updateMusicDelay():void
        {
            _noteMod.start();
            if (_isIsolation && totalNotes > 0)
            {
                if (_isReverse)
                    _musicDelay = Math.max(0, notes[notes.length - 1].frame - notes[Math.max(0, notes.length - 1 - _isolationOffset)].frame - 60);
                else
                    _musicDelay = Math.max(0, notes[_isolationOffset].frame - 60);
            }
            else
                _musicDelay = 0;
        }

        public function getPosition():int
        {
            switch (_type)
            {
                case NoteChart.FFR:
                case NoteChart.FFR_RAW:
                case NoteChart.FFR_LEGACY:
                    return (_clip.currentFrame - 2 - _musicDelay) * 1000 / 30;

                case NoteChart.FFR_MP3:
                case NoteChart.THIRDSTYLE:
                    return _soundChannel ? _soundChannel.position - _musicDelay / _rate * 1000 / 30 : 0;

                default:
                    return 0;
            }
        }
    }
}
