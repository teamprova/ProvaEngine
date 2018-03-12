module prova.graphics.primitives.texture;

import imageformats,
       prova.graphics,
       std.algorithm.mutation,
       std.string;

///
class Texture
{
  private static Texture[string] textureCache;
  ///
  immutable uint id;
  ///
  immutable int width;
  ///
  immutable int height;

  /// Creates a new blank texture using the specified width and height
  this(int width, int height)
  {
    this.id = generateTexture(null, width, height);
    this.width = width;
    this.height = height;
  }

  /**
   * Params:
   *   data = RGBA by row
   */
  this(ubyte[] data, int width, int height)
  {
    this.id = generateTexture(data, width, height);
    this.width = width;
    this.height = height;
  }

  private uint generateTexture(ubyte[] data, int width, int height)
  {
    uint id;
    glGenTextures(1, &id);
    glBindTexture(GL_TEXTURE_2D, id);
    
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

    return id;
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

  package(prova) static cleanUp()
  {
    textureCache.clear();
  }
}