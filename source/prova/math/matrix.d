module prova.math.matrix;

import prova.math;
import std.algorithm.mutation;
import std.math;

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
  static @property Matrix identity()
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
  Matrix rotate(Quaternion rotation) const
  {
    Matrix rotationMatrix;
    float x = rotation.x;
    float y = rotation.y;
    float z = rotation.z;
    float w = rotation.w;

    rotationMatrix.array = [
      [1 - 2 * y * y - 2 * z * z,     2 * x * y - 2 * w * z,     2 * x * z + 2 * w * y, 0 ],
      [    2 * x * y + 2 * w * z, 1 - 2 * x * x - 2 * z * z,     2 * y * z - 2 * w * x, 0 ],
      [    2 * x * z - 2 * w * y,     2 * y * z + 2 * w * x, 1 - 2 * x * x - 2 * y * y, 0 ],
      [    0f,                        0f,                        0f,                    1f]
    ];

    return rotationMatrix * this;
  }

  ///
  Matrix rotateX(float degrees) const
  {
    const float angle = degrees / 180 * PI;
    const float angleSin = sin(-angle);
    const float angleCos = cos(-angle);

    Matrix rotation = identity;
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

    Matrix rotation = identity;
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

    Matrix rotation = identity;
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
    Matrix translation = identity;
    translation[0][3] = x;
    translation[1][3] = y;
    translation[2][3] = z;

    return translation * this;
  }

  ///
  Matrix transpose() const
  {
    Matrix transposition;

    foreach(x; 0 .. 4)
      foreach(y; 0 .. 4)
        transposition[x][y] = array[y][x];

    return transposition;
  }

  ///
  Matrix invert() const
  {
    // calculating inverse using row operations
    Matrix identity = Matrix.identity;
    float[8][4] appendedMatrix;

    // setup
    foreach(row; 0 .. 4)
      appendedMatrix[row] = array[row] ~ identity[row];

    // down
    foreach(i; 0 .. 4) {
      float denominator = appendedMatrix[i][i];

      if(denominator == 0)
        foreach(col; 0 .. 4)
          foreach(row; i .. 4) {
            denominator = appendedMatrix[row][col];

            if(denominator == 0)
              continue;

            swap(appendedMatrix[i], appendedMatrix[row]);
          }

      appendedMatrix[i][] *= 1 / denominator;

      foreach(j; i + 1 .. 4)
        appendedMatrix[j][] += appendedMatrix[i][] * -appendedMatrix[j][i];
    }

    // up
    foreach_reverse(i; 1 .. 4)
      foreach_reverse(j; 0 .. i)
        appendedMatrix[j][] += appendedMatrix[i][] * -appendedMatrix[j][i];

    // storing results
    Matrix result;

    foreach(i; 0 .. 4)
      result.array[i] = appendedMatrix[i][4 .. 8];

    return result;
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
    float[4] result;

    foreach(i; 0 .. 4) {
      result[i] = array[0][i] * vector.x +
                  array[1][i] * vector.y +
                  array[2][i] * vector.z +
                  array[3][i] * vector.w;
    }

    return Vector4(result[0], result[1], result[2], result[3]);
  }

  Vector3 opMul(Vector3 vector) const
  {
    float[3] result; // x, y, z, 1

    foreach(i; 0 .. 3) {
      result[i] = array[0][i] * vector.x +
                  array[1][i] * vector.y +
                  array[2][i] * vector.z +
                  array[3][i]/*    1   */+
                  array[i][3]; // translate
    }

    return Vector3(result[0], result[1], result[2]);
  }

  Vector2 opMul(Vector2 vector) const
  {
    float[2] result; // x, y, 0, 1

    foreach(i; 0 .. 2) {
      result[i] = array[0][i] * vector.x +
                  array[1][i] * vector.y +
                  array[3][i]/*    1   */+
                  array[i][3]; // translate
    }

    return Vector2(result[0], result[1]);
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
