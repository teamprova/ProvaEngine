module prova.core.game;

import derelict.sdl2.sdl;
import prova;
import prova.init;
import std.string;

/// Core class that manages input, scenes, and the window
final class Game
{
  /// The FPS the gameloop will attempt to maintain
  int targetFPS = 60;
  package(prova) SDL_Window* window;
  private Screen _screen;
  private Input _input;
  private Scene _activeScene;
  private AssetManager assetManager; 
  private bool _isFullscreen = false;
  private bool running = false;

  /// Sets up the window
  this(string title, int width, int height)
  {
    init();

    auto context = new GraphicsContext();

    window = SDL_CreateWindow(
      toStringz(title),
      SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
      width, height,
      SDL_WINDOW_OPENGL
    );

    context.setWindow(window);

    _screen = new Screen(this, context, width, height);
    _input = new Input(this);
    assetManager = new AssetManager();
  }

  ///
  @property Scene activeScene()
  {
    return _activeScene;
  }

  ///
  @property Screen screen()
  {
    return _screen;
  }

  ///
  @property Input input()
  {
    return _input;
  }

  ///
  @property AssetManager assets()
  {
    return assetManager;
  }

  ///
  @property bool isFullscreen()
  {
    return _isFullscreen;
  }

  ///
  void setTitle(string title)
  {
    SDL_SetWindowTitle(window, toStringz(title));
  }

  /// Fullscreen windowed
  void toggleFullscreen()
  {
    _isFullscreen = !_isFullscreen;

    SDL_SetWindowFullscreen(
      window,
      _isFullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0
    );
  }

  /// Allows/Prevents window resizing
  void setResizable(bool resizable)
  {
    SDL_SetWindowResizable(window, cast(SDL_bool) resizable);
  }

  /**
   * Changes the active scene
   *
   * use Game.start(Scene) to set the initial scene
   */
  void swapScene(Scene scene)
  {
    assert(running, "The initial scene should be set through Game.start(Scene)");

    setScene(scene);
  }

  private void setScene(Scene scene)
  {
    _activeScene = scene;
    _activeScene._game = this;

    if(!_activeScene.isSetup)
      _activeScene.setup();
    _activeScene.start();
  }

  /**
   * Starts the game loop and sets the initial scene
   *
   * Lines after this statement will not execute until the loop has stopped
   */
  void start(Scene scene)
  {
    assert(!running, "The game should not already be running");

    running = true;
    setScene(scene);

    loop();

    // cleanup after finishing the final loop
    cleanUp();
  }

  /// Stops the game loop after it finishes a final cycle
  void quit()
  {
    running = false;
  }

  private void loop()
  {
    int lag = 0;
    Watch watch = new Watch();
    watch.start();

    while(running) {
      const int frameDuration = 1000 / targetFPS;
      lag += watch.getElapsedMilliseconds();
      watch.restart();

      while(lag >= frameDuration) {
        update();
        lag -= frameDuration;
      }

      draw(); 

      // give the processor a break if we are ahead of schedule
      const int sleepTime = frameDuration - watch.getElapsedMilliseconds() - lag;

      if(sleepTime > 0)
        SDL_Delay(sleepTime);
    }
  }

  private void update()
  {
    SDL_Event event;
    string inputText = "";

    _input.reset();

    while(SDL_PollEvent(&event) != 0) {
      switch(event.type) {
        case SDL_QUIT:
          quit();
          return;
        case SDL_WINDOWEVENT:
          switch(event.window.event) {
            case SDL_WINDOWEVENT_RESIZED:
              screen.updateResolution(event.window.data1, event.window.data2);
              break;
            default:
              break;
          }
          break;
        case SDL_TEXTINPUT:
          inputText = fromStringz(event.text.text.ptr).idup;
          break;
        case SDL_KEYDOWN:
          _input.setKeyDown(event.key.keysym.sym);
          break;
        default:
          break;
      }
    }

    _input.update();
    _input.updateTextInput(inputText);

    _activeScene.update();
    _activeScene.updateAudio();
  }

  private void draw()
  {
    _screen.prepare();

    _screen.prepareDynamic();
    _activeScene.draw(screen);
    _screen.endDynamic();

    _screen.prepareStatic();
    _activeScene.drawStatic(screen);
    _screen.endStatic();

    _screen.swapBuffer();
  }

  private void cleanUp()
  {
    SDL_DestroyWindow(window);
    finalize();
  }
}
