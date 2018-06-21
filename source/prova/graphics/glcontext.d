module prova.graphics.glcontext;

import derelict.opengl;
import derelict.sdl2.sdl;
import std.conv;

///
final class GLContext
{
  ///
  SDL_GLContext handle;

  ///
  this(SDL_Window* window)
  {
    handle = SDL_GL_CreateContext(window);

    if(!handle)
      throw new Exception("Error initializing GL Context: " ~ to!string(SDL_GetError()));

    DerelictGL3.reload();
  }

  ~this()
  {
    SDL_GL_DeleteContext(handle);
  }
}
