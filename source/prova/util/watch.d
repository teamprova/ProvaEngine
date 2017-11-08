module prova.util.watch;

import derelict.sdl2.sdl;

/**
 * Class used for measuring time
 */
class Watch
{
  private bool running = false;
  private int startTime = 0;
  private int timeStoredBeforeLastStop = 0;

  /**
   * Starts or resumes the watch
   */
  void start()
  {
    running = true;
    
    // reset
    if(startTime == 0) {
      timeStoredBeforeLastStop = 0;
      startTime = SDL_GetTicks();
    }
  }

  /**
   * Pauses the watch
   */
  void pause()
  {
    timeStoredBeforeLastStop = getElapsedMilliseconds();
    running = false;
  }

  /**
   * Stops timing and resets
   */
  void reset()
  {
    startTime = 0;
    running = false;
  }

  /**
   * Resets and starts again
   */
  void restart()
  {
    startTime = 0;
    
    start();
  }

  // we currently only track using milliseconds so,
  // maybe this should be renamed?
  int getElapsedMilliseconds()
  {
    if(startTime == 0)
      throw new Exception("Watch never started");
    
    return SDL_GetTicks() - startTime + timeStoredBeforeLastStop;
  }

  /**
   * Returns the state of the watch
   */
  bool isRunning()
  {
    return running;
  }
}