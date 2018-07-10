module prova.assets.sprites.gridspritesheet;

import prova.assets;

/// Uses a grid of sprites
class GridSpriteSheet : SpriteSheet
{
  /**
   * Params:
   *   path = Path of the image file
   *   defaultDuration = Default duration for SpriteFrames
   *   cols = Columns
   *   rows = Rows
   */
  this(string path, int cols, int rows, float defaultDuration)
  {
    texture = new Texture(path);

    float clipWidth = texture.width / cols;
    float clipHeight = texture.height / rows;

    frames.reserve(cols * rows);

    foreach(int y; 0 .. rows) {
      foreach(int x; 0 .. cols) {
        SpriteFrame frame;
        frame.clip.left = clipWidth * x;
        frame.clip.top = clipHeight * y;
        frame.clip.width = clipWidth;
        frame.clip.height = clipHeight;
        frame.duration = defaultDuration;

        frames ~= frame;
      }
    }
  }

  ///
  void createAnimation(string name, int start, int count)
  {
    SpriteFrame[] frames = this.frames[start .. start + count];

    animations[name] = new SpriteAnimation(name, frames);
  }
}
