module prova.graphics.rendertarget;

import prova.assets;
import prova.attachables;
import prova.graphics;
import prova.math;
import std.typecons;

///
class RenderTarget
{
  private static uint currentFrameBuffer = -1;

  ///
  SpriteBatch spriteBatch;
  ///
  protected Matrix projection;

  private GraphicsContext _context;
  private uint renderBufferId;
  private uint _frameBufferId;
  private Texture _texture;
  private int _width;
  private int _height;
  private bool begun;

  ///
  this(GraphicsContext context, int width, int height)
  {
    _context = context;
    spriteBatch = new SpriteBatch(context);
    _texture = new Texture(width, height);
    _width = width;
    _height = height;

    createFrameBuffer();
    createRenderBuffer();
  }

  private void createFrameBuffer()
  {
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

    glDepthFunc(GL_LEQUAL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glViewport(0, 0, width, height);
  }

  private void createRenderBuffer()
  {
    glGenRenderbuffers(1, &renderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);

    bindFrameBuffer();

    glFramebufferRenderbuffer(
      GL_FRAMEBUFFER,
      GL_DEPTH_ATTACHMENT,
      GL_RENDERBUFFER,
      renderBufferId
    );
  }

  ///
  @property GraphicsContext context()
  {
    return _context;
  }

  ///
  void resize(int width, int height)
  {
    _width = width;
    _height = height;

    texture.recreate(null, width, height);

    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);

    // update settings
    glViewport(0, 0, width, height);
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
    assert(!begun, "RenderTarget should not already be started");

    spriteBatch.begin(this, projection);

    this.projection = projection;
    begun = true;
  }

  /// Finishes the batch
  void end()
  {
    assert(begun, "RenderTarget not ready, call begin(Matrix projection)");

    spriteBatch.end();
    begun = false;
  }

  /// Draws mesh using a flat shader
  void drawMesh(Mesh mesh, Matrix transform, DrawMode mode, Color color)
  {
    assert(begun, "RenderTarget not ready, call begin(Matrix projection)");

    context.flatShader.setMatrix("transform", projection * transform);
    context.flatShader.setVector4("color", color);
    context.flatShader.drawMesh(mesh, this, mode);
  }

  ///
  void drawSprite(Sprite sprite, Matrix transform)
  {
    spriteBatch.batchSprite(sprite, transform);
  }

  ///
  void drawSprite(AnimatedSprite sprite, Matrix transform)
  {
    spriteBatch.batchSprite(sprite, transform);
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
