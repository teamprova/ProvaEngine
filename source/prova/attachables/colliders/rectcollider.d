module prova.attachables.colliders.rectcollider;

import prova.attachables;
import prova.collision.intersects;
import prova.collision.resolve;
import prova.core;
import prova.graphics;
import prova.math;

///
class RectCollider : Collider2D
{
  ///
  float width;
  ///
  float height;

  ///
  this(float width, float height)
  {
    super(Shape.RECTANGLE);
    this.width = width;
    this.height = height;
  }

  ///
  override Vector2 getSize()
  {
    return Vector2(width, height);
  }

  ///
  override bool intersects(RectCollider collider)
  {
    return rectIntersectsRect(this, collider);
  }

  ///
  override bool intersects(CircleCollider collider)
  {
    return circleIntersectsRect(collider, this);
  }

  ///
  override bool intersects(PointCollider collider)
  {
    return pointIntersectsRect(collider, this);
  }

  alias intersects = Collider2D.intersects;

  ///
  override Vector2 resolve(PointCollider collider)
  {
    return -resolvePointRect(collider, this);
  }

  ///
  override Vector2 resolve(CircleCollider collider)
  {
    return -resolveCircleRect(collider, this);
  }

  ///
  override Vector2 resolve(RectCollider collider)
  {
    return resolveRectRect(this, collider);
  }

  alias resolve = Collider2D.resolve;
}
