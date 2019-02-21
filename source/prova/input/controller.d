module prova.input.controller;

import derelict.sdl2.sdl,
       prova.math,
       std.conv;

///
enum ThumbStick { LEFT, RIGHT }

///
enum ControllerButton {
  A, B, X, Y, BACK, GUIDE, START,
  LEFT_STICK, RIGHT_STICK, BUMPER_LEFT, BUMPER_RIGHT,
  DPAD_UP, DPAD_DOWN, DPAD_LEFT, DPAD_RIGHT,
  // simulated buttons
  TRIGGER_LEFT, TRIGGER_RIGHT
}

///
class Controller
{
  ///
  float deadzone = .15;
  private SDL_GameController* handle;
  private int[18] oldButtonState;
  private int[18] buttonState;
  private int _id;

  package this(int index)
  {
    _id = index;
    handle = SDL_GameControllerOpen(index);
    
    foreach(i; 0 .. 17) {
      oldButtonState[i] = false;
      buttonState[i] = false;
    }
  }

  ///
  @property int id()
  {
    return _id;
  }

  ///
  bool isConnected()
  {
    return cast(bool) SDL_GameControllerGetAttached(handle);
  }

  package void update()
  {
    foreach(i; 0 .. 17) {
      oldButtonState[i] = buttonState[i];
      buttonState[i] = getButtonState(cast(ControllerButton) i);
    }
  }

  private bool getButtonState(ControllerButton button)
  {
    if(button == ControllerButton.TRIGGER_LEFT || button == ControllerButton.TRIGGER_RIGHT)
      return getTrigger(button) > .3;
    return cast(bool) SDL_GameControllerGetButton(handle, cast(SDL_GameControllerButton) button);
  }

  ///
  bool isButtonDown(ControllerButton button)
  {
    return cast(bool) buttonState[cast(int) button];
  }

  ///
  bool isButtonUp(ControllerButton button)
  {
    return !buttonState[cast(int) button];
  }

  ///
  bool buttonJustPressed(ControllerButton button)
  {
    return buttonState[cast(int) button] && !oldButtonState[cast(int) button];
  }

  ///
  Vector2 getStick(ThumbStick stick)
  {
    int xAxis = SDL_CONTROLLER_AXIS_LEFTX;

    if(stick == ThumbStick.RIGHT)
      xAxis = SDL_CONTROLLER_AXIS_RIGHTX;
    
    Vector2 displacement = Vector2(getAxis(xAxis), -getAxis(xAxis + 1));

    if(displacement.getMagnitude() <= deadzone)
      return Vector2();
    else
      return displacement;
  }

  ///
  float getTrigger(ControllerButton button)
  {
    if(button == ControllerButton.TRIGGER_LEFT)
      return getAxis(SDL_CONTROLLER_AXIS_TRIGGERLEFT);
    if(button == ControllerButton.TRIGGER_RIGHT)
      return getAxis(SDL_CONTROLLER_AXIS_TRIGGERRIGHT);

    throw new Error(to!string(button) ~ " is not a trigger");
  }

  private float getAxis(int axis)
  {
    return SDL_GameControllerGetAxis(handle, cast(SDL_GameControllerAxis) axis) / cast(float) 32767;
  }

  ~this()
  {
    SDL_GameControllerClose(handle);
  }
}
