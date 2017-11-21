module prova.core.scene;

import derelict.openal.al,
       prova,
       std.algorithm,
       std.math;

///
class Scene
{
  ///
  public Camera camera;
  package LinkedList!(Audio) audioSources;
  package SpacialMap2D collider2DMap;
  package Game _game;
  package bool isSetup;
  private LinkedList!(Entity) entities;
  private bool debugEnabled;

  ///
  this()
  {
    camera = new Camera();
    collider2DMap = new SpacialMap2D();
    entities = new LinkedList!(Entity);
    audioSources = new LinkedList!(Audio);
  }

  ///
  @property Game game()
  {
    return _game;
  }

  ///
  @property Input input()
  {
    return _game.input;
  }

  ///
  void enableDebug()
  {
    debugEnabled = true;
  }

  ///
  void disableDebug()
  {
    debugEnabled = false;
  }

  ///
  bool isDebugEnabled()
  {
    return debugEnabled;
  }

  ///
  Entity[] getEntities()
  {
    Entity[] clonedArray;
    clonedArray.length = entities.length;
    int i = 0;

    foreach(Node!Entity node; entities)
      clonedArray[i++] = node.getValue();

    return clonedArray;
  }

  ///
  void addEntity(Entity entity)
  {
    entities.insertBack(entity);
    entity._scene = this;

    foreach(Audio source; entity.audioSources)
      audioSources.insertBack(source);

    collider2DMap.add(entity.colliders2d);

    if(!entity.isSetup) {
      entity.setup();
      entity.isSetup = true;
    }

    entity.start();
  }

  ///
  void removeEntity(Entity entity)
  {
    entities.remove(entity);

    if(entity._scene == this)
      entity._scene = null;

    foreach(Audio source; entity.audioSources)
      audioSources.remove(source);

    collider2DMap.remove(entity.colliders2d);
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
    Quaternion rotation = Quaternion.fromEuler(camera.rotation);

    Vector3 position = camera.position / Audio.scale;
    Vector3[] orientation = [
      rotation * Vector3(0, 0, -1), // forward
      rotation * Vector3(0, 1, 0) // up
    ];

    alListener3f(AL_POSITION, position.x, position.y, position.z);
    alListenerfv(AL_ORIENTATION, cast(float*) orientation.ptr);

    foreach(Audio source; audioSources)
      source.update();
  }

  /**
   * All draw operations performed here will be affected by the camera
   *
   * Call super.draw(renderTarget) to render entities if overridden
   */
  void draw(RenderTarget renderTarget)
  {
    Entity[][float] distanceMappedEntities;

    foreach(Entity entity; entities)
    {
      float distance;

      if(camera.sortingMethod == SortingMethod.Distance)
        distance = entity.position.distanceTo(camera.position);
      else
        distance = camera.position.z - entity.position.z;
      
      distanceMappedEntities[distance] ~= entity;
    }

    foreach_reverse(float key; sort(distanceMappedEntities.keys))
      foreach(Entity entity; distanceMappedEntities[key])
        entity.draw(renderTarget);

    if(debugEnabled)
      collider2DMap.draw(renderTarget);
  }

  /**
   * All draw operations here will be affected by a static orthographic perspective
   *
   * Origin is moved to the bottom left of the window
   */
  void drawStatic(RenderTarget renderTarget) { }
}