module prova.init;

import derelict.sdl2.sdl,
       prova.graphics,
       std.conv;

private bool _provaInitialized = false;

/**
 * True if prova.init() was called
 */
@property bool provaInitialized()
{
  return _provaInitialized;
}

/**
 * Initializes SDL and OpenGL
 *
 * call at the start of your program
 * or let the Game class call it implicitly
 * on instantiation
 */
void init()
{
  if(_provaInitialized)
    throw new Exception("ProvaEngine already initialized");

  DerelictSDL2.load();

  if(SDL_Init(SDL_INIT_EVERYTHING) < 0)
    throw new Exception("Initialization Error: " ~ to!string(SDL_GetError()));

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

  DerelictGL3.load();
}