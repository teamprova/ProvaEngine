module prova.graphics.screen;

import derelict.sdl2.sdl,
       prova.core,
       prova.graphics,
       prova.math,
       std.conv,
       std.math;

///
class Screen : RenderTarget
{
  ///
  GLContext glContext;
  private Game game;
  private Mesh quad;
  private Matrix quadProjectionMatrix;
  private Color clearColor;

  package(prova) this(Game game, int width, int height)
  {
    this.game = game;

    glContext = new GLContext(game.window);
    super(width, height);
    disableVSync();

    quad = new SpriteMesh();
    quadProjectionMatrix = createQuadProjectionMatrix();
    clearColor.set(0, 0, 0, 0);
  }

  private Matrix createQuadProjectionMatrix()
  {
    Matrix quadProjectionMatrix = Matrix.identity;
    quadProjectionMatrix = quadProjectionMatrix.scale(2, 2, 1);
    quadProjectionMatrix = quadProjectionMatrix.translate(-1, -1);

    return quadProjectionMatrix;
  }

  // Forward of the active scene's camera
  private @property Camera camera()
  {
    return game.activeScene.camera;
  }

  /// Resizes the window
  override void resize(int width, int height)
  {
    SDL_SetWindowSize(game.window, width, height);
    updateResolution(width, height);
  }

  package(prova) void updateResolution(int width, int height)
  {
    super.resize(width, height);
  }

  ///
  void enableVSync()
  {
    if(SDL_GL_SetSwapInterval(1) < 0)
      throw new Exception("VSync Error: " ~ to!string(SDL_GetError()));
  }

  ///
  void disableVSync()
  {
    if(SDL_GL_SetSwapInterval(0) < 0)
      throw new Exception("VSync Error: " ~ to!string(SDL_GetError()));
  }

  ///
  void setClearColor(float r, float g, float b)
  {
    clearColor.r = r;
    clearColor.g = g;
    clearColor.b = b;
  }

  ///
  void setClearColor(Color color)
  {
    clearColor = color;
  }

  ///
  override void clear()
  {
    bindFrameBuffer(0);

    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    glClearDepth(1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    super.clear();
  }

  package(prova) void prepare()
  {
    clear();

    if(camera.useDepthBuffer)
      glEnable(GL_DEPTH_TEST);
    else
      glDisable(GL_DEPTH_TEST);

    if(camera.resolutionDependent) {
      camera.width = width;
      camera.height = height;
    }
  }

  package(prova) void prepareDynamic()
  {
    Matrix projection = camera.getScreenMatrix();

    begin(projection);
  }

  package(prova) void endDynamic()
  {
    end();
  }

  package(prova) void prepareStatic()
  {
    Matrix projection = camera.getUIMatrix();

    begin(projection);
  }

  package(prova) void endStatic()
  {
    end();
  }

  package(prova) void swapBuffer()
  {
    // render the FBO
    ShaderProgram shaderProgram = SpriteBatch.defaultShaderProgram;

    shaderProgram.setMatrix("transform", quadProjectionMatrix);
    shaderProgram.setTexture(0, texture.id);
    shaderProgram.setVector4("clip", Rect(0, 0, 1, 1));
    shaderProgram.setVector4("tint", Color(1, 1, 1));
    shaderProgram.drawMesh(quad, 0, DrawMode.TRIANGLE_FAN);

    SDL_GL_SwapWindow(game.window);
  }
}
