module prova.graphics.text.text;

import prova.core,
       prova.graphics,
       prova.math;

///
enum TextAlign { LEFT, CENTER, RIGHT }
///
enum TextBaseline { TOP, MIDDLE, BOTTOM, HANGING, ALPHABETIC }

///
class Text : Entity
{
  ///
  Color color;
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
      sprite.origin = Vector2(-glyph.clip.width / 2, glyph.clip.height / 2);

      sprites[i] = sprite;
      glyphs[i] = glyph;
    }

    _text = text;
  }

  ///
  Vector2 getSize()
  {
    Vector2 size = font.measureString(_text);
    Vector3 scale = getWorldScale();

    return Vector2(size.x * scale.x, size.y * scale.y);
  }

  ///
  override void draw(RenderTarget renderTarget, Matrix transform)
  {
    Matrix glyphTransform = Matrix.identity;
    glyphTransform = glyphTransform.translate(getOffset());

    foreach(i; 0 .. _text.length)
    {
      Glyph glyph = glyphs[i];
      Sprite sprite = sprites[i];

      sprite.tint = color;

      Vector2 offset = glyph.offset;

      if(i > 0)
        offset += font.getKerning(_text[i - 1], _text[i]);

      renderTarget.drawSprite(
        sprite,
        transform * glyphTransform.translate(offset)
      );

      glyphTransform = glyphTransform.translate(glyph.advance);
    }
  }

  private Vector2 getOffset()
  {
    const Vector2 size = font.measureString(_text);
    Vector2 offset;

    if(textAlign == TextAlign.CENTER)
      offset.x -= size.x / 2;
    else if(textAlign == TextAlign.RIGHT)
      offset.x -= size.x;

    final switch(textBaseline)
    {
      case TextBaseline.TOP:
        break;
      case TextBaseline.MIDDLE:
        offset.y += (font.ascentLine - font.descentLine) * scale.y / 2;
        break;
      case TextBaseline.BOTTOM:
        offset.y += (font.size - font.descentLine) * scale.y;
        break;
      case TextBaseline.HANGING:
        offset.y += (font.ascentLine - font.size) * scale.y;
        break;
      case TextBaseline.ALPHABETIC:
        offset.y += font.size * scale.y;
        break;
    }

    return offset;
  }
}