module prova.core.camera;

import prova.core;
import prova.math;

///
enum SortingMethod { Z, DISTANCE }
///
enum Projection { PERSPECTIVE, ORTHOGRAPHIC }

///
class Camera : Entity
{
  ///
  Projection projection = Projection.PERSPECTIVE;
  ///
  SortingMethod sortingMethod = SortingMethod.DISTANCE;
  ///
  bool useDepthBuffer = true;
  /// Width and height will be set to the screen resolution when true
  bool resolutionDependent = false;
  ///
  float zNear = float.min_normal;
  ///
  float zFar = 1000;
  /// For orthographic projection and UI
  float width = 1;
  /// For orthographic projection and UI
  float height = 1;
  /// For perspective projection
  float FOV = 90;

  ///
  @property float zRange()
  {
    return zFar - zNear;
  }

  ///
  Matrix getViewMatrix()
  {
    Vector3 worldPosition = getWorldPosition();
    Quaternion worldRotation = getWorldRotation();

    Matrix transform = Matrix.identity;
    transform = transform.translate(-worldPosition);
    transform = transform.rotate(worldRotation.getConjugate());
    transform = transform.scale(scale);

    return transform;
  }

  ///
  Matrix getProjectionMatrix()
  {
    if(projection == Projection.ORTHOGRAPHIC)
      return Matrix.ortho(-width/2, width/2, height/2, -height/2, zNear, zFar);
    return Matrix.perspective(width, height, zNear, zFar, FOV);
  }

  /**
   * Converts world position to screen position
   * - This is equal to getProjectionMatrix() * getViewMatrix()
   */
  Matrix getScreenMatrix()
  {
    return getProjectionMatrix() * getViewMatrix();
  }

  /// 
  Vector2 getScreenPosition(Vector3 worldPosition)
  {
    Vector4 worldPositionVec4 = worldPosition;
    worldPositionVec4.w = 1;

    Vector4 clipSpacePosition = getScreenMatrix() * worldPositionVec4;

    return clipSpacePosition.xy / clipSpacePosition.w;
  }

  ///
  Matrix getUIMatrix()
  {
    const float left = 0;
    const float right = width / scale.x;
    const float top = height / scale.y;
    const float bottom = 0;

    return Matrix.ortho(left, right, top, bottom, -1, 1);
  }

  ///
  bool delegate(Entity, Entity) getSortDelegate()
  {
    final switch(sortingMethod)
    {
      case SortingMethod.DISTANCE:
        return (a, b) => distanceSort(a, b);
      case SortingMethod.Z:
        return (a, b) => zSort(a, b);
    }
  }

  private bool distanceSort(Entity entityA, Entity entityB)
  {
    float distanceA = position.distanceTo(entityA.position);
    float distanceB = position.distanceTo(entityB.position);

    return distanceA < distanceB;
  }

  private bool zSort(Entity entityA, Entity entityB)
  {
    return entityA.position.z < entityB.position.z;
  }
}
