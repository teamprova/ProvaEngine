module prova.collision.rectcollider;

import prova.collision,
       prova.collision.intersects,
       prova.collision.resolve,
       prova.core,
       prova.graphics,
       prova.math;

///
class RectCollider : Collider2D
{
  ///
  float width;
  ///
  float height;

  ///
  this(Entity entity, float width, float height)
  {
    super(entity, Shape.RECTANGLE);
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

  ///
  override void draw(Screen screen)
  {
    Color color = collisionOccurred ? Color(1, 0, 0) : Color(0, 0, 1);

    Rect bounds = getBounds();
    screen.drawRect(bounds, color);
  }
}