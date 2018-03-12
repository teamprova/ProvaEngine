module prova.graphics.rendertarget;

import prova.graphics,
       prova.math,
       std.typecons;

///
class RenderTarget
{
  static ShaderProgram flatShaderProgram;
  private static uint currentFrameBuffer = -1;

  ///
  SpriteBatch spriteBatch;
  ///
  protected Matrix projection;

  private uint renderBufferId;
  private uint _frameBufferId;
  private Texture _texture;
  private int _width;
  private int _height;
  private bool begun;

  ///
  this(int width, int height)
  {
    if(!flatShaderProgram)
      flatShaderProgram = new FlatShaderProgram();

    spriteBatch = new SpriteBatch();

    resize(width, height);
  }

  ///
  void resize(int width, int height)
  {
    if(_texture) {
      _texture.destroy();
      glDeleteFramebuffers(1, &_frameBufferId);
      glDeleteRenderbuffers(1, &renderBufferId);
    }

    _texture = new Texture(width, height);
    _width = width;
    _height = height;

    // create the frame buffer
    glGenFramebuffers(1, &_frameBufferId);
    bindFrameBuffer();

    // attach texture to the frame buffer
    glFramebufferTexture2D(
      GL_FRAMEBUFFER,
      GL_COLOR_ATTACHMENT0,
      GL_TEXTURE_2D,
      _texture.id,
      0
    );

    // create render buffer
    glGenRenderbuffers(1, &renderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);

    // attach render buffer to frame buffer
    glFramebufferRenderbuffer(
      GL_FRAMEBUFFER,
      GL_DEPTH_ATTACHMENT,
      GL_RENDERBUFFER,
      renderBufferId
    );

    // change settings
    glViewport(0, 0, width, height);
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

  ///
  @property Texture texture()
  {
    return _texture;
  }

  ///
  @property uint frameBufferId()
  {
    return _frameBufferId;
  }

  package(prova) void bindFrameBuffer()
  {
    bindFrameBuffer(_frameBufferId);
  }

  /// Updates projection and prepares batches
  void begin(Matrix projection)
  {
    if(begun)
      throw new Exception("RenderTarget already started");

    spriteBatch.begin(this, projection);

    this.projection = projection;
    begun = true;
  }

  /// Finishes the batch
  void end()
  {
    if(!begun)
      throw new Exception("RenderTarget not ready, call begin(Matrix projection)");

    spriteBatch.end();
    begun = false;
  }

  ///
  void drawLine(float x1, float y1, float x2, float y2, Color color)
  {
    if(!begun)
      throw new Exception("RenderTarget not ready, call begin(Matrix projection)");

    float[] vertices = [ x1, y1, x2, y2 ];
    uint[] indexes = [0, 1];

    auto mesh = scoped!Mesh();
    mesh.setVBO(vertices, 2);
    mesh.setIBO(indexes);

    flatShaderProgram.setMatrix("transform", projection);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINES, mesh, this);
  }

  ///
  void drawLine(Vector2 start, Vector2 end, Color color)
  {
    drawLine(start.x, start.y, end.x, end.y, color);
  }

  ///
  void drawLine(Vector3 start, Vector3 end, Color color)
  {
    if(!begun)
      throw new Exception("RenderTarget not ready, call begin(Matrix projection)");

    float[] vertices = [
      start.x, start.y, start.z,
      end.x, end.y, end.z
    ];
    uint[] indexes = [0, 1];

    auto mesh = scoped!Mesh();
    mesh.setVBO(vertices, 3);
    mesh.setIBO(indexes);

    flatShaderProgram.setMatrix("transform", projection);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINES, mesh, this);
  }

  ///
  void drawRect(Rect rect, Color color)
  {
    drawRect(rect.left, rect.top, rect.width, rect.height, color);
  }

  ///
  void drawRect(float x, float y, float width, float height, Color color)
  {
    if(!begun)
      throw new Exception("RenderTarget not ready, call begin(Matrix projection)");

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

    flatShaderProgram.setMatrix("transform", projection);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINE_LOOP, mesh, this);
  }

  ///
  void drawCircle(Vector2 position, float radius, int segments, Color color)
  {
    drawCircle(position.x, position.y, radius, segments, color);
  }

  ///
  void drawCircle(float x, float y, float radius, int segments, Color color)
  {
    if(!begun)
      throw new Exception("RenderTarget not ready, call begin(Matrix projection)");

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

    flatShaderProgram.setMatrix("transform", projection);
    flatShaderProgram.setVector4("color", color);
    flatShaderProgram.drawMesh(DrawMode.LINE_LOOP, mesh, this);
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
  void clear()
  {
    bindFrameBuffer();

    glClearDepth(1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  }

  package(prova) static void bindFrameBuffer(uint id)
  {
    if(id == currentFrameBuffer)
      return;

    glBindFramebuffer(GL_FRAMEBUFFER, id);
    currentFrameBuffer = id;
  }

  ~this()
  {
    glDeleteFramebuffers(1, &_frameBufferId);
    glDeleteRenderbuffers(1, &renderBufferId);
  }
}