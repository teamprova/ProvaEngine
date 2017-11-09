module prova.input.input;

import core.stdc.string,
       derelict.sdl2.sdl,
       prova.input,
       prova.math;

///
class Input
{
  private Vector2 mousePosition;
  private Controller[int] controllers;
  private bool[] keystate;
  private bool[] oldKeystate;

  package(prova) this()
  {
    updateKeystate();
    oldKeystate = keystate;
  }

  package(prova) void update()
  {
    // update controller state
    foreach(Controller controller; controllers)
      controller.update();

    // update keystate
    oldKeystate = keystate;
    updateKeystate();

    // update mouse state
    int x, y;
    SDL_GetMouseState(&x, &y);

    mousePosition.x = x;
    mousePosition.y = y;
  }

  private void updateKeystate()
  {
    int keystateLength;
    const ubyte* SDLKeystate = SDL_GetKeyboardState(&keystateLength);

    keystate = [];
    keystate.length = keystateLength;

    (cast(ubyte*)keystate)[0 .. keystateLength][] = SDLKeystate[0 .. keystateLength];
  }

  /// 
  Controller getController(int index)
  {
    // controller not found then add it to our list
    // of updated controllers
    if(!(index in controllers))
      controllers[index] = new Controller(index);

    return controllers[index];
  }

  ///
  bool isKeyDown(Key key)
  {
    return keystate[cast(int) key];
  }

  ///
  bool isKeyUp(Key key)
  {
    return !keystate[cast(int) key];
  }

  /// Returns true if the key is pressed and was not pressed in the last tick
  bool keyJustPressed(Key key)
  {
    return !oldKeystate[cast(int) key] && keystate[cast(int) key];
  }

  /// Uses the WASD format, returns a normalized vector
  Vector2 simulateStick(Key up, Key left, Key down, Key right)
  {
    Vector2 vector = Vector2(
      isKeyDown(right) - isKeyDown(left),
      isKeyDown(up) - isKeyDown(down)
    );

    return vector.getNormalized();
  }

  ///
  bool isMouseButtonDown(int mouseButton)
  {
    return cast(bool) SDL_BUTTON(cast(ubyte) mouseButton);
  }

  ///
  bool isMouseButtonUp(int mouseButton)
  {
    return !SDL_BUTTON(cast(ubyte) mouseButton);
  }

  ///
  Vector2 getMousePosition()
  {
    return mousePosition;
  }
}