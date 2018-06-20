module prova.math.vector4;

import prova.math,
       std.math;

///
struct Vector4
{
  ///
  float x = 0;
  ///
  float y = 0;
  ///
  float z = 0;
  ///
  float w = 0;

  ///
  this(float x, float y, float z, float w)
  {
    set(x, y, z, w);
  }

  ///
  this(Vector3 vector)
  {
    set(vector.x, vector.y, vector.z, 0);
  }

  ///
  this(Vector2 vector)
  {
    set(vector.x, vector.y, 0, 0);
  }

  /// Sets the values of x, y, z, and w in a single statement
  void set(float x, float y, float z, float w)
  {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }

  /// Creates a normalized vector with a random direction
  static Vector4 random()
  {
    Vector4 vector = Vector4(
      randomF(1),
      randomF(1),
      randomF(1),
      randomF(1)
    );

    vector.normalize();

    return vector;
  }

  /// Returns a normalized copy of this vector
  Vector4 getNormalized() const
  {
    const float magnitude = getMagnitude();

    Vector4 result;
    
    if(magnitude != 0) {
      result.x = x / magnitude;
      result.y = y / magnitude;
      result.z = z / magnitude;
      result.w = w / magnitude;
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
    w = w / magnitude;
  }

  /// Returns the magnitude of the vector
  float getMagnitude() const
  {
    return sqrt(x * x + y * y + z * z + w * w);
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
    w *= magnitude;
  }

  /// Returns the distance between the vectors
  float distanceTo(Vector4 vector) const
  {
    const float a = vector.x - x;
    const float b = vector.y - y;
    const float c = vector.z - z;
    const float d = vector.w - w;

    return sqrt(a * a + b * b + c * c + d * d);
  }

  /// Returns the squared distance between the vectors
  float distanceToSquared(Vector4 vector) const
  {
    const float a = vector.x - x;
    const float b = vector.y - y;
    const float c = vector.z - z;
    const float d = vector.w - w;

    return a * a + b * b + c * c + d * d;
  }

  /// Returns the dot product of the two vectors
  float dot(Vector4 vector)
  {
    return x * vector.x + y * vector.y + z * vector.z + w * vector.w;
  }


  // assignment overloading
  Vector4 opAddAssign(Vector4 vector)
  {
    x += vector.x;
    y += vector.y;
    z += vector.z;
    w += vector.w;

    return this;
  }

  Vector4 opSubAssign(Vector4 vector)
  {
    x -= vector.x;
    y -= vector.y;
    z -= vector.z;
    w -= vector.w;

    return this;
  }

  Vector4 opMulAssign(Vector4 vector)
  {
    x *= vector.x;
    y *= vector.y;
    z *= vector.z;
    w *= vector.w;

    return this;
  }

  Vector4 opMulAssign(float a)
  {
    x *= a;
    y *= a;
    z *= a;
    w *= a;

    return this;
  }

  Vector4 opDivAssign(float a)
  {
    x /= a;
    y /= a;
    z /= a;
    w /= a;

    return this;
  }


  // arithmetic overloading
  Vector4 opAdd(Vector4 vector) const
  {
    Vector4 result;
    result.x = x + vector.x;
    result.y = y + vector.y;
    result.z = z + vector.z;
    result.w = w + vector.w;

    return result;
  }

  Vector4 opSub(Vector4 vector) const
  {
    Vector4 result;
    result.x = x - vector.x;
    result.y = y - vector.y;
    result.z = z - vector.z;
    result.w = w - vector.w;

    return result; 
  }

  Vector4 opUnary(string s)() const if (s == "-")
  {
    Vector4 result;
    result.x = -x;
    result.y = -y;
    result.z = -z;
    result.w = -w;

    return result;
  }

  Vector4 opMul(Vector4 vector) const
  {
    Vector4 result;
    result.x = x * vector.x;
    result.y = y * vector.y;
    result.z = z * vector.z;
    result.w = w * vector.w;

    return result; 
  }

  Vector4 opMul(float a) const
  {
    Vector4 result;
    result.x = x * a;
    result.y = y * a;
    result.z = z * a;
    result.w = w * a;

    return result; 
  }

  Vector4 opDiv(float a) const
  {
    Vector4 result;
    result.x = x / a;
    result.y = y / a;
    result.z = z / a;
    result.w = w / a;

    return result; 
  }

  void opAssign(Vector2 vector)
  {
    x = vector.x;
    y = vector.y;
    z = 0;
    w = 0;
  }

  void opAssign(Vector3 vector)
  {
    x = vector.x;
    y = vector.y;
    z = vector.z;
    w = 0;
  }
}
