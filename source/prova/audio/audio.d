module prova.audio.audio;

import derelict.sdl2.mixer,
       prova.core,
       std.string;

///
class Audio
{
  package(prova) bool attached;
  private static Mix_Chunk*[string] cache;
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
      cache[path] = Mix_LoadWAV(toStringz(path));

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
      import std.stdio; writeln(left, " ", right);

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
}