module prova.math.rect;

import prova.math,
       std.math;

///
enum Side { LEFT, RIGHT, TOP, BOTTOM }

///
struct Rect
{
  ///
  float left = 0;
  ///
  float top = 0;
  ///
  float width = 0;
  ///
  float height = 0;

  ///
  this(float left, float top, float width, float height)
  {
    set(left, top, width, height);
  }

  //// Sets the position and dimensions of the rect in a single statement
  void set(float left, float top, float width, float height)
  {
    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;
  }

  ///
  @property float right() const
  {
    return left + width;
  }

  ///
  @property void right(float value)
  {
    left = value - width;
  }

  ///
  @property float bottom() const
  {
    return top - height;
  }

  ///
  @property void bottom(float value)
  {
    top = value + height;
  }

  ///
  Vector2 getSize() const
  {
    return Vector2(width, height);
  }

  ///
  Vector2 getCenter() const
  {
    return Vector2(left + width / 2, top - height / 2);
  }

  ///
  Vector2 getTopLeft() const
  {
    return Vector2(left, top);
  }

  ///
  Vector2 getTopRight() const
  {
    return Vector2(right, top);
  }

  ///
  Vector2 getBottomLeft() const
  {
    return Vector2(left, bottom);
  }

  ///
  Vector2 getBottomRight() const
  {
    return Vector2(right, bottom);
  }

  Side getClosestSide(Rect rect) const
  {
    const Vector2 center = getCenter();
    const Vector2 rectCenter = rect.getCenter();

    return getClosestSide(
      (rectCenter.x - center.x) / (width + rect.width),
      (rectCenter.y - center.y) / (height + rect.height)
    );
  }

  Side getClosestSide(Vector2 position) const
  {
    const Vector2 center = getCenter();

    return getClosestSide(
      (position.x - center.x) / width,
      (position.y - center.y) / height
    );
  }

  private Side getClosestSide(float fractionX, float fractionY) const
  {
    if(abs(fractionX) > abs(fractionY)) {
      if(fractionX > 0)
        return Side.RIGHT;
      if(fractionX < 0)
        return Side.LEFT;
    } else {
      if(fractionY > 0)
        return Side.TOP;
      if(fractionY < 0)
        return Side.BOTTOM;
    }

    // default to the left side
    return Side.LEFT;
  }
}