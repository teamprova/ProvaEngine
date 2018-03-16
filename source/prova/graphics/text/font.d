module prova.graphics.text.font;

import derelict.freetype,
       prova.graphics,
       prova.math,
       std.algorithm,
       std.conv,
       std.math,
       std.string;

///
class Font
{
  package(prova) static FT_Library ftlibrary;
  ///
  immutable int size;
  immutable int ascentLine;
  immutable int descentLine;
  immutable bool hasKerning;
  ///
  float lineHeight;
  private Glyph[int] glyphs;
  private Texture _texture;
  private FT_Face fontface;
  private int largestGlyphLength;
  private int marginLeft = 0;
  private int left = 0;
  private int top = 0;
  private int right = 512;

  ///
  this(string path, int size)
  {
    int error = FT_New_Face(
      ftlibrary,
      toStringz(path),
      0,
      &fontface
    );

    if(error != 0)
      throw new Exception("Failed to load font: " ~ path);

    error = FT_Set_Char_Size(
      fontface,
      0, size * 64,
      0, 0
    );

    if(error != 0)
      throw new Exception("Failed to set size, using a fixed-sized font?");

    this._texture = new Texture(512, 512);
    this.lineHeight = fontface.size.metrics.height / 64;
    this.ascentLine = cast(int) fontface.size.metrics.ascender / 64;
    this.descentLine = cast(int) fontface.size.metrics.descender / 64;
    this.hasKerning = FT_HAS_KERNING(fontface);
    this.size = size;

    // preload the glyphs for 0-9
    foreach(int i; 0 .. 9)
      loadGlyph(48 + i);
  }

  @property Texture texture()
  {
    return _texture;
  }

  ///
  bool hasGlyph(int character)
  {
    uint glyphIndex = FT_Get_Char_Index(fontface, character);

    return glyphIndex != 0;
  }

  ///
  Glyph getGlyph(int character)
  {
    // return early if the character was already generated
    if(character in glyphs)
      return glyphs[character];
    return loadGlyph(character);
  }

  ///
  Vector2 getKerning(int leftChar, int rightChar)
  {
    if(!hasKerning)
      return Vector2();

    uint leftIndex = FT_Get_Char_Index(fontface, leftChar);
    uint rightIndex = FT_Get_Char_Index(fontface, rightChar);

    FT_Vector kerning;

    int err = FT_Get_Kerning(
      fontface,
      leftChar,
      rightChar,
      FT_Kerning_Mode.FT_KERNING_DEFAULT,
      &kerning
    );

    return Vector2(kerning.x / 64, kerning.y / 64);
  }

  ///
  Vector2 measureString(string text)
  {
    Vector2 position;
    float width = 0;
    float height = 0;

    foreach(char c; text)
    {
      if(!hasGlyph(c))
        continue;

      const Glyph glyph = getGlyph(c);

      // get the bottom of the glyph
      const float bottom = position.y + glyph.offset.y - glyph.height;

      // update the height if the inverted value of bottom is larger
      if(-bottom > height)
        height = -bottom;

      // update the width
      width = position.x + glyph.width;

      // update the position
      position += glyph.advance;
    }

    return Vector2(width, height);
  }

  private Glyph loadGlyph(int character)
  {
    // character was not previously loaded, time to generate it

    uint glyphIndex = FT_Get_Char_Index(fontface, character);

    int error = FT_Load_Glyph(
      fontface,
      glyphIndex,
      FT_LOAD_DEFAULT
    );

    if(error != 0)
      throw new Exception(
        "Could not find '" ~ to!string(character) ~ "' in this font, use hasGlyph to check for this"
      );

    FT_GlyphSlot slot = fontface.glyph;

    Glyph glyph;
    glyph.code = character;
    glyph.width = cast(int) (slot.metrics.width / 64);
    glyph.height = cast(int) (slot.metrics.height / 64);
    glyph.offset = Vector2(slot.bitmap_left, slot.bitmap_top - size);
    glyph.advance = Vector2(slot.advance.x / 64, slot.advance.y / 64);

    // get the clip from stamping the glyph
    glyph.clip = stampGlyph(glyph, slot);

    glyphs[character] = glyph;

    return glyph;
  }

