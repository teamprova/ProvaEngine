module prova.audio.audio;

import derelict.openal.al,
       prova.audio,
       prova.core,
       prova.math;

private class AudioBuffer
{
  uint id;
  int channels;

  ~this()
  {
    alDeleteBuffers(1, &id);
  }
}

/// 
class Audio
{
  /// What distance in units equals one meter (defaults to 1)
  static float scale = 1;
  package(prova) static ALCdevice* device;
  package(prova) static ALCcontext* context;
  private static AudioBuffer[string] bufferCache;

  package(prova) Entity entity;
  private uint sourceId;
  private AudioBuffer buffer;
  private bool _looping = false;
  private float _volume = 1;
  private float _pitch = 1;

  /// Limited to Ogg files for now
  this(string path)
  {
    if(!(path in bufferCache)) 
      cacheFile(path);

    buffer = bufferCache[path];

    alGenSources(1, &sourceId);
    alSourcei(sourceId, AL_BUFFER, buffer.id);
  }

  ///
  @property uint channels()
  {
    return buffer.channels;
  }

  ///
  @property float volume()
  {
    return _volume;
  }

  ///
  @property void volume(float value)
  {
    _volume = value;
    alSourcef(sourceId, AL_GAIN, value);
  }

  ///
  @property float pitch()
  {
    return _pitch;
  }

  ///
  @property void pitch(float value)
  {
    _pitch = value;
    alSourcef(sourceId, AL_PITCH, value);
  }

  ///
  @property bool isPlaying()
  {
    ALenum status;
    alGetSourcei(sourceId, AL_SOURCE_STATE, &status);

    return status == AL_PLAYING;
  }

  ///
  @property bool looping()
  {
    return _looping;
  }

  ///
  void play(bool loop = false)
  {
    if(isPlaying())
      stop();

    _looping = loop;
    alSourcei(sourceId, AL_LOOPING, loop);

    alSourceRewind(sourceId);
    alSourcePlay(sourceId);
  }

  ///
  void stop()
  {
    alSourceStop(sourceId);
  }

  ///
  void pause()
  {
    alSourcePause(sourceId);
  }

  ///
  void resume()
  {
    alSourcePlay(sourceId);
  }

  package(prova) void update()
  {
    if(!entity)
      return;

    Vector3 position = entity.position / scale;
    Vector3 velocity = entity.velocity / scale;

    alSource3f(sourceId, AL_POSITION, position.x, position.y, position.z);
    alSource3f(sourceId, AL_VELOCITY, velocity.x, velocity.y, velocity.z);
  }

  ~this()
  {
    if(isPlaying)
      stop();

    alDeleteSources(1, &sourceId);
  }

  /// Limited to Ogg files for now
  static void cacheFile(string path)
  {
    AudioFile file = new OggFile(path);

    genBuffer(path, file.channels, file.data, file.frequency);
  }

  private static void genBuffer(string path, int channels, byte[] data, int frequency)
  {
    AudioBuffer buffer = new AudioBuffer();
    buffer.channels = channels;

    ALenum format = channels ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;

    alGenBuffers(1, &buffer.id);
    alBufferData(buffer.id, format, data.ptr, cast(int) data.length, frequency);

    bufferCache[path] = buffer;
  }

  package(prova) static void cleanUp()
  {
    bufferCache.clear();
  }
}