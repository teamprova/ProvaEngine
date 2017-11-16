module prova.audio.oggfile;

import derelict.vorbis,
       prova.audio,
       std.string;

///
class OggFile : AudioFile
{
  ///
  this(string path)
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

    this.data = data;
    this.channels = ogg.vi.channels;
    this.frequency = ogg.vi.rate;

    ov_clear(&ogg);
  }
}