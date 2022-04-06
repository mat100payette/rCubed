package classes
{
    import com.flashfla.media.MP3Extraction;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.utils.ByteArray;

    public class SoundPlayer
    {
        public var isPlaying:Boolean;
        public var userPaused:Boolean;
        public var userStopped:Boolean;

        private var _pausePosition:int;
        private var _noRepeat:Boolean;

        private var _sound:Sound;
        private var _soundTransform:SoundTransform;
        private var _soundChannel:SoundChannel;

        public function SoundPlayer(swfBytes:ByteArray, isMP3File:Boolean = false, noRepeat:Boolean = false)
        {
            isPlaying = false;
            userPaused = false;
            userStopped = false;

            _soundTransform = new SoundTransform();
            _pausePosition = 0;
            _noRepeat = noRepeat;

            setBytes(swfBytes, isMP3File);
        }

        public function setBytes(bytes:ByteArray, isMP3File:Boolean = false):void
        {
            if (!bytes || bytes.length <= 0)
                return;

            if (!isMP3File)
                bytes = MP3Extraction.extractSound(bytes);

            bytes.position = 0;

            if (_sound != null)
            {
                try
                {
                    _sound.close();
                }
                catch (e:Error)
                {
                    Logger.error(this, "Could not close sound properly");
                }
            }

            _sound = new Sound();
            _sound.loadCompressedDataFromByteArray(bytes, bytes.length);
        }

        public function set volume(value:Number):void
        {
            if (_soundTransform == null || isNaN(value))
                return;

            _soundTransform.volume = value;
        }

        public function get soundTransform():SoundTransform
        {
            return _soundTransform;
        }

        public function start():void
        {
            if (!_sound || userPaused)
                return;

            stop();

            _soundChannel = _sound.play(_pausePosition);
            _soundChannel.soundTransform = _soundTransform;
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, onComplete);

            isPlaying = true;
        }

        private function onComplete(e:Event):void
        {
            SoundChannel(e.target).removeEventListener(e.type, onComplete);
            _pausePosition = 0;

            if (_noRepeat)
                isPlaying = false;
            else
                start();
        }

        public function stop():void
        {
            if (_soundChannel)
            {
                _soundChannel.stop();
                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
            }

            isPlaying = false;
        }

        public function userPause():void
        {
            _pausePosition = _soundChannel.position;
            userPaused = true;
            stop();
        }

        public function userStart():void
        {
            userPaused = userStopped = false;
            start();
        }

        public function userStop():void
        {
            _pausePosition = 0;
            userStopped = true;
            stop();
        }
    }
}
