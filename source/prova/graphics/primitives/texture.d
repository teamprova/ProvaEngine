module prova.graphics.primitives.texture;

import imageformats,
       prova.graphics,
       std.algorithm.mutation,
       std.string;

///
class Texture
{
  private static Texture[string] textureCache;
  private uint _id;
  private int _width;
  private int _height;

  /// Creates a new blank texture using the specified width and height
  this(int width, int height)
  {
    _width = width;
    _height = height;

    glGenTextures(1, &_id);
    glBindTexture(GL_TEXTURE_2D, _id);
    
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
      null
    );
  }

  /**
   * Params:
   *   data = RGBA by row
   */
  this(ubyte[] data, int width, int height)
  {
    _width = width;
    _height = height;

    glGenTextures(1, &_id);
    glBindTexture(GL_TEXTURE_2D, _id);
    
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
      data.ptr
    );
  }

  /// Loads a texture from file or cache
  this(string path)
  {
    Texture cachedTexture = fetchTexture(path);

    _id = cachedTexture.id;
    _width = cachedTexture.width;
    _height = cachedTexture.height;
  }

  ///
  @property uint id()
  {
    return _id;
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

  private static Texture fetchTexture(string path)
  {
    if(path in textureCache)
      return textureCache[path];

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

  package(prova) static cleanUp()
  {
    // Textures are freed when the context is destroyed
    textureCache.clear();
  }
}