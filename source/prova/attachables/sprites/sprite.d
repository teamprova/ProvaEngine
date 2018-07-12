module prova.attachables.sprites.sprite;

import prova.assets;
import prova.attachables;
import prova.graphics;
import prova.math;

///
class Sprite : Renderable
{
  ///
  Texture texture;
  ///
  Rect clip;
  /// Defaults to the center of the sprite
  Vector2 origin;
  ///
  Color tint = Color(1, 1, 1, 1);

  ///
  this()
  { }

  ///
  this(string sheetpath)
  {
    Texture texture = new Texture(sheetpath);
    this(texture);
  }

  ///
  this(Texture texture)
  {
    this.texture = texture;

    clip.width = texture.width;
    clip.height = texture.height;
  }

  void draw(RenderTarget renderTarget, Matrix transform)
  {
    renderTarget.drawSprite(this, transform);
  }
}
