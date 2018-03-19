module prova.core.entity;

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
  package bool isSetup = false;
  package Scene _scene;
  package LinkedList!(Collider2D) colliders2d;
  package LinkedList!(Audio) audioSources;
  private LinkedList!(int) tags;

  ///
  this()
  {
    colliders2d = new LinkedList!(Collider2D);
    audioSources = new LinkedList!(Audio);
    tags = new LinkedList!(int);
  }

  ///
  @property Scene scene()
  {
    return _scene;
  }

  /// Shortcut for scene.game
  @property Game game()
  {
    return _scene.game;
  }

  /// Shortcut for scene.game.input
  @property Input input()
  {
    return _scene.game.input;
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
  void addTag(int tag)
  {
    tags.insertBack(tag);
  }

  ///
  void removeTag(int tag)
  {
    tags.remove(tag);
  }

  ///
  bool hasTag(int tag)
  {
    return tags.contains(tag);
  }

  ///
  void attach(Collider2D collider)
  {
    if(collider.entity != this)
      throw new Exception("Collider can not be attached to non owner entity");

    if(colliders2d.contains(collider))
      throw new Exception("Collider already added");

    if(scene)
      scene.collider2DMap.add(collider);

    colliders2d.insertBack(collider);
  }

  ///
  void remove(Collider2D collider)
  {
    if(scene)
      scene.collider2DMap.remove(collider);

    colliders2d.remove(collider);
  }

  ///
  void attach(Audio source)
  {
    if(source.channels == 2)
      throw new Exception("Source must use a mono format");

    if(source.entity)
      throw new Exception("Remove the audio before attaching it to a new entity");

    if(scene)
      scene.audioSources.insertBack(source);

    audioSources.insertBack(source);
    source.entity = this;
  }

  ///
  void remove(Audio source)
  {
    if(scene)
      scene.audioSources.remove(source);

    audioSources.remove(source);
    source.entity = null;
  }

  /// Called when first attached to a scene
  void setup(){}
  /// Called when attached to a scene
  void start(){}
  /// Called every update tick
  void update(){}
  /// Called every draw tick (skipped if update loop is behind)
  void draw(RenderTarget renderTarget){}

  ///
  void onCollisionEnter2D(Collider2D collider, Collider2D other){}
  ///
  void onCollision2D(Collider2D collider, Collider2D other){}
  ///
  void onCollisionExit2D(Collider2D collider, Collider2D other){}
}