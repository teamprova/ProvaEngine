module prova.graphics.sprite;

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
  int width;
  ///
  int height;
  ///
  Rect clip = Rect(0, 0, 1, 1);
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
    this(new Texture(sheetpath));
  }

  ///
  this(Texture texture)
  {
    this.texture = texture;
    width = texture.width;
    height = texture.height;
    origin.x = width / 2;
    origin.y = height / 2;
  }
}