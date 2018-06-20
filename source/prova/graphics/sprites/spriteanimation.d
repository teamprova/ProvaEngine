module prova.graphics.sprites.spriteanimation;

import prova.graphics;

///
class SpriteAnimation
{
  ///
  string name;
  ///
  SpriteFrame[] frames;

  ///
  this(string name, SpriteFrame[] frames)
  {
    this.name = name;
    this.frames = frames;
  }

  ///
  float getDuration()
  {
    float duration = 0;

    foreach(SpriteFrame frame; frames)
      duration += frame.duration;

    return duration;
  }
}
