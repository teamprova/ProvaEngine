module prova.init;

import derelict.freetype;
import derelict.openal.al;
import derelict.sdl2.sdl;
import derelict.vorbis;
import prova;
import std.conv;

package void init()
{
  initSDL();
  initOpenAL();
  initVorbis();
  initFreeType();
}

private void initSDL()
{
  DerelictSDL2.load();

  if(SDL_Init(SDL_INIT_EVERYTHING) < 0)
    throw new Exception("Initialization Error: " ~ to!string(SDL_GetError()));
}

private void initOpenAL()
{
  DerelictAL.load();

  Audio.device = alcOpenDevice(null);

  if(!Audio.device)
    throw new Exception("Initialization Error: Failed to open audio device");

  Audio.context = alcCreateContext(Audio.device, null);

  if(!Audio.context)
    throw new Exception("Initialization Error: Failed audio context creation");

  alcMakeContextCurrent(Audio.context);
}

private void initVorbis()
{
  DerelictVorbisFile.load();
}

private void initFreeType()
{
  DerelictFT.load();
  int error = FT_Init_FreeType(&Font.ftlibrary);

  if(error != 0)
    throw new Exception("Initialization Error: Failed to initalize FreeType library");
}

package void finalize()
{
  finalizeOpenAL();
  finalizeSDL();
  finalizeFreeType();
}

private void finalizeOpenAL()
{
  alcMakeContextCurrent(null);
  alcDestroyContext(Audio.context);
  alcCloseDevice(Audio.device);
}

private void finalizeSDL()
{
  SDL_Quit();
}

private void finalizeFreeType()
{
  FT_Done_FreeType(Font.ftlibrary);
}
