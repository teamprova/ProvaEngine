module prova.collision.collider2d;

import prova.collision,
       prova.collision.intersects,
       prova.collision.resolve,
       prova.core,
       prova.graphics,
       prova.math,
       prova.util;

package enum Shape { POINT, RECTANGLE, CIRCLE }

///
abstract class Collider2D
{
  ///
  Vector2 offset;
  package bool collisionOccurred = false;
  package LinkedList!(Collider2D) collisions;
  package LinkedList!(Collider2D) previousCollisions;
  private LinkedList!(int) tags;
  private Entity _entity;
  private Shape _shape;

  package this(Entity entity, Shape shape)
  {
    _entity = entity;
    _shape = shape;
    collisions = new LinkedList!(Collider2D);
    tags = new LinkedList!(int);
  }

  ///
  @property Entity entity()
  {
    return _entity;
  }

  ///
  Vector2 getSize();
  ///
  bool intersects(RectCollider collider);
  ///
  bool intersects(CircleCollider collider);
  ///
  bool intersects(PointCollider collider);
  ///
  Vector2 resolve(RectCollider collider);
  ///
  Vector2 resolve(CircleCollider collider);
  ///
  Vector2 resolve(PointCollider collider);

  ///
  void draw(RenderTarget renderTarget);

  ///
  Vector2 getPosition()
  {
    return Vector2(
      entity.position.x + offset.x,
      entity.position.y + offset.y
    );
  }

  ///
  Rect getBounds()
  {
    Vector2 size = getSize();
    Vector2 position = getPosition();

    return Rect(
      position.x - size.x / 2,
      position.y + size.y / 2,
      size.x,
      size.y
    );
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
  bool intersects(Collider2D collider)
  {
    final switch(collider._shape)
    {
      case Shape.POINT:
        return intersects(cast(PointCollider) collider);
      case Shape.CIRCLE:
        return intersects(cast(CircleCollider) collider);
      case Shape.RECTANGLE:
        return intersects(cast(RectCollider) collider);
    }
  }

  /// Returns a vector that can be used to move the entity out of the collider
  Vector2 resolve(Collider2D collider)
  {
    final switch(collider._shape)
    {
      case Shape.POINT:
        return resolve(cast(PointCollider) collider);
      case Shape.CIRCLE:
        return resolve(cast(CircleCollider) collider);
      case Shape.RECTANGLE:
        return resolve(cast(RectCollider) collider);
    }
  }
}