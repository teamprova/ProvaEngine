module prova.math.vector3;

import prova.math,
       std.math;

///
struct Vector3
{
  ///
  float x = 0;
  ///
  float y = 0;
  ///
  float z = 0;

  ///
  this(float x, float y, float z)
  {
    set(x, y, z);
  }

  ///
  this(Vector2 vector)
  {
    set(vector.x, vector.y, 0);
  }

  /// Sets the values of x, y, and z in a single statement
  void set(float x, float y, float z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  /// Creates a normalized vector with a random direction
  static Vector3 random()
  {
    Vector3 vector = Vector3(
      randomF(1),
      randomF(1),
      randomF(1)
    );

    vector.normalize();

    return vector;
  }

  /// Returns a normalized copy of this vector
  Vector3 getNormalized() const
  {
    const float magnitude = getMagnitude();

    Vector3 result;

    if(magnitude != 0) {
      result.x = x / magnitude;
      result.y = y / magnitude;
      result.z = y / magnitude;
    }

    return result;
  }

  /// Normalizes the vector
  void normalize()
  {
    const float magnitude = getMagnitude();

    if(magnitude == 0)
      return;

    x = x / magnitude;
    y = y / magnitude;
    z = z / magnitude;
  }

  /// Returns the magnitude of the vector
  float getMagnitude() const
  {
    return sqrt(x * x + y * y + z * z);
  }

  /**
   * Sets the magnitude of this vector
   *
   * If the previous magnitude is zero, the x value
   * of the vector will be set to the magnitude
   */
  void setMagnitude(float magnitude)
  {
    if(getMagnitude() == 0) {
      x = magnitude;
      return;
    }

    normalize();

    x *= magnitude;
    y *= magnitude;
    z *= magnitude;
  }

  /// Returns the distance between the vectors
  float distanceTo(Vector3 vector) const
  {
    const float a = vector.x - x;
    const float b = vector.y - y;
    const float c = vector.z - z;

    return sqrt(a * a + b * b + c * c);
  }

  /// Returns the squared distance between the vectors
  float distanceToSquared(Vector3 vector) const
  {
    const float a = vector.x - x;
    const float b = vector.y - y;
    const float c = vector.z - z;

    return a * a + b * b + c * c;
  }

  // Returns the dot product of the two vectors
  float dot(Vector3 vector)
  {
    return x * vector.x + y * vector.y + z * vector.z;
  }

  // Returns the cross product of the two vectors
  Vector3 cross(Vector3 vector)
  {
    Vector3 result;
    result.x = y * vector.z - vector.y * x;
    result.y = -(x * vector.z - vector.x * z);
    result.z = x * vector.y - vector.x * y;

    return result;
  }


  // assignment overloading
  Vector3 opAddAssign(Vector3 vector)
  {
    x += vector.x;
    y += vector.y;
    z += vector.z;

    return this;
  }

  Vector3 opAddAssign(Vector2 vector)
  {
    x += vector.x;
    y += vector.y;

    return this;
  }

  Vector3 opSubAssign(Vector3 vector)
  {
    x -= vector.x;
    y -= vector.y;
    z -= vector.z;

    return this;
  }

  Vector3 opSubAssign(Vector2 vector)
  {
    x -= vector.x;
    y -= vector.y;

    return this;
  }

  Vector3 opMulAssign(float a)
  {
    x *= a;
    y *= a;
    z *= a;

    return this;
  }

  Vector3 opDivAssign(float a)
  {
    x /= a;
    y /= a;
    z /= a;

    return this;
  }


  // arithmetic overloading
  Vector3 opAdd(Vector3 vector) const
  {
    Vector3 result;
    result.x = x + vector.x;
    result.y = y + vector.y;
    result.z = z + vector.z;

    return result;
  }

  Vector3 opAdd(Vector2 vector) const
  {
    Vector3 result;
    result.x = x + vector.x;
    result.y = y + vector.y;
    result.z = z;

    return result; 
  }

  Vector3 opSub(Vector3 vector) const
  {
    Vector3 result;
    result.x = x - vector.x;
    result.y = y - vector.y;
    result.z = z - vector.z;

    return result; 
  }

  Vector3 opSub(Vector2 vector) const
  {
    Vector3 result;
    result.x = x - vector.x;
    result.y = y - vector.y;
    result.z = z;

    return result; 
  }

  Vector3 opUnary(string s)() const if (s == "-")
  {
    Vector3 result;
    result.x = -x;
    result.y = -y;
    result.z = -z;

    return result;
  }

  Vector3 opMul(float a) const
  {
    Vector3 result;
    result.x = x * a;
    result.y = y * a;
    result.z = z * a;

    return result; 
  }

  Vector3 opDiv(float a) const
  {
    Vector3 result;
    result.x = x / a;
    result.y = y / a;
    result.z = z / a;

    return result; 
  }

  void opAssign(Vector2 vector)
  {
    x = vector.x;
    y = vector.y;
    z = 0;
  }
}