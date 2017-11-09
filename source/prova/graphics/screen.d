module prova.graphics.screen;

import derelict.sdl2.sdl,
       prova.core,
       prova.graphics,
       prova.math,
       std.conv,
       std.math,
       std.typecons;

///
class Screen
{
  ///
  GLContext glContext;
  ///
  ShaderProgram flatShaderProgram;
  ///
  SpriteBatch spriteBatch;
  private Game game;
  private Matrix transforms;
  private Color clearColor;
  private int _width;
  private int _height;

  package(prova) this(Game game, int width, int height)
  {
    this.game = game;
    _width = width;
    _height = height;

    glContext = new GLContext(game.window);
    flatShaderProgram = new FlatShaderProgram();
    spriteBatch = new SpriteBatch();
    clearColor.set(0, 0, 0, 0);

    disableVSync();
    glDepthFunc(GL_LEQUAL);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  }

  ///
  @property int width()
  {
    return _width;
  }

  ///
  @property int height()
  {
    return _height;
  }

  /// Forward of the active scene's camera
  @property Camera camera()
  {
    return game.activeScene.camera;
  }

  ///
  void resize(int width, int height)
  {
    SDL_SetWindowSize(game.window, width, height);
    updateResolution(width, height);
  }

  package(prova) void updateResolution(int width, int height)
  {
    _width = width;
    _height = height;

    glViewport(0, 0, width, height);
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
  void drawLine(float x1, float y1, float x2, float y2, Color color)
  {
    float[] vertices = [ x1, y1, x2, y2 ];
    uint[] indexes = [0, 1];

    auto mesh = scoped!Mesh();
    mesh.setVBO(vertices, 2);
    mesh.setIBO(indexes);

    flatShaderProgram.setMatrix("transform", transforms);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINES, mesh);
  }

  ///
  void drawLine(Vector2 start, Vector2 end, Color color)
  {
    drawLine(start.x, start.y, end.x, end.y, color);
  }

  ///
  void drawLine(Vector3 start, Vector3 end, Color color)
  {
    float[] vertices = [
      start.x, start.y, start.z,
      end.x, end.y, end.z
    ];
    uint[] indexes = [0, 1];

    auto mesh = scoped!Mesh();
    mesh.setVBO(vertices, 3);
    mesh.setIBO(indexes);

    flatShaderProgram.setMatrix("transform", transforms);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINES, mesh);
  }

  ///
  void drawRect(Rect rect, Color color)
  {
    drawRect(rect.left, rect.top, rect.width, rect.height, color);
  }

  ///
  void drawRect(float x, float y, float width, float height, Color color)
  {
    float[] vertices = [
      x, y - height, 
      x + width, y - height, 
      x + width, y, 
      x, y
    ];
    uint[] indexes = [0, 1, 2, 3];

    auto mesh = scoped!Mesh();
    mesh.setVBO(vertices, 2);
    mesh.setIBO(indexes);

    flatShaderProgram.setMatrix("transform", transforms);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINE_LOOP, mesh);
  }

  ///
  void drawCircle(Vector2 position, float radius, int segments, Color color)
  {
    drawCircle(position.x, position.y, radius, segments, color);
  }

  ///
  void drawCircle(float x, float y, float radius, int segments, Color color)
  {
    float[] vertices;
    uint[] indexes;

    indexes.length = segments + 1;
    vertices.length = indexes.length * 2;

    foreach(i; 0 .. indexes.length)
    {
      Vector2 point;
      point.setMagnitude(radius);
      point.setDirection(i * 360 / segments);

      vertices[i * 2] = point.x + x;
      vertices[i * 2 + 1] = point.y + y;
      indexes[i] = cast(uint) i;
    }

    auto mesh = scoped!Mesh();
    mesh.setVBO(vertices, 2);
    mesh.setIBO(indexes);

    flatShaderProgram.setMatrix("transform", transforms);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINE_LOOP, mesh);
  }

  ///
  void drawSprite(Sprite sprite, Vector3 position)
  {
    spriteBatch.batchSprite(sprite, position);
  }

  ///
  void drawSprite(Sprite sprite, Vector2 position)
  {
    spriteBatch.batchSprite(sprite, Vector3(position.x, position.y, 0));
  }

  ///
  void drawSprite(Sprite sprite, float x, float y)
  {
    spriteBatch.batchSprite(sprite, Vector3(x, y, 0));
  }

  ///
  void drawSprite(Sprite sprite, float x, float y, float z)
  {
    spriteBatch.batchSprite(sprite, Vector3(x, y, z));
  }

  ///
  void drawSprite(AnimatedSprite sprite, Vector3 position)
  {
    spriteBatch.batchSprite(sprite, position);
  }

  ///
  void drawSprite(AnimatedSprite sprite, Vector2 position)
  {
    spriteBatch.batchSprite(sprite, Vector3(position.x, position.y, 0));
  }

  ///
  void drawSprite(AnimatedSprite sprite, float x, float y)
  {
    spriteBatch.batchSprite(sprite, Vector3(x, y, 0));
  }

  ///
  void drawSprite(AnimatedSprite sprite, float x, float y, float z)
  {
    spriteBatch.batchSprite(sprite, Vector3(x, y, z));
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
  void clear()
  {
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    glClearDepth(1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  }

  package(prova) void prepare()
  {
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
    transforms = camera.getProjection() * camera.getTransform();

    spriteBatch.begin(transforms);
  }

  package(prova) void endDynamic()
  {
    spriteBatch.end();
  }

  package(prova) void prepareStatic()
  {
    glDisable(GL_DEPTH_TEST);

    transforms = camera.getUIMatrix();

    spriteBatch.begin(transforms);
  }

  package(prova) void endStatic()
  {
    spriteBatch.end();
  }

  package(prova) void swapBuffer()
  {
    SDL_GL_SwapWindow(game.window);
  }
}