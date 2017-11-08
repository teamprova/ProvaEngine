module prova.graphics.font;

import prova.graphics,
       prova.math,
       std.file,
       std.math;

///
struct Glyph
{
  ///
  int encoding;
  ///
  int width;
  ///
  int height;
  /// clip to crop the glyph from the font texture
  Rect clip;
  /// offset to render the current glyph
  Vector2 offset;
  /// offset to render the next glyph
  Vector2 shift;
}

///
abstract class Font
{
  ///
  Texture texture;
  protected Glyph[int] glyphs;
  protected int _maxHeight;

  ///
  @property int maxHeight()
  {
    return _maxHeight;
  }

  ///
  bool hasGlyph(int character)
  {
    return !!(character in glyphs);
  }

  ///
  Glyph getGlyph(int character)
  {
    return glyphs[character];
  }

  ///
  Vector2 measureString(string text, float scale)
  {
    Vector2 position;
    float width = 0;
    float height = 0;

    foreach(char c; text)
    {
      if(!hasGlyph(c))
        continue;

      const Glyph glyph = glyphs[c];

      // get the top of the glyph
      const float top = position.y + glyph.offset.y + glyph.height;

      // update the height if the top is higher
      if(top > height)
        height = top;
      
      // update the width
      width = position.x + glyph.width;

      // update the position
      position += glyph.shift;
    }

    return Vector2(width, height) * scale;
  }
}