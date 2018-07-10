module prova.collision.intersects;

import prova.attachables;
import prova.math;
import std.math;

bool pointIntersectsPoint(PointCollider pointA, PointCollider pointB)
{
  return pointA.getPosition() == pointB.getPosition();
}

bool pointIntersectsCircle(PointCollider point, CircleCollider circle)
{
  const float distance = point.getPosition().distanceTo(circle.getPosition());
  
  return distance <= circle.radius;
}

bool pointIntersectsRect(PointCollider point, RectCollider rect)
{
  Vector2 position = point.getPosition();
  Rect bounds = rect.getBounds();

  return position.x > bounds.left && position.x < bounds.left + bounds.width &&
        position.y < bounds.top && position.y > bounds.top - bounds.height;
}

bool circleIntersectsCircle(CircleCollider circleA, CircleCollider circleB)
{
  const float distance = circleA.getPosition().distanceTo(circleB.getPosition());

  return distance < circleA.radius + circleB.radius;
}

bool circleIntersectsRect(CircleCollider circle, RectCollider rect)
{
  // Following answer provided by e.James https://stackoverflow.com/users/33686/e-james
  // https://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection

  const Vector2 circlePosition = circle.getPosition();
  const Vector2 rectPosition = rect.getPosition();

  const Vector2 distance = Vector2(
    abs(circlePosition.x - rectPosition.x),
    abs(circlePosition.y - rectPosition.y)
  );

  if(distance.x >= rect.width / 2 + circle.radius)
    return false;
  if(distance.y >= rect.height / 2 + circle.radius)
    return false;

  if(distance.x < rect.width / 2)
    return true;
  if(distance.y < rect.height / 2)
    return true;

  const float cornerDistSquared = (distance.x - rect.width / 2) ^^ 2 +
                                  (distance.y - rect.height / 2) ^^ 2;

  return cornerDistSquared < circle.radius ^^ 2;
}

bool rectIntersectsRect(RectCollider rectA, RectCollider rectB)
{
  Rect boundsA = rectA.getBounds();
  Rect boundsB = rectB.getBounds();

  return boundsA.left < boundsB.right &&
          boundsA.right > boundsB.left &&
          boundsA.top > boundsB.bottom &&
          boundsA.bottom < boundsB.top;
}
