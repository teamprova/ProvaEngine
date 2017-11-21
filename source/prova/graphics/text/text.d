module prova.graphics.text.text;

import prova.core,
       prova.graphics,
       prova.math;

///
enum TextAlign { LEFT, CENTER, RIGHT }
///
enum TextBaseline { MIDDLE, TOP, BOTTOM }

///
class Text
{
  ///
  Vector3 position;
  ///
  Color color;
  ///
  float scale;
  ///
  TextAlign textAlign;
  ///
  TextBaseline textBaseline;
  private Sprite[] sprites;
  private Glyph[] glyphs;
  private Font font;
  private string _text;

  ///
  this(string text, Font font)
  {
    this.font = font;
    this.text = text;
    scale = 1;
  }

  ///
  @property string text()
  {
    return _text;
  }

  ///
  @property void text(string text)
  {
    sprites.length = text.length;
    glyphs.length = text.length;

    foreach(i; 0 .. text.length)
    {
      const int c = text[i];

      if(!font.hasGlyph(c))
        continue;

      const Glyph glyph = font.getGlyph(c);

      Sprite sprite = new Sprite();
      sprite.texture = font.texture;
      sprite.clip = glyph.clip;
      sprite.width = glyph.width;
      sprite.height = glyph.height;

      sprites[i] = sprite;
      glyphs[i] = glyph;
    }

    _text = text;
  }

  ///
  Vector2 getSize()
  {
    return font.measureString(_text, scale);
  }

  ///
  Rect getBounds()
  {
    Vector3 start = position + getOffset();
    Vector2 size = getSize();

    return Rect(start.x, start.y + font.maxHeight * scale, size.x, size.y);
  }

  ///
  void draw(RenderTarget renderTarget)
  {
    Vector3 pos = position + getOffset();

    foreach(i; 0 .. _text.length)
    {
      Glyph glyph = glyphs[i];
      Sprite sprite = sprites[i];

      sprite.tint = color;
      sprite.scale.x = scale;
      sprite.scale.y = scale;

      renderTarget.drawSprite(sprite, pos + glyph.offset * scale);

      pos += glyph.shift * scale;
    }
  }

  private Vector2 getOffset()
  {
    const Vector2 size = font.measureString(_text, scale);
    Vector2 offset;

    if(textAlign == TextAlign.CENTER)
      offset.x -= size.x / 2;
    else if(textAlign == TextAlign.RIGHT)
      offset.x -= size.x;

    if(textBaseline == TextBaseline.TOP)
      offset.y -= font.maxHeight * scale;
    else if(textBaseline == TextBaseline.MIDDLE)
      offset.y -= size.y / 2;

    return offset;
  }
}