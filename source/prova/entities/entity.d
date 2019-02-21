module prova.entities.entity;

import prova;

///
class Entity
{
  ///
  Vector3 position;
  ///
  Quaternion rotation;
  ///
  Vector3 scale = Vector3(1, 1, 1);
  ///
  Vector3 velocity;
  /// Velocity is multiplied by (1 - friction) every tick
  float friction = 0;
  package(prova) bool isSetup = false;
  package(prova) Scene _scene;
  package(prova) Entity[] children;
  package(prova) Collider2D[] colliders2d;
  package(prova) AudioSource[] audioSources;
  private Renderable[] renderables;
  private Entity _parent;
  private int[] tags;

  ///
  final @property Scene scene()
  {
    assert(_scene, "Entity should be attached to a scene");

    return _scene;
  }

  /// Shortcut for scene.game
  final @property Game game()
  {
    return scene.game;
  }

  ///
  final @property Entity parent()
  {
    return _parent;
  }

  package(prova) final @property void parent(Entity parent)
  {
    _parent = parent;
  }

  /// Shortcut for scene.game.input
  final @property Input input()
  {
    return scene.game.input;
  }

  ///
  final void addTag(int tag)
  {
    tags ~= tag;
  }

  ///
  final void removeTag(int tag)
  {
    tags = tags.removeElement(tag);
  }

  ///
  final bool hasTag(int tag)
  {
    import std.algorithm : canFind;

    return tags.canFind(tag);
  }

  /// Makes the passed entity a child of this entity
  final void attach(Entity entity)
  {
    assert(!entity.parent, "Entity should not already be attached to an entity");

    // marked as parent before Scene.addEntity, scene needs to find
    // entities without parents for it's root entities list
    entity.parent = this;
    children ~= entity;

    if(_scene)
      _scene.addEntity(entity);
  }

  /// Detach a child entity or the parent entity
  final void detach(Entity entity)
  {
    if(parent == entity) {
      parent.detach(this);
      return;
    }

    assert(entity.parent == this, "Entity should be attached to this entity");

    if(_scene && entity._scene)
      _scene.removeEntity(entity);

    // abandon child after Scene.removeEntity, so that the scene
    // knows that the entity removed is not a root entity
    entity.parent = null;
    children = children.removeElement(entity);
  }

  ///
  final void attach(Collider2D collider)
  {
    assert(!collider.entity, "Collider should not already be attached to an entity");

    if(_scene)
      _scene.collider2DMap.add(collider);

    colliders2d ~= collider;
    collider.entity = this;
  }

  ///
  final void detach(Collider2D collider)
  {
    assert(collider.entity == this, "Collider should be attached to this entity");

    if(_scene)
      _scene.collider2DMap.remove(collider);

    colliders2d = colliders2d.removeElement(collider);
    collider.entity = null;
  }

  ///
  final void attach(AudioSource source)
  {
    assert(!source.entity, "AudioSource should not already be attached to an entity");

    assert(source.channels == 1, "Source must use a mono format");

    if(_scene)
      _scene.audioSources ~= source;

    audioSources ~= source;
    source.entity = this;
  }

  ///
  final void detach(AudioSource source)
  {
    assert(source.entity == this, "AudioSource should be attached to this entity");

    if(_scene)
      _scene.audioSources = _scene.audioSources.removeElement(source);

    audioSources = audioSources.removeElement(source);
    source.entity = null;
  }

  ///
  final void attach(Renderable renderable)
  {
    renderables ~= renderable;
  }

  ///
  final void detach(Renderable renderable)
  {
    import std.algorithm : canFind;

    assert(renderables.canFind(renderable), "Renderable should be attached to this entity");

    renderables = renderables.removeElement(renderable);
  }

  ///
  final void lookAt(Entity entity)
  {
    lookAt(entity.getWorldPosition());
  }

  ///
  final void lookAt(Vector3 position)
  {
    Vector3 difference = position - getWorldPosition();
    rotation = difference.getDirection();
  }

  ///
  final Matrix getLocalTransformMatrix()
  {
    Matrix transform = Matrix.identity;
    transform = transform.scale(scale);
    transform = transform.rotate(rotation);
    transform = transform.translate(position);

    return transform;
  }

  ///
  final Matrix getWorldTransformMatrix()
  {
    Matrix transform = getLocalTransformMatrix();

    if(parent)
      transform = parent.getWorldTransformMatrix() * transform;

    return transform;
  }

  ///
  final Vector3 getWorldPosition()
  {
    Matrix transform = getWorldTransformMatrix();

    return transform * Vector3();
  }

  ///
  final Quaternion getWorldRotation()
  {
    Quaternion worldRotation;

    if(parent)
      worldRotation = parent.getWorldRotation();

    return rotation * worldRotation;
  }

  ///
  final Vector3 getWorldScale()
  {
    Vector3 worldScale = Vector3(1, 1, 1);

    if(parent)
      worldScale = parent.getWorldScale();

    return scale * worldScale;
  }

  ///
  final Vector2 getScreenPosition()
  {
    return scene.camera.getScreenPosition(position);
  }

  /// Called every draw tick (skipped if update loop is behind)
  void draw(RenderTarget renderTarget, Matrix transform)
  {
    import std.algorithm : sort;

    const auto sortDelegate = scene.camera.getSortDelegate();
    auto sortedChildren = children.sort!(sortDelegate);

    foreach(Entity child; sortedChildren)
      child.draw(renderTarget, transform * child.getLocalTransformMatrix());

    foreach(Renderable renderable; renderables)
      renderable.draw(renderTarget, transform);
  }

  /// Called when first attached to a scene
  void setup(){}
  /// Called when attached to a scene
  void start(){}
  /// Called every update tick
  void update(){}

  ///
  void onCollisionEnter2D(Collider2D collider, Collider2D other){}
  ///
  void onCollision2D(Collider2D collider, Collider2D other){}
  ///
  void onCollisionExit2D(Collider2D collider, Collider2D other){}
}
