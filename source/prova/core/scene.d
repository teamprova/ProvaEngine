module prova.core.scene;

import prova.collision,
       prova.core,
       prova.graphics,
       prova.input,
       prova.util,
       std.algorithm;

///
class Scene
{
  ///
  public Camera camera;
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
    entityUpdate();
    collider2DUpdate();
  }

  /// Called by Scene.update()
  void collider2DUpdate()
  {
    collider2DMap.mapColliders();
    collider2DMap.markCollisions();
    collider2DMap.resolveCollisions();
  }

  /// Called by Scene.update()
  void entityUpdate()
  {
    foreach(Entity entity; entities) {
      entity.update();
      entity.position += entity.velocity;
      entity.velocity *= 1 - entity.friction;
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
      collider2DMap.draw(_game.screen);
  }

  /**
   * All draw operations here will be affected by a static orthographic perspective
   *
   * Origin is moved to the bottom left of the window
   */
  void drawStatic(Screen screen) { }
}