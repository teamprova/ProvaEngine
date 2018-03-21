module prova.core.init;

import derelict.freetype,
       derelict.openal.al,
       derelict.sdl2.sdl,
       derelict.vorbis,
       prova,
       std.conv;

package void init()
{
  initSDL();
  initOpenAL();
  initVorbis();
  initOpenGL();
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

private void initOpenGL()
{
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

  DerelictGL3.load();
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
  finalizeOpenGL();
  finalizeSDL();
  finalizeFreeType();
}

private void finalizeOpenAL()
{
  alcMakeContextCurrent(null);
  alcDestroyContext(Audio.context);
  alcCloseDevice(Audio.device);
}

private void finalizeOpenGL()
{
  SpriteBatch.defaultShaderProgram = null;
  Texture.cleanUp();
}

private void finalizeSDL()
{
  SDL_Quit();
}

private void finalizeFreeType()
{
  FT_Done_FreeType(Font.ftlibrary);
}
