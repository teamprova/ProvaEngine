module prova.graphics.sprites.animatedsprite;

import derelict.sdl2.sdl,
       prova.graphics,
       prova.math,
       std.math;

private class Animation
{
  int id;
  int frameCount;
  int row;
  float frameDuration;
  float duration;
}

///
class AnimatedSprite : Sprite
{
  private bool looping;
  private uint startTime;
  private Animation[int] animations;
  private Animation currentAnimation;

  ///
  this(string sheetpath, int width, int height)
  {
    super(sheetpath);
    this.width = width;
    this.height = height;
    clip.width = width / cast(float) texture.width;
    clip.height = height / cast(float) texture.height;
  }

  ///
  void createAnimation(int id, int row, int frameCount, float frameDuration)
  {
    Animation animation = new Animation();
    animation.id = id;
    animation.row = row;
    animation.frameCount = frameCount;
    animation.frameDuration = frameDuration;
    animation.duration = frameCount * frameDuration;

    animations[id] = animation;
  }

  ///
  void playAnimation(int id, bool loop)
  {
    startTime = SDL_GetTicks();
    looping = loop;
    
    currentAnimation = animations[id];
  }

  ///
  bool isAnimationFinished()
  {
    return getCurrentTime() > currentAnimation.duration;
  }

  ///
  bool isLooping()
  {
    return looping;
  }

  ///
  float getCurrentTime()
  {
    float currentTime = SDL_GetTicks() - startTime;
    currentTime /= 1000.0f;

    if(looping)
      currentTime = fmod(currentTime, currentAnimation.duration);

    return currentTime;
  }

  ///
  int getCurrentFrame()
  {
    if(!currentAnimation)
      return 0;
    
    int frame = cast(int)(getCurrentTime() / currentAnimation.frameDuration);

    if(isAnimationFinished())
      frame = cast(int)(currentAnimation.duration / currentAnimation.frameDuration - 1);
    
    return frame;
  }

  ///
  int getCurrentAnimation()
  {
    if(!currentAnimation)
      return -1;

    return currentAnimation.id;
  }

  /// Usually unnecessary to call directly
  void update()
  {
    if(!currentAnimation)
      return;

    clip.left = clip.width * getCurrentFrame();
    clip.top = 1 - clip.height * (currentAnimation.row + 1);
  }
}