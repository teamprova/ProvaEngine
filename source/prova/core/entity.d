module prova.core.entity;

import prova.collision,
       prova.core,
       prova.graphics,
       prova.input,
       prova.math,
       prova.util;

///
class Entity
{
  ///
  Vector3 position;
  ///
  Vector3 velocity;
  /// Velocity is multiplied by (1 - friction) every tick
  float friction = 0;
  package bool isSetup = false;
  package Scene _scene;
  package LinkedList!(Collider2D) colliders2d;
  private LinkedList!(int) tags;

  this()
  {
    colliders2d = new LinkedList!(Collider2D);
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

  /// Called when first attached to a scene
  void setup(){}
  /// Called when attached to a scene
  void start(){}
  /// Called every update tick
  void update(){}
  /// Called every draw tick (skipped if update loop is behind)
  void draw(Screen screen){}

  ///
  void onCollisionEnter2D(Collider2D collider, Collider2D other){}
  ///
  void onCollision2D(Collider2D collider, Collider2D other){}
  ///
  void onCollisionExit2D(Collider2D collider, Collider2D other){}
}