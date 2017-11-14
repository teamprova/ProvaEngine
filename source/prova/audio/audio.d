module prova.audio.audio;

import derelict.sdl2.mixer,
       prova.core,
       std.string,
       std.conv;

///
class Audio
{
  /// What distance in units equals one meter (defaults to 1)
  static float scale = 1;
  package(prova) Entity entity;
  private static Mix_Chunk*[string] cache;
  private static shared Audio[int] playingChannels;
  private Mix_Chunk* chunk;
  private int channel = -1;
  private bool _looping;
  private ubyte _volume = MIX_MAX_VOLUME;
  private ubyte left = 127;
  private ubyte right = 127;

  ///
  this(string path)
  {
    if(!(path in cache)) 
      cacheFile(path);

    chunk = cache[path];
  }

  ///
  @property float volume()
  {
    return _volume / cast(float) MIX_MAX_VOLUME;
  }

  /// Volume should be in range [0, 1]
  @property void volume(float value)
  {
    _volume = cast(ubyte) (value * MIX_MAX_VOLUME);

    if(isPlaying)
      Mix_Volume(channel, _volume);
  }

  ///
  @property float panning()
  {
    return (right - left) / 254f;
  }

  /// Panning should be in range [-1, 1]
  @property void panning(float value)
  {
    if(value < 0) {
      left = cast(ubyte) (127 + 127 * -value);
      right = cast(ubyte) (254 - left);
    }
    else {
      right = cast(ubyte) (127 + 127 * value);
      left = cast(ubyte) (254 - right);
    }

    if(isPlaying)
      Mix_SetPanning(channel, left, right);
  }

  ///
  @property bool isPlaying()
  {
    if(channel == -1)
      return false;
    return Mix_Playing(channel) != 0;
  }

  ///
  @property bool looping()
  {
    return _looping;
  }

  ///
  void play(bool loop = false)
  {
    _looping = loop;
    channel = Mix_PlayChannel(-1, chunk, loop ? -1: 0);
    Mix_Volume(channel, _volume);
    Mix_SetPanning(channel, left, right);

    playingChannels[channel] = cast(shared(Audio)) this;
  }

  ///
  void stop()
  {
    Mix_HaltChannel(channel);
  }

  ///
  void pause()
  {
    Mix_Pause(channel);
  }

  ///
  void resume()
  {
    Mix_Resume(channel);
  }

  ~this()
  {
    if(isPlaying)
      stop();
  }

  ///
  static void cacheFile(string path)
  {
    Mix_Chunk* chunk = Mix_LoadWAV(toStringz(path));

    if(!chunk)
      throw new Exception("Audio load error: " ~ to!string(Mix_GetError()));

    cache[path] = chunk;
  }

  package(prova) extern(C) static void channelFinished(int channel) nothrow
  {
    shared(Audio) source = playingChannels[channel];

    if(source.channel == channel)
      source.channel = -1;

    playingChannels.remove(channel);
  }
}