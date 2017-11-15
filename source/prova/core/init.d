module prova.core.init;

import derelict.sdl2.mixer,
       derelict.sdl2.sdl,
       prova,
       std.conv;

package void init()
{
  initSDL();
  initSDLMixer();
  initOpenGL();
}

private void initSDL()
{
  DerelictSDL2.load();

  if(SDL_Init(SDL_INIT_EVERYTHING) < 0)
    throw new Exception("Initialization Error: " ~ to!string(SDL_GetError()));
}

private void initSDLMixer()
{
  DerelictSDL2Mixer.load();

  Mix_Init(
    MIX_INIT_FLAC |
    MIX_INIT_MOD |
    MIX_INIT_MP3 |
    MIX_INIT_OGG
  );

  if(Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, AUDIO_S16SYS, 2, 4096) < 0)
    throw new Exception("Initialization Error: " ~ to!string(Mix_GetError()));

  Mix_ChannelFinished(&Audio.channelFinished);
}

private void initOpenGL()
{
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

  DerelictGL3.load();
}

package void finalize()
{
  Mix_CloseAudio();
  Mix_Quit();
  SDL_Quit();
}