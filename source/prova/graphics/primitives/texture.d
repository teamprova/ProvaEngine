module prova.graphics.primitives.texture;

import imageformats;
import prova.graphics;
import std.algorithm.mutation;
import std.string;

///
final class Texture
{
  private static Texture[string] textureCache;
  private static uint bindedId;
  ///
  immutable uint id;
  private int _width;
  private int _height;

  /// Creates a new blank texture using the specified width and height
  this(int width, int height)
  {
    this(null, width, height);
  }

  /**
   * Params:
   *   data = RGBA by row
   */
  this(ubyte[] data, int width, int height)
  {
    uint id;
    glGenTextures(1, &id);

    this.id = id;

    recreate(data, width, height);
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

  /**
   * Params:
   *   data = RGBA by row
   *   width = new width of the texture
   *   width = new height of the texture
   */
  void recreate(ubyte[] data, int width, int height)
  {
    bind();

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glTexImage2D(
      GL_TEXTURE_2D,
      0,
      GL_RGBA,
      width,
      height,
      0,
      GL_RGBA,
      GL_UNSIGNED_BYTE,
      data ? data.ptr : null
    );

    _width = width;
    _height = height;
  }

  /**
   * Updates the texture
   *
   * Params:
   *   data = RGBA by row
   */
  void update(ubyte[] data)
  {
    update(data, 0, 0, _width, _height);
  }

  /**
   * Updates part of the texture
   *
   * Params:
   *   data = RGBA by row
   *   x = x offset of the change
   *   y = y offset of the change
   *   width = width of the change
   *   height = height of the change
   */
  void update(ubyte[] data, int x, int y, int width, int height)
  {
    bind();

    glTexSubImage2D(
      GL_TEXTURE_2D,
      0,
      x,
      y,
      width,
      height,
      GL_RGBA,
      GL_UNSIGNED_BYTE,
      data ? data.ptr : null
    );
  }

  /// Resizes texture, preserving data
  void resize(int width, int height)
  {
    ubyte[] data = getData();

    recreate(null, width, height);
    update(data, 0, 0, _width, _height);
  }

  /// 
  ubyte[] getData()
  {
    ubyte[] data;
    data.length = _width * _height * 4;

    bind();

    glGetTexImage(
      GL_TEXTURE_2D,
      0,
      GL_RGBA,
      GL_UNSIGNED_BYTE,
      data.ptr
    );

    return data;
  }

  ///
  public static Texture fetch(string path)
  {
    return path in textureCache ? textureCache[path] : cacheFile(path);
  }

  ///
  public static Texture cacheFile(string path)
  {
    IFImage image = read_image(path, ColFmt.RGBA);

    flipImage(image);

    Texture texture = new Texture(image.pixels, image.w, image.h);
    textureCache[path] = texture;

    return texture;
  }

  private static void flipImage(ref IFImage image)
  {
    int rowLength = image.w * 4;

    foreach(i; 0 .. image.h)
    {
      const int start = i * rowLength;

      ubyte[] row = image.pixels[start .. start + rowLength];

      reverse(row);

      copy(image.pixels[start .. start + rowLength], row[0 .. rowLength]);
    }

    reverse(image.pixels);
  }

  ~this()
  {
    glDeleteTextures(1, &id);
  }

  package(prova) void bind()
  {
    bind(id);
  }

  package(prova) static void bind(uint id)
  {
    if(bindedId == id)
      return;

    bindedId = id;
    glBindTexture(GL_TEXTURE_2D, id);
  }

  package(prova) static cleanUp()
  {
    textureCache.clear();
  }
}
