module prova.audio.audioclip;

import derelict.openal.al;
import derelict.vorbis;
import prova.interfaces;
import std.string;

/// Only supports ogg for now
final class AudioClip : Asset
{
  /// What distance in units equals one meter (defaults to 1)
  static float scale = 1;
  ///
  package(prova) uint bufferId;
  private uint _channels;

  ///
  this(string path)
  {
    genFromOgg(path);
  }

  ///
  @property uint channels()
  {
    return _channels;
  }

  private void genFromOgg(string path)
  {
    OggVorbis_File ogg;

    if(ov_fopen(toStringz(path), &ogg) < 0)
      throw new Exception("\"" ~ path ~ "\" is not a valid Ogg file");

    const BUFFER_SIZE = 4096;
    byte[BUFFER_SIZE] dataBuffer;
    byte[] data;
    long bytesRead = 0;
    int currentSection;

    long requiredCapacity = ov_pcm_total(&ogg, -1) * ogg.vi.channels * 2;
    data.reserve(requiredCapacity);

    do{
      bytesRead = ov_read(&ogg, dataBuffer.ptr, BUFFER_SIZE, 0, 2, 1, &currentSection);

      data ~= dataBuffer[0 .. bytesRead];
    }
    while(bytesRead > 0);

    genBuffer(ogg.vi.channels, data, ogg.vi.rate);

    ov_clear(&ogg);
  }

  private void genBuffer(uint channels, byte[] data, int frequency)
  {
    _channels = channels;

    ALenum format = channels ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;

    alGenBuffers(1, &bufferId);
    alBufferData(bufferId, format, data.ptr, cast(int) data.length, frequency);
  }
}
