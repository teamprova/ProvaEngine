module prova.input.binding;

import prova.input,
       prova.math,
       prova.util;

/// Allows representation of input from multiple sources in a uniform way
class Binding
{
  private Controller controller;
  private Input input;
  private LinkedList!(Key)[int] boundKeyButtons;
  private LinkedList!(ControllerButton)[int] boundControllerButtons;
  private LinkedList!(Key[4])[int] boundKeySticks;
  private LinkedList!(ThumbStick)[int] boundControllerSticks;

  /// Forward of deadzone on Controller
  @property float deadzone()
  {
    return controller.deadzone;
  }

  /// Forward of deadzone on Controller
  @property void deadzone(float deadzone)
  {
    controller.deadzone = deadzone;
  }

  /// Must be called before using any other method
  void bindInput(Input input)
  {
    if(!input)
      throw new Exception("Input is null. Did you bind in a constructor rather than during setup()?");

    this.input = input;
  }

  ///
  void bindController(int index)
  {
    if(!input)
      throw new Exception("Input has not been binded yet");
    
    controller = input.getController(index);
  }

  ///
  void bindButton(int button, Key key)
  {
    if(!(button in boundKeyButtons))
      boundKeyButtons[button] = new LinkedList!(Key);

    boundKeyButtons[button].insertBack(key);
  }

  ///
  void bindButton(int button, ControllerButton controllerButton)
  {
    if(!(button in boundControllerButtons))
      boundControllerButtons[button] = new LinkedList!(ControllerButton);

    boundControllerButtons[button].insertBack(controllerButton);
  }

  /**
   * Simulates a joystick using four keys
   *
   * Uses a WASD format for ordering directions
   */
  void bindStick(int stick, Key up, Key left, Key down, Key right)
  {
    if(!(stick in boundKeySticks))
      boundKeySticks[stick] = new LinkedList!(Key[4]);

    Key[4] simulatedStick = [up, left, down, right];
    boundKeySticks[stick].insertBack(simulatedStick);
  }

  ///
  void bindStick(int stick, ThumbStick joystick)
  {
    if(!(stick in boundControllerSticks))
      boundControllerSticks[stick] = new LinkedList!(ThumbStick);

    boundControllerSticks[stick].insertBack(joystick);
  }

  ///
  bool isButtonDown(int button)
  {
    if(!input)
      throw new Exception("Input has not been binded yet");

    return isKeyDown(button) || isControllerButtonDown(button);
  }

  private bool isKeyDown(int button)
  {
    if(!(button in boundKeyButtons))
      return false;

    // loop through bound keys and return true if just pressed
    LinkedList!Key keyButtons = boundKeyButtons[button];

    foreach(Key keyButton; keyButtons)
      if(input.isKeyDown(keyButton))
        return true;

    return false;
  }

  private bool isControllerButtonDown(int button)
  {
    // do not test controller bindings if the controller isn't set
    // or if there are no buttons bound
    if(!controller || !(button in boundControllerButtons))
      return false;

    // loop through bound buttons and return true if just pressed
    LinkedList!ControllerButton controllerButtons = boundControllerButtons[button];

    foreach(ControllerButton controllerButton; controllerButtons)
      if(controller.isButtonDown(controllerButton))
        return true;

    return false;
  }

  ///
  bool isButtonUp(int button)
  {
    return !isButtonDown(button);
  }

  ///
  bool buttonJustPressed(int button)
  {
    if(!input)
      throw new Exception("Input has not been binded yet");

    return keyJustPressed(button) || controllerButtonJustPressed(button);
  }

  private bool keyJustPressed(int button)
  {
    if(!(button in boundKeyButtons))
      return false;

    // loop through bound keys and return true if just pressed
    LinkedList!Key keyButtons = boundKeyButtons[button];

    foreach(Key keyButton; keyButtons)
      if(input.keyJustPressed(keyButton))
        return true;

    return false;
  }

  private bool controllerButtonJustPressed(int button)
  {
    // do not test controller bindings if the controller isn't set
    // or if there are no buttons bound
    if(!controller || !(button in boundControllerButtons))
      return false;

    // loop through bound buttons and return true if just pressed
    LinkedList!ControllerButton controllerButtons = boundControllerButtons[button];

    foreach(ControllerButton controllerButton; controllerButtons)
      if(controller.buttonJustPressed(controllerButton))
        return true;

    return false;
  }

  ///
  Vector2 getStick(int stick)
  {
    if(!input)
      throw new Exception("Input has not been binded yet");
    
    Vector2 result;
    Vector2 zero;

    result = getSimulatedStick(stick);

    if(result != zero)
      return result;

    result = getJoyStick(stick);

    if(result != zero)
      return result;

    return zero;
  }

  private Vector2 getSimulatedStick(int stick)
  {
    Vector2 zero;

    if(!(stick in boundKeySticks))
      return zero;

    // loop through bound sticks and return only if it does not equal zero
    LinkedList!(Key[4]) keySticks = boundKeySticks[stick];

    foreach(Key[4] keyStick; keySticks) {
      Vector2 vector = input.simulateStick(
        keyStick[0], keyStick[1], keyStick[2], keyStick[3]
      );
      
      if(vector != zero)
        return vector;
    }

    return zero;
  }

  private Vector2 getJoyStick(int stick)
  {
    Vector2 zero;

    // do not test controller bindings if the controller isn't set,
    // or if there are no sticks bound to the controller
    if(!controller || !(stick in boundControllerSticks))
      return zero;

    // loop through bound sticks and return only if it does not equal zero
    LinkedList!ThumbStick thumbsticks = boundControllerSticks[stick];

    foreach(ThumbStick thumbstick; thumbsticks) {
      Vector2 vector = controller.getStick(thumbstick);

      if(vector != zero)
        return vector;
    }

    return zero;
  }
}