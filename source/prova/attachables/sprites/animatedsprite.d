module prova.attachables.sprites.animatedsprite;

import derelict.sdl2.sdl;
import prova.assets;
import prova.attachables;
import prova.math;
import std.math;

///
class AnimatedSprite : Sprite
{
  private SpriteAnimation[string] animations;
  private SpriteAnimation currentAnimation;
  private SpriteFrame currentFrame;
  private uint startTime;
  private float frameEndTime;
  private int currentFrameIndex;
  private bool looping;

  ///
  this(SpriteSheet sheet)
  {
    animations = sheet.animations;
    texture = sheet.texture;
  }

  ///
  void playAnimation(string name, bool loop = false)
  { 
    if(!(name in animations))
      throw new Exception("Animation " ~ name ~ " does not exist");

    currentAnimation = animations[name];
    looping = loop;
    reset();

    update();
  }

  ///
  bool isAnimationFinished()
  {
    if(!currentAnimation)
      return true;

    return getCurrentTime() == currentAnimation.getDuration();
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

    float animationDuration = currentAnimation.getDuration();

    if(looping)
      currentTime = fmod(currentTime, animationDuration);
    else if(currentTime > animationDuration)
      currentTime = animationDuration;

    return currentTime;
  }

  /// Returns the index of the current frame within the current animation
  int getCurrentFrame()
  {
    if(!currentAnimation)
      return 0;

    return currentFrameIndex;
  }

  /// Returns the name of the current animation
  string getCurrentAnimation()
  {
    if(!currentAnimation)
      return null;

    return currentAnimation.name;
  }

  /// Usually unnecessary to call directly
  void update()
  {
    if(!currentAnimation)
      return;

    updateCurrentFrame();

    clip = currentFrame.clip;
  }

  private void updateCurrentFrame()
  {
    float currentTime = SDL_GetTicks() - startTime;
    currentTime /= 1000.0f;

    while(currentTime > frameEndTime) {
      if(++currentFrameIndex >= currentAnimation.frames.length) {
        if(looping)
          reset();
        else
          currentFrameIndex -= 1;

        break;
      }

      currentFrame = currentAnimation.frames[currentFrameIndex];
      frameEndTime += currentFrame.duration;
    }
  }

  private void reset()
  {
    currentFrameIndex = 0;
    currentFrame = currentAnimation.frames[0];
    frameEndTime = currentFrame.duration;
    startTime = SDL_GetTicks();
  }
}
