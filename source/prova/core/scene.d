module prova.core.scene;

import derelict.openal.al;
import prova;

///
class Scene
{
  ///
  public Camera camera;
  package(prova) LinkedList!(AudioSource) audioSources;
  package(prova) SpacialMap2D collider2DMap;
  package Game _game;
  package bool isSetup;
  private Entity[] entities;

  ///
  this()
  {
    camera = new Camera();
    collider2DMap = new SpacialMap2D();
    audioSources = new LinkedList!(AudioSource);

    addEntity(camera);
  }

  ///
  final @property Game game()
  {
    if(!_game)
      throw new Exception("Scene is not attached to a game");
    return _game;
  }

  ///
  final @property Input input()
  {
    return game.input;
  }

  ///
  final void addEntity(Entity entity)
  {
    if(entity._scene == this)
      throw new Exception("Entity was already added to the scene");

    entities ~= entity;
    entity._scene = this;

    foreach(Entity child; entity.children)
      if(child.scene != this)
        addEntity(child);

    foreach(AudioSource source; entity.audioSources)
      audioSources.insertBack(source);

    collider2DMap.add(entity.colliders2d);

    if(!entity.isSetup) {
      entity.setup();
      entity.isSetup = true;
    }

    entity.start();
  }

  ///
  final void removeEntity(Entity entity)
  {
    if(entity._scene != this)
      throw new Exception("Entity was not added to the scene");

    disassociateEntity(entity);

    // detach from parent to not be drawn
    if(entity.parent)
      entity.parent.detach(entity);
  }

  package void disassociateEntity(Entity entity)
  {
    foreach(Entity child; entity.children)
      disassociateEntity(entity);

    foreach(AudioSource source; entity.audioSources)
      audioSources.remove(source);

    collider2DMap.remove(entity.colliders2d);

    entities = entities.removeElement(entity);

    entity._scene = null;
  }

  /// Finds the closest entity to this entity
  Entity findClosestEntity(Entity entity)
  {
    return findClosestEntity(entity, 0, false);
  }

  /// Finds the closest entity with the matching tag
  Entity findClosestEntity(Entity entity, int tag)
  {
    return findClosestEntity(entity, tag, true);
  }

  private Entity findClosestEntity(Entity entity, int tag, bool needsTag)
  {
    float closestDistance = -1;
    Entity closestEntity = null;

    foreach(Entity other; entities)
    {
      // make sure we aren't matching with self
      if(other == entity)
        continue;

      // make sure tag matches
      if(needsTag && !other.hasTag(tag))
        continue;

      const float distance = other.position.distanceTo(entity.position);

      if(distance < closestDistance || closestDistance == -1) {
        closestDistance = distance;
        closestEntity = other;
      }
    }

    return closestEntity;
  }

  /// Called when attached to a scene for the first time
  void setup() { }
  /// Called when attached to a scene
  void start() { }

  /// Call super.update() to update entities if overridden
  void update()
  {
    updateEntities();
    updateCollisions();
  }

  /// Called by Scene.update()
  void updateEntities()
  {
    foreach(Entity entity; entities) {
      entity.update();
      entity.position += entity.velocity;
      entity.velocity *= 1 - entity.friction;
    }
  }

  /// Called by Scene.update()
  void updateCollisions()
  {
    collider2DMap.mapColliders();
    collider2DMap.markCollisions();
    collider2DMap.resolveCollisions();
  }

  package void updateAudio()
  {
    Vector3 position = camera.getWorldPosition() / Audio.scale;
    Quaternion rotation = camera.getWorldRotation();

    Vector3[] orientation = [
      rotation * Vector3(0, 0, -1), // forward
      rotation * Vector3(0, 1, 0) // up
    ];

    alListener3f(AL_POSITION, position.x, position.y, position.z);
    alListenerfv(AL_ORIENTATION, cast(float*) orientation.ptr);

    foreach(AudioSource source; audioSources)
      source.update();
  }

  /**
   * All draw operations performed here will be affected by the camera
   *
   * Call super.draw(renderTarget) to render entities if overridden
   */
  void draw(RenderTarget renderTarget)
  {
    import std.algorithm : filter, sort;
    import std.array : array;

    const auto sortDelegate = camera.getSortDelegate();

    auto sortedEntities =
        entities
          .filter!(e => !is(e.parent))
          .array
          .sort!(sortDelegate);

    foreach(Entity entity; sortedEntities) {
      entity.draw(renderTarget, entity.getLocalTransformMatrix());
    }
  }

  /**
   * All draw operations here will be affected by a static orthographic perspective
   *
   * Origin is moved to the bottom left of the window
   */
  void drawStatic(RenderTarget renderTarget) { }
}
