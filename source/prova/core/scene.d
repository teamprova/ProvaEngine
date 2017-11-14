module prova.core.scene;

import prova.audio,
       prova.collision,
       prova.core,
       prova.graphics,
       prova.input,
       prova.math,
       prova.util,
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

  /// Called after Scene.update()
  void updateAudio()
  {
    Quaternion rotation = Quaternion.fromEuler(camera.rotation);
    Vector3 earOffset = rotation * Vector3(.26, 0, 0) * Audio.scale;
    Vector3 leftEar = camera.position - earOffset;
    Vector3 rightEar = camera.position + earOffset;

    // .26 * 2
    float earsDistance = .52;
    float audioScaleSquared = Audio.scale ^^ 2;

    foreach(Audio source; audioSources) {
      Vector3 position = source.entity.position;

      float leftSquared = position.distanceToSquared(leftEar) / audioScaleSquared;
      float rightSquared = position.distanceToSquared(rightEar) / audioScaleSquared;
      float leftDistance = sqrt(leftSquared);
      float rightDistance = sqrt(rightSquared);

      float volume = 1 / min(leftSquared, rightSquared);

      source.volume = volume > 1 || volume == 0 ? 1 : volume;
      source.panning = (leftDistance - rightDistance) / earsDistance;
    }
  }

  /**
   * All draw operations performed here will be affected by the camera
   *
   * Call super.draw(screen) to render entities if overridden
   */
  void draw(Screen screen)
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

    foreach(float key; sort(distanceMappedEntities.keys))
      foreach(Entity entity; distanceMappedEntities[key])
        entity.draw(screen);

    if(debugEnabled)
      collider2DMap.draw(screen);
  }

  /**
   * All draw operations here will be affected by a static orthographic perspective
   *
   * Origin is moved to the bottom left of the window
   */
  void drawStatic(Screen screen) { }
}