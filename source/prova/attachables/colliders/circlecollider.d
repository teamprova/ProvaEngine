module prova.attachables.colliders.circlecollider;

import prova.attachables;
import prova.collision.intersects;
import prova.collision.resolve;
import prova.core;
import prova.graphics;
import prova.math;

///
class CircleCollider : Collider2D
{
  private float _radius;

  ///
  this(float radius)
  {
    super(Shape.CIRCLE);
    _radius = radius;
  }

  ///
  @property float radius()
  {
    return _radius;
  }

  ///
  @property void radius(float radius)
  {
    resize(radius);
  }

  ///
  void resize(float radius)
  {
    this._radius = radius;
    updateSize();
  }

  ///
  override Vector2 getSize()
  {
    return Vector2(_radius * 2, _radius * 2);
  }

  ///
  override bool intersects(PointCollider collider)
  {
    return pointIntersectsCircle(collider, this);
  }

  ///
  override bool intersects(CircleCollider collider)
  {
    return circleIntersectsCircle(this, collider);
  }

  ///
  override bool intersects(RectCollider collider)
  {
    return circleIntersectsRect(this, collider);
  }

  alias intersects = Collider2D.intersects;

  ///
  override Vector2 resolve(PointCollider collider)
  {
    return -resolvePointCircle(collider, this);
  }

  ///
  override Vector2 resolve(CircleCollider collider)
  {
    return resolveCircleCircle(this, collider);
  }

  ///
  override Vector2 resolve(RectCollider collider)
  {
    return resolveCircleRect(this, collider);
  }

  alias resolve = Collider2D.resolve;
}
