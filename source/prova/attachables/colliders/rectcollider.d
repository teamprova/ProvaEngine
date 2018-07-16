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
  private float _width;
  private float _height;

  ///
  this(float width, float height)
  {
    super(Shape.RECTANGLE);
    this._width = width;
    this._height = height;
  }

  ///
  @property float width()
  {
    return _width;
  }

  ///
  @property void width(float width)
  {
    this._width = width;
    updateSize();
  }

  ///
  @property float height()
  {
    return _height;
  }

  ///
  @property void height(float height)
  {
    this._height = height;
    updateSize();
  }

  ///
  void resize(float width, float height)
  {
    this._width = width;
    this._height = height;
    updateSize();
  }

  ///
  override Vector2 getSize()
  {
    return Vector2(_width, _height);
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
