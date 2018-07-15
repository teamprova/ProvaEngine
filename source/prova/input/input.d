module prova.input.input;

import core.stdc.string;
import derelict.sdl2.sdl;
import prova.core;
import prova.input;
import prova.math;

///
class Input
{
  private Game game;
  private Vector2 mousePosition;
  private Controller[int] controllers;
  private bool[] keystate;
  private bool[] oldKeystate;
  private bool[Key] repeatedKeyMap;
  private bool[] buttonState;
  private bool[] oldButtonState;
  private string text = "";

  package(prova) this(Game game)
  {
    this.game = game;

    update();
    oldKeystate = keystate;
    oldButtonState = buttonState;
  }

  package(prova) void reset()
  {
    repeatedKeyMap.clear();
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
    uint mouseState = SDL_GetMouseState(&x, &y);

    // update button state
    oldButtonState = buttonState;
    updateButtonState(mouseState);

    mousePosition.x = -1f + x / (game.screen.width * .5f);
    mousePosition.y = 1f - y / (game.screen.height * .5f);
  }

  private void updateKeystate()
  {
    int keystateLength;
    const ubyte* SDLKeystate = SDL_GetKeyboardState(&keystateLength);

    keystate = [];
    keystate.length = keystateLength;

    (cast(ubyte*)keystate)[0 .. keystateLength][] = SDLKeystate[0 .. keystateLength];
  }

  private void updateButtonState(uint mouseState)
  {
    buttonState = [];
    buttonState.length = 5;

    foreach(i; 0 .. 5) {
      ubyte button = SDL_BUTTON(cast(ubyte) (i + 1));
      buttonState[i] = cast(bool) (mouseState & button);
    }
  }

  package(prova) void setKeyDown(SDL_Keycode keycode) {
    Key key = cast(Key) SDL_GetScancodeFromKey(keycode);

    if(isKeyDown(key)) {
      repeatedKeyMap[key] = true;
    }
  }

  package(prova) void updateTextInput(string text)
  {
    const bool enteredNewLine =
      keyJustPressed(Key.KP_ENTER) || isKeyRepeated(Key.KP_ENTER) ||
      keyJustPressed(Key.RETURN) || isKeyRepeated(Key.RETURN);

    if(enteredNewLine) {
      text ~= '\n';
    }

    this.text = text;
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

  /**
   * Returns true if a key down event was received before the key was released
   * Useful for creating text inputs
   */
  bool isKeyRepeated(Key key)
  {
    return (key in repeatedKeyMap) != null;
  }

  ///
  bool isMouseButtonDown(MouseButton button)
  {
    return buttonState[button];
  }

  ///
  bool isMouseButtonUp(MouseButton button)
  {
    return !buttonState[button];
  }

  ///
  bool mouseButtonClicked(MouseButton button)
  {
    return oldButtonState[button] && !buttonState[button];
  }

  ///
  Vector2 getMousePosition()
  {
    return mousePosition;
  }

  ///
  void startTextInput()
  {
    SDL_StartTextInput();
  }

  ///
  void stopTextInput()
  {
    SDL_StopTextInput();
    text = "";
  }

  ///
  string getTextInput()
  {
    return text;
  }
}
