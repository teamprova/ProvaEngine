module prova.assets.text.glyph;

import prova.math;

///
struct Glyph
{
  ///
  int code;
  ///
  int width;
  ///
  int height;
  /// clip to crop the glyph from the font texture
  Rect clip;
  /// offset to render the current glyph
  Vector2 offset;
  /// offset to render the next glyph
  Vector2 advance;
}
