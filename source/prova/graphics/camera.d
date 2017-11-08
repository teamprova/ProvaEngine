module prova.graphics.camera;

import prova.math;

///
enum SortingMethod { Z, Distance }
///
enum Projection { Perspective, Orthographic }

///
class Camera
{
  ///
  Projection projection = Projection.Perspective;
  ///
  SortingMethod sortingMethod = SortingMethod.Distance;
  ///
  Vector3 scale = Vector3(1, 1, 1);
  ///
  Vector3 position;
  ///
  Vector3 rotation;
  ///
  bool useDepthBuffer = true;
  /// Width and height will be set to the screen resolution when true
  bool resolutionDependent = false;
  ///
  float zNear = 0;
  ///
  float zFar = 1000;
  /// for orthographic projection and UI
  float width = 1;
  /// for orthographic projection and UI
  float height = 1;
  /// for perspective projection
  float FOV = 90;

  ///
  @property float zRange()
  {
    return zFar - zNear;
  }

  ///
  Matrix getTransform()
  {
    Matrix transform = Matrix.identity();
    transform = transform.translate(-position);
    transform = transform.scale(scale);
    transform = transform.rotateY(rotation.y);
    transform = transform.rotateX(rotation.x);
    transform = transform.rotateZ(rotation.z);

    return transform;
  }

  ///
  Matrix getProjection()
  {
    if(projection == Projection.Orthographic)
      return Matrix.ortho(-width/2, width/2, height/2, -height/2, zNear, zFar);
    return Matrix.perspective(width, height, zNear, zFar, FOV);
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