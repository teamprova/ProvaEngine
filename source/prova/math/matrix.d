module prova.math.matrix;

import prova.math,
       std.math;

/// Struct representing a 4x4 matrix
struct Matrix
{
  /// array[row][column]
  float[4][4] array = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ];

  ///
  static Matrix identity()
  {
    Matrix identity;

    foreach(i; 0 .. 4)
      identity[i][i] = 1;

    return identity;
  }

  ///
  static Matrix ortho(float left, float right, float top, float bottom, float near, float far)
  {
    Matrix ortho;
    ortho[0][0] = 2 / (right - left);
    ortho[1][1] = 2 / (top - bottom);
    ortho[2][2] = 2 / (near - far);

    ortho[0][3] = (left + right) / (left - right);
    ortho[1][3] = (bottom + top) / (bottom - top);
    ortho[2][3] = (near + far) / (near - far);
    ortho[3][3] = 1;

    return ortho;
  }

  ///
  static Matrix perspective(float width, float height, float near, float far, float fov)
  {
    fov = fov / 180 * PI;

    const float tanHalfFov = tan(fov / 2);
    const float range = far - near;
    const float aspectRatio = width / height;

    Matrix perspective;
    perspective[0][0] = 1 / (tanHalfFov * aspectRatio);
    perspective[1][1] = 1 / tanHalfFov;
    perspective[2][2] = - (far + near) / range;
    perspective[2][3] = - (2 * near * far) / range;
    perspective[3][2] = -1;
    return perspective;
  }

  ///
  Matrix rotateX(float degrees) const
  {
    const float angle = degrees / 180 * PI;
    const float angleSin = sin(-angle);
    const float angleCos = cos(-angle);

    Matrix rotation = identity();
    rotation[1][1] = angleCos;
    rotation[1][2] = -angleSin;
    rotation[2][1] = angleSin;
    rotation[2][2] = angleCos;

    return rotation * this;
  }

  ///
  Matrix rotateY(float degrees) const
  {
    const float angle = degrees / 180 * PI;
    const float angleSin = sin(-angle);
    const float angleCos = cos(-angle);

    Matrix rotation = identity();
    rotation[0][0] = angleCos;
    rotation[0][2] = angleSin;
    rotation[2][0] = -angleSin;
    rotation[2][2] = angleCos;

    return rotation * this;
  }

  ///
  Matrix rotateZ(float degrees) const
  {
    const float angle = degrees / 180 * PI;
    const float angleSin = sin(-angle);
    const float angleCos = cos(-angle);

    Matrix rotation = identity();
    rotation[0][0] = angleCos;
    rotation[0][1] = -angleSin;
    rotation[1][0] = angleSin;
    rotation[1][1] = angleCos;

    return rotation * this;
  }

  ///
  Matrix scale(Vector2 vector) const
  {
    return scale(vector.x, vector.y, 1);
  }

  ///
  Matrix scale(Vector3 vector) const
  {
    return scale(vector.x, vector.y, vector.z);
  }

  ///
  Matrix scale(float x, float y, float z) const
  {
    Matrix result;

    foreach(col; 0 .. 4) {
      result[0][col] = array[0][col] * x;
      result[1][col] = array[1][col] * y;
      result[2][col] = array[2][col] * z;
      result[3][col] = array[3][col];
    }

    return result;
  }

  ///
  Matrix translate(Vector2 vector) const
  {
    return translate(vector.x, vector.y, 0);
  }

  ///
  Matrix translate(Vector3 vector) const
  {
    return translate(vector.x, vector.y, vector.z);
  }

  ///
  Matrix translate(float x, float y) const
  {
    return translate(x, y, 0);
  }

  ///
  Matrix translate(float x, float y, float z) const
  {
    Matrix translation = identity();
    translation[0][3] = x;
    translation[1][3] = y;
    translation[2][3] = z;

    return translation * this;
  }

  ref float[4] opIndex(int i)
  {
    return array[i];
  }

  Matrix opAdd(Matrix matrix) const
  {
    foreach(y; 0 .. 4)
      foreach(x; 0 .. 4)
        matrix[y][x] += array[x][y];

    return matrix;
  }

  Matrix opSub(Matrix matrix) const
  {
    foreach(y; 0 .. 4)
      foreach(x; 0 .. 4)
        matrix[y][x] -= array[y][x];

    return matrix;
  }

  Matrix opMul(Matrix matrix) const
  {
    Matrix result;

    foreach(y; 0 .. 4)
      foreach(x; 0 .. 4)
        foreach(i; 0 .. 4)
          result[y][x] += array[y][i] * matrix[i][x];

    return result;
  }

  Vector4 opMul(Vector4 vector) const
  {
    Vector4 result;

    foreach(col; 0 .. 4) {
      result.x += array[0][col] * vector.x;
      result.y += array[1][col] * vector.y;
      result.z += array[2][col] * vector.z;
      result.w += array[3][col] * vector.w;
    }

    return result;
  }

  Matrix opMul(float a) const
  {
    Matrix matrix;

    foreach(y; 0 .. 4)
      foreach(x; 0 .. 4)
        matrix[y][x] = array[y][x] * a;

    return matrix;
  }

  Matrix opDiv(float a) const
  {
    Matrix matrix;

    foreach(y; 0 .. 4)
      foreach(x; 0 .. 4)
        matrix[y][x] = array[y][x] / a;

    return matrix;
  }
}