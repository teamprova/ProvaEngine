module prova.util.watch;

import derelict.sdl2.sdl;

/**
 * Class used for measuring time
 */
class Watch
{
  private bool running = false;
  private int startTime = 0;
  private int timeStored = 0;

  /**
   * Returns the state of the watch
   */
  @property bool isRunning()
  {
    return running;
  }

  /**
   * Starts or resumes the watch
   */
  void start()
  {
    if(running)
      timeStored = getElapsedMilliseconds();

    startTime = SDL_GetTicks();
    running = true;
  }

  /**
   * Pauses the watch
   */
  void pause()
  {
    timeStored = getElapsedMilliseconds();
    running = false;
  }

  /**
   * Stops timing and resets
   */
  void reset()
  {
    startTime = 0;
    timeStored = 0;
    running = false;
  }

  /**
   * Resets and starts again
   */
  void restart()
  {
    reset();
    start();
  }

  // we currently only track using milliseconds so,
  // maybe this should be renamed?
  int getElapsedMilliseconds()
  {
    if(startTime == 0)
      throw new Exception("Watch never started");
    
    return SDL_GetTicks() - startTime + timeStored;
  }
}