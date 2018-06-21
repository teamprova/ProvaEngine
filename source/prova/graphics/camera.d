module prova.graphics.camera;

import prova.core;
import prova.math;

///
enum SortingMethod { Z, Distance }
///
enum Projection { Perspective, Orthographic }

///
class Camera : Entity
{
  ///
  Projection projection = Projection.Perspective;
  ///
  SortingMethod sortingMethod = SortingMethod.Distance;
  ///
  bool useDepthBuffer = true;
  /// Width and height will be set to the screen resolution when true
  bool resolutionDependent = false;
  ///
  float zNear = 0;
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
    if(projection == Projection.Orthographic)
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
  Matrix getUIMatrix()
  {
    const float left = 0;
    const float right = width / scale.x;
    const float top = height / scale.y;
    const float bottom = 0;

    return Matrix.ortho(left, right, top, bottom, -1, 1);
  }
}