  // returns the clip
  private Rect stampGlyph(Glyph glyph, FT_GlyphSlot slot)
  {
    optimizeTexture(glyph);
    moveStamper(glyph);

    ubyte[] data = getBitmap(slot);

    _texture.update(data, left, _texture.height - top - glyph.height, glyph.width, glyph.height);

    return Rect(left, top, glyph.width, glyph.height);
  }

  // optimizes the texture to be able to support every glyph
  // assures that the texture's size will be a power of two
  private void optimizeTexture(Glyph glyph)
  {
    largestGlyphLength = max(largestGlyphLength, glyph.width, glyph.height);
    int glyphCount = cast(int) glyphs.length + 1;

    int combinedLength = largestGlyphLength * glyphCount;
    int size = cast(int) sqrt(cast(float) combinedLength);

    int powerOfTwo = cast(int) ceil(log2(size));

    size = 2 ^^ powerOfTwo;

    if(size > _texture.width)
      resizeTexture(size);
  }

  // custom resize function, replaces old data at the top left
  // Texture.resize places it at the bottom left (0,0)
  private void resizeTexture(int size)
  {
    ubyte[] data = _texture.getData();
    int oldWidth = _texture.width;
    int oldHeight = _texture.height;

    _texture.recreate(null, size, size);
    _texture.update(data, 0, _texture.height - oldHeight, oldWidth, oldHeight);
  }

  private void moveStamper(Glyph glyph)
  {
    left += largestGlyphLength;

    // past right edge, move down a row
    if(left + glyph.width > right) {
      left = marginLeft;
      top += largestGlyphLength;
    }

    // past bottom, texture was resized
    if(top + glyph.height > _texture.height) {
      left = right;
      top = 0;
      right = _texture.width;
    }
  }

  private ubyte[] getBitmap(FT_GlyphSlot slot)
  {
    if(slot.format != FT_GLYPH_FORMAT_BITMAP)
      FT_Render_Glyph(slot, FT_RENDER_MODE_NORMAL);

    switch(slot.bitmap.pixel_mode)
    {
      case FT_PIXEL_MODE_MONO:
        return convertMonoBitmap(slot);
      case FT_PIXEL_MODE_GRAY:
        return convertGrayScaleBitmap(slot);
      default:
        throw new Exception("Bitmap format for rendering glyph is not supported");
    }
  }

  private ubyte[] convertMonoBitmap(FT_GlyphSlot slot)
  {
    ubyte[] data;
    data.length = slot.bitmap.width * slot.bitmap.rows * 4;

    foreach(int row; 0 .. slot.bitmap.rows) {
      foreach(int col; 0 .. slot.bitmap.width) {
        int byteIndex = col / 8 + row * slot.bitmap.pitch;
        int bitIndex = col % 8;
        ubyte bit = (slot.bitmap.buffer[byteIndex] >> (7 - bitIndex)) & 1;
        ubyte color = bit == 1 ? 255 : 0;

        int destinationRow = slot.bitmap.rows - row - 1;
        int idx = (slot.bitmap.width * destinationRow + col) * 4;

        foreach(int i; 0 .. 4) {
          data[idx + i] = color;
        }
      }
    }

    return data;
  }

  private ubyte[] convertGrayScaleBitmap(FT_GlyphSlot slot)
  {
    ubyte[] data;
    data.length = slot.bitmap.width * slot.bitmap.rows * 4;

    foreach(int row; 0 .. slot.bitmap.rows) {
      foreach(int col; 0 .. slot.bitmap.width) {
        int sourceIdx = slot.bitmap.width * row + col;

        int destinationRow = slot.bitmap.rows - row - 1;
        int destinationIdx = (slot.bitmap.width * destinationRow + col) * 4;

        foreach(int i; 0 .. 4) {
          data[destinationIdx + i] = slot.bitmap.buffer[sourceIdx];
        }
      }
    }

    return data;
  }
}