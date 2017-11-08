module prova.collision.collider2d;

import prova.collision,
       prova.collision.intersects,
       prova.collision.resolve,
       prova.core,
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
  void draw(Screen screen);

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
    Collider2D colliderA = this;
    Collider2D colliderB = collider;

    if(colliderA._shape == Shape.POINT && colliderB._shape == Shape.POINT)
      return pointIntersectsPoint(cast(PointCollider) colliderA, cast(PointCollider) colliderB);
    if(colliderA._shape == Shape.POINT && colliderB._shape == Shape.CIRCLE)
      return pointIntersectsCircle(cast(PointCollider) colliderA, cast(CircleCollider) colliderB);
    if(colliderA._shape == Shape.POINT && colliderB._shape == Shape.RECTANGLE)
      return pointIntersectsRect(cast(PointCollider) colliderA, cast(RectCollider) colliderB);

    if(colliderA._shape == Shape.CIRCLE && colliderB._shape == Shape.POINT)
      return pointIntersectsCircle(cast(PointCollider) colliderB, cast(CircleCollider) colliderA);
    if(colliderA._shape == Shape.CIRCLE && colliderB._shape == Shape.CIRCLE)
      return circleIntersectsCircle(cast(CircleCollider) colliderA, cast(CircleCollider) colliderB);
    if(colliderA._shape == Shape.CIRCLE && colliderB._shape == Shape.RECTANGLE)
      return circleIntersectsRect(cast(CircleCollider) colliderA, cast(RectCollider) colliderB);

    if(colliderA._shape == Shape.RECTANGLE && colliderB._shape == Shape.POINT)
      return pointIntersectsRect(cast(PointCollider) colliderB, cast(RectCollider) colliderA);
    if(colliderA._shape == Shape.RECTANGLE && colliderB._shape == Shape.CIRCLE)
      return circleIntersectsRect(cast(CircleCollider) colliderB, cast(RectCollider) colliderA);
    if(colliderA._shape == Shape.RECTANGLE && colliderB._shape == Shape.RECTANGLE)
      return rectIntersectsRect(cast(RectCollider) colliderA, cast(RectCollider) colliderB);

    throw new Exception("Could not test intersection");
  }

  /// Returns a vector that can be used to move the entity out of the collider
  Vector2 resolve(Collider2D collider)
  {
    Collider2D colliderA = this;
    Collider2D colliderB = collider;

    if(colliderA._shape == Shape.POINT && colliderB._shape == Shape.POINT)
      return resolvePointPoint(cast(PointCollider) colliderA, cast(PointCollider) colliderB);
    if(colliderA._shape == Shape.POINT && colliderB._shape == Shape.CIRCLE)
      return resolvePointCircle(cast(PointCollider) colliderA, cast(CircleCollider) colliderB);
    if(colliderA._shape == Shape.POINT && colliderB._shape == Shape.RECTANGLE)
      return resolvePointRect(cast(PointCollider) colliderA, cast(RectCollider) colliderB);

    if(colliderA._shape == Shape.CIRCLE && colliderB._shape == Shape.POINT)
      return -resolvePointCircle(cast(PointCollider) colliderB, cast(CircleCollider) colliderA);
    if(colliderA._shape == Shape.CIRCLE && colliderB._shape == Shape.CIRCLE)
      return resolveCircleCircle(cast(CircleCollider) colliderA, cast(CircleCollider) colliderB);
    if(colliderA._shape == Shape.CIRCLE && colliderB._shape == Shape.RECTANGLE)
      return resolveCircleRect(cast(CircleCollider) colliderA, cast(RectCollider) colliderB);

    if(colliderA._shape == Shape.RECTANGLE && colliderB._shape == Shape.POINT)
      return -resolvePointRect(cast(PointCollider) colliderB, cast(RectCollider) colliderA);
    if(colliderA._shape == Shape.RECTANGLE && colliderB._shape == Shape.CIRCLE)
      return -resolveCircleRect(cast(CircleCollider) colliderB, cast(RectCollider) colliderA);
    if(colliderA._shape == Shape.RECTANGLE && colliderB._shape == Shape.RECTANGLE)
      return resolveRectRect(cast(RectCollider) colliderA, cast(RectCollider) colliderB);

    throw new Exception("Could not resolve intersection");
  }
}