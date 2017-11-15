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
  ///
  float volume = 1;
  package(prova) Entity entity;
  private static Mix_Chunk*[string] cache;
  private static shared Audio[int] playingChannels;
  private Mix_Chunk* chunk;
  private int channel = -1;
  private bool _looping;
  private float left = .5;
  private float right = .5;

  ///
  this(string path)
  {
    if(!(path in cache)) 
      cacheFile(path);

    chunk = cache[path];
  }

  ///
  @property float panning()
  {
    return right - left;
  }

  /// Panning should be in range [-1, 1]
  @property void panning(float value)
  {
    if(value < 0) {
      left = .5 + -value / 2;
      right = 1 - left;
    }
    else {
      right = .5 + value / 2;
      left = 1 - right;
    }
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
    if(isPlaying())
      stop();

    _looping = loop;
    channel = Mix_PlayChannel(-1, chunk, loop ? -1: 0);

    playingChannels[channel] = cast(shared(Audio)) this;
    Mix_RegisterEffect(channel, &effectFunction, null, null);
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

  private extern(C) static void effectFunction(int channel, void* stream, int length, void* udata) nothrow
  {
    shared(Audio) source = playingChannels[channel];
    short* buffer = cast(short*) stream;

    foreach(i; 0 .. length / 4) {
      *buffer = cast(short) (*buffer * source.left * source.volume);
      *++buffer = cast(short) (*buffer * source.right * source.volume);
      buffer++;
    }
  }

  package(prova) extern(C) static void channelFinished(int channel) nothrow
  {
    shared(Audio) source = playingChannels[channel];

    if(source.channel == channel)
      source.channel = -1;

    playingChannels.remove(channel);
  }
}