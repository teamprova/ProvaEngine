module prova.collision.resolve;

import prova.attachables;
import prova.math;

// Helper functions for getting a displacement vector that allows colliderA to escape colliderB

// pushes to the left by the smallest value representable by a floating point
Vector2 resolvePointPoint(PointCollider colliderA, PointCollider colliderB)
{
  return Vector2(-float.min_normal, 0);
}

Vector2 resolvePointCircle(PointCollider colliderA, CircleCollider colliderB)
{
  const Vector2 difference = colliderA.getPosition() - colliderB.getPosition();
  Vector2 resolution = difference;

  resolution.setMagnitude(colliderB.radius);
  resolution -= difference;

  return resolution;
}

Vector2 resolvePointRect(PointCollider colliderA, RectCollider colliderB)
{
  const Vector2 position = colliderA.getPosition();
  const Rect bounds = colliderB.getBounds();
  const Side side = bounds.getClosestSide(position);
  Vector2 resolution;

  if(side == Side.LEFT)
    resolution.x = bounds.left - position.x;
  else if(side == Side.RIGHT)
    resolution.x = bounds.right - position.x;
  else if(side == Side.TOP)
    resolution.y = bounds.top - position.y;
  else if(side == Side.BOTTOM)
    resolution.y = bounds.bottom - position.y;

  return resolution;
}

Vector2 resolveCircleCircle(CircleCollider colliderA, CircleCollider colliderB)
{
  const Vector2 difference = colliderA.getPosition() - colliderB.getPosition();
  Vector2 resolution = difference;

  resolution.setMagnitude(colliderA.radius + colliderB.radius);
  resolution -= difference;

  return resolution;
}

Vector2 resolveCircleRect(CircleCollider colliderA, RectCollider colliderB)
{
  Vector2 circlePosition = colliderA.getPosition();
  Rect circleBounds = colliderA.getBounds();
  Rect rectBounds = colliderB.getBounds();
  bool topBottom = circlePosition.x < rectBounds.right && circlePosition.x > rectBounds.left;
  bool leftRight = circlePosition.y < rectBounds.top && circlePosition.y > rectBounds.bottom;

  // touching a side
  if(leftRight || topBottom)
    return resolveRectBounds(circleBounds, rectBounds);

  // on a corner
  return resolveCircleCorners(colliderA, rectBounds);
}

Vector2 resolveCircleCorners(CircleCollider circle, Rect rectBounds)
{
  Vector2 circlePosition = circle.getPosition();
  Vector2 rectPosition = rectBounds.getCenter();
  Vector2[4] corners = [
    rectBounds.getTopLeft(),
    rectBounds.getTopRight(),
    rectBounds.getBottomLeft(),
    rectBounds.getBottomRight()
  ];

  Vector2 resolution;

  foreach(Vector2 corner; corners)
  {
    if(corner.distanceTo(circlePosition) > circle.radius)
      continue;

    const Vector2 difference = circlePosition - corner;
    resolution = difference;

    resolution.setMagnitude(circle.radius + 1e-06);
    resolution -= difference;

    break;
  }

  return resolution;
}

Vector2 resolveRectRect(RectCollider colliderA, RectCollider colliderB)
{
  const Rect boundsA = colliderA.getBounds();
  const Rect boundsB = colliderB.getBounds();

  return resolveRectBounds(boundsA, boundsB);
}

Vector2 resolveRectBounds(Rect boundsA, Rect boundsB)
{
  const Side side = boundsB.getClosestSide(boundsA);
  Vector2 resolution;

  if(side == Side.LEFT)
    resolution.x = boundsB.left - boundsA.right;
  else if(side == Side.RIGHT)
    resolution.x = boundsB.right - boundsA.left;
  else if(side == Side.TOP)
    resolution.y = boundsB.top - boundsA.bottom;
  else if(side == Side.BOTTOM)
    resolution.y = boundsB.bottom - boundsA.top;

  return resolution;
}
