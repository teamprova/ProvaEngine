module prova.audio.audiosource;

import derelict.openal.al;
import prova.audio;
import prova.core;
import prova.math;

/// 
class AudioSource
{
  private uint sourceId;
  private AudioClip audioClip;
  private Entity _entity;
  private bool _looping = false;
  private float _volume = 1;
  private float _pitch = 1;

  /// Limited to Ogg files for now
  this(AudioClip audioClip)
  {
    this.audioClip = audioClip;

    alGenSources(1, &sourceId);
    alSourcei(sourceId, AL_BUFFER, audioClip.bufferId);
  }

  ///
  @property Entity entity()
  {
    return _entity;
  }

  ///
  @property void entity(Entity entity)
  {
    _entity = entity;
  }

  ///
  @property uint channels()
  {
    return audioClip.channels;
  }

  ///
  @property float volume()
  {
    return _volume;
  }

  ///
  @property void volume(float value)
  {
    _volume = value;
    alSourcef(sourceId, AL_GAIN, value);
  }

  ///
  @property float pitch()
  {
    return _pitch;
  }

  ///
  @property void pitch(float value)
  {
    _pitch = value;
    alSourcef(sourceId, AL_PITCH, value);
  }

  ///
  @property bool isPlaying()
  {
    ALenum status;
    alGetSourcei(sourceId, AL_SOURCE_STATE, &status);

    return status == AL_PLAYING;
  }

  ///
  @property bool looping()
  {
    return _looping;
  }

  ///
  void play(bool loop = false)
  {
    if(isPlaying())
      stop();

    _looping = loop;
    alSourcei(sourceId, AL_LOOPING, loop);

    alSourceRewind(sourceId);
    alSourcePlay(sourceId);
  }

  ///
  void stop()
  {
    alSourceStop(sourceId);
  }

  ///
  void pause()
  {
    alSourcePause(sourceId);
  }

  ///
  void resume()
  {
    alSourcePlay(sourceId);
  }

  package(prova) void update()
  {
    if(!entity)
      return;

    Vector3 position = entity.getWorldPosition();
    Vector3 velocity = entity.getWorldRotation() * entity.velocity;

    position /= Audio.scale;
    velocity /= Audio.scale;

    alSource3f(sourceId, AL_POSITION, position.x, position.y, position.z);
    alSource3f(sourceId, AL_VELOCITY, velocity.x, velocity.y, velocity.z);
  }

  ~this()
  {
    if(isPlaying)
      stop();

    alDeleteSources(1, &sourceId);
  }
}
