module prova.attachables.colliders.pointcollider;

import prova.attachables;
import prova.collision.intersects;
import prova.collision.resolve;
import prova.core;
import prova.graphics;
import prova.math;

///
class PointCollider : Collider2D
{
  ///
  this()
  {
    super(Shape.POINT);
  }

  ///
  override Vector2 getSize()
  {
    return Vector2(1, 1);
  }

  ///
  override bool intersects(RectCollider collider)
  {
    return pointIntersectsRect(this, collider);
  }

  ///
  override bool intersects(CircleCollider collider)
  {
    return pointIntersectsCircle(this, collider);
  }

  ///
  override bool intersects(PointCollider collider)
  {
    return pointIntersectsPoint(this, collider);
  }

  alias intersects = Collider2D.intersects;

  ///
  override Vector2 resolve(PointCollider collider)
  {
    return resolvePointPoint(this, collider);
  }

  ///
  override Vector2 resolve(CircleCollider collider)
  {
    return resolvePointCircle(this, collider);
  }

  ///
  override Vector2 resolve(RectCollider collider)
  {
    return resolvePointRect(this, collider);
  }

  alias resolve = Collider2D.resolve;
}
