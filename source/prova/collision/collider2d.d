module prova.collision.collider2d;

import prova.collision;
import prova.collision.intersects;
import prova.collision.resolve;
import prova.core;
import prova.graphics;
import prova.math;
import prova.util;

package enum Shape { POINT, RECTANGLE, CIRCLE }

///
abstract class Collider2D
{
  ///
  Vector2 offset;
  package LinkedList!(Collider2D) collisions;
  package LinkedList!(Collider2D) previousCollisions;
  private LinkedList!(int) tags;
  private Entity _entity;
  private Shape _shape;

  ///
  package this(Shape shape)
  {
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
  package(prova) @property void entity(Entity entity)
  {
    _entity = entity;
  }

  ///
  @property bool collisionOccured()
  {
    return collisions.length > 0;
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
  Vector2 getPosition()
  {
    Vector3 position = _entity.getWorldPosition();

    return Vector2(position.x, position.y);
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
