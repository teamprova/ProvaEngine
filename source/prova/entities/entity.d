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
  package(prova) LinkedList!(Collider2D) colliders2d;
  package(prova) AudioSource[] audioSources;
  private Renderable[] renderables;
  private Entity _parent;
  private int[] tags;

  ///
  this()
  {
    colliders2d = new LinkedList!(Collider2D);
  }

  ///
  final @property Scene scene()
  {
    if(!_scene)
      throw new Exception("Entity is not attached to a scene");
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
    if(entity.parent || entity.parent == this)
      throw new Exception("Entity already attached");

    if(_scene)
      _scene.addEntity(entity);

    children ~= entity;
    entity.parent = this;
  }

  /// Detach a child entity or the parent entity
  final void detach(Entity entity)
  {
    if(parent == entity) {
      parent.detach(this);
      return;
    }

    if(entity.parent != this)
      throw new Exception("Entity was not attached");

    if(_scene && entity._scene)
      _scene.removeEntity(entity);

    children = children.removeElement(entity);
    entity.parent = null;
  }

  ///
  final void attach(Collider2D collider)
  {
    if(collider.entity || collider.entity == this)
      throw new Exception("Collider already attached");

    if(_scene)
      _scene.collider2DMap.add(collider);

    colliders2d.insertBack(collider);
    collider.entity = this;
  }

  ///
  final void detach(Collider2D collider)
  {
    if(collider.entity != this)
      throw new Exception("Collider was not attached");

    if(_scene)
      _scene.collider2DMap.remove(collider);

    colliders2d.remove(collider);
    collider.entity = null;
  }

  ///
  final void attach(AudioSource source)
  {
    if(source.entity || source.entity == this)
      throw new Exception("AudioSource already attached");

    if(source.channels == 2)
      throw new Exception("Source must use a mono format");

    if(_scene)
      _scene.audioSources ~= source;

    audioSources ~= source;
    source.entity = this;
  }

  ///
  final void detach(AudioSource source)
  {
    if(source.entity != this)
      throw new Exception("Collider was not attached");

    if(_scene)
      _scene.audioSources = _scene.audioSources.removeElement(source);

    audioSources = audioSources.removeElement(source);
    source.entity = null;
  }

  ///
  final void attach(Renderable renderable)
  {
    import std.algorithm : canFind;

    if(renderables.canFind(renderable))
      throw new Exception("Renderable already attached");

    renderables ~= renderable;
  }

  ///
  final void detach(Renderable renderable)
  {
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
