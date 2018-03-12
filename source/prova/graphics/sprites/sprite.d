module prova.graphics.sprites.sprite;

import prova.graphics,
       prova.math;

///
class Sprite
{
  ///
  Texture texture;
  ///
  int angle = 0;
  ///
  Rect clip;
  /// Defaults to the center of the sprite
  Vector2 origin;
  ///
  Vector2 scale = Vector2(1, 1);
  ///
  Color tint = Color(1, 1, 1, 1);

  ///
  this()
  { }

  ///
  this(string sheetpath)
  {
    Texture texture = Texture.fetch(sheetpath);
    this(texture);
  }

  ///
  this(Texture texture)
  {
    this.texture = texture;

    clip.width = texture.width;
    clip.height = texture.height;
  }
}