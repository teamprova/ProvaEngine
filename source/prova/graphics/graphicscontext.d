module prova.graphics.graphicscontext;

import derelict.opengl;
import derelict.sdl2.sdl;
import prova.assets.shaders;
import prova.graphics;
import std.conv;

///
final class GraphicsContext
{
  private ShaderProgram _flatShader;
  private ShaderProgram _spriteShader;
  private SDL_GLContext handle;

  package(prova) this()
  {
    initOpenGL();
  }

  private void initOpenGL()
  {
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    DerelictGL3.load();
  }

  package(prova) void setWindow(SDL_Window* window)
  {
    handle = SDL_GL_CreateContext(window);

    if(!handle)
      throw new Exception("Error initializing GL Context: " ~ to!string(SDL_GetError()));

    DerelictGL3.reload();

    initShaders();
  }

  private void initShaders()
  {
    _flatShader = new FlatShaderProgram();
    _spriteShader = new SpriteShaderProgram();
  }

  ///
  @property ShaderProgram flatShader()
  {
    return _flatShader;
  }

  ///
  @property ShaderProgram spriteShader()
  {
    return _spriteShader;
  }

  ~this()
  {
    _flatShader.destroy();
    _spriteShader.destroy();

    SDL_GL_DeleteContext(handle);
  }
}
