module prova.audio.audio;

import derelict.openal.al;

///
final abstract class Audio
{
  ///
  static float scale;
  package(prova) static ALCdevice* device;
  package(prova) static ALCcontext* context;
}