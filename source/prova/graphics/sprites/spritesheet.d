module prova.graphics.sprites.spritesheet;

import prova.graphics;
import prova.interfaces;

///
class SpriteSheet : Asset
{
  ///
  SpriteAnimation[string] animations;
  ///
  SpriteFrame[] frames;
  ///
  Texture texture;
}
