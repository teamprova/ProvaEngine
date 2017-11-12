module prova.init;

import derelict.sdl2.mixer,
       derelict.sdl2.sdl,
       prova,
       std.conv;

private Instance _provaInstance;

/**
 * True if prova.init() was called
 */
@property bool provaInitialized()
{
  return is(_provaInstance);
}

/**
 * Initializes SDL and OpenGL
 *
 * Call at the start of your program
 * or let the Game class call it implicitly
 * on instantiation
 */
void init()
{
  if(_provaInstance)
    throw new Exception("ProvaEngine already initialized");

  _provaInstance = new Instance();
}

private class Instance
{
  this()
  {
    initSDL();
    initSDLMixer();
    initOpenGL();
  }

  void initSDL()
  {
    DerelictSDL2.load();

    if(SDL_Init(SDL_INIT_EVERYTHING) < 0)
      throw new Exception("Initialization Error: " ~ to!string(SDL_GetError()));
  }

  void initSDLMixer()
  {
    DerelictSDL2Mixer.load();

    Mix_Init(
      MIX_INIT_FLAC |
      MIX_INIT_MOD |
      MIX_INIT_MP3 |
      MIX_INIT_OGG
    );

    if(Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 2, 4096) < 0)
      throw new Exception("Initialization Error: " ~ to!string(Mix_GetError()));
  }

  void initOpenGL()
  {
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    DerelictGL3.load();
  }

  ~this()
  {
    Mix_CloseAudio();
    Mix_Quit();
    SDL_Quit();
  }
}