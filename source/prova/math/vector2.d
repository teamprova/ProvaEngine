module prova.math.vector2;

import prova.math,
       std.math;

///
struct Vector2
{
  ///
  float x = 0;
  ///
  float y = 0;

  ///
  this(float x, float y)
  {
    set(x, y);
  }

  /// Sets the values of x and y in a single statement
  void set(float x, float y)
  {
    this.x = x;
    this.y = y;
  }

  /// Creates a normalized vector with a random direction
  static Vector2 random()
  {
    Vector2 vector = Vector2(
      randomF(1),
      randomF(1)
    );

    vector.normalize();

    return vector;
  }

  /// Returns a normalized copy of this vector
  Vector2 getNormalized() const
  {
    const float magnitude = getMagnitude();

    Vector2 result;

    if(magnitude != 0) {
      result.x = x / magnitude;
      result.y = y / magnitude;
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
  }

  /// Returns the magnitude of the vector
  float getMagnitude() const
  {
    return sqrt(x * x + y * y);
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
  }

  /// Returns the direction of the vector in degrees
  float getDirection() const
  {
    return atan2(y, x) / PI * 180;
  }

  /**
   * Sets the direction of the vector using degrees
   *
   * Make sure the magnitude is not zero or this will not work
   */
  void setDirection(float angle)
  {
    const float magnitude = this.getMagnitude();
    angle *= PI / 180;

    y = sin(angle) * magnitude;
    x = cos(angle) * magnitude;
  }

  /// Returns the angle to the vector in degrees
  float angleTo(Vector2 vector) const
  {
    return atan2(vector.y - y, vector.x - x) / PI * 180;
  }

  /// Returns the distance between the vectors
  float distanceTo(Vector2 vector) const
  {
    const float a = vector.x - x;
    const float b = vector.y - y;

    return sqrt(a * a + b * b);
  }

  /// Returns the squared distance between the vectors
  float distanceToSquared(Vector2 vector) const
  {
    const float a = vector.x - x;
    const float b = vector.y - y;

    return a * a + b * b;
  }

  // Returns the dot product of the two vectors
  float dot(Vector2 vector)
  {
    return x * vector.x + y * vector.y;
  }


  // assignment overloading
  Vector2 opAddAssign(Vector2 vector)
  {
    x += vector.x;
    y += vector.y;

    return this;
  }

  Vector2 opSubAssign(Vector2 vector)
  {
    x -= vector.x;
    y -= vector.y;

    return this;
  }

  Vector2 opMulAssign(Vector2 vector)
  {
    x *= vector.x;
    y *= vector.y;

    return this;
  }

  Vector2 opMulAssign(float a)
  {
    x *= a;
    y *= a;

    return this;
  }

  Vector2 opDivAssign(float a)
  {
    x /= a;
    y /= a;

    return this;
  }


  // arithmetic overloading
  Vector2 opAdd(Vector2 vector) const
  {
    Vector2 result;
    result.x = x + vector.x;
    result.y = y + vector.y;

    return result;
  }

  Vector3 opAdd(Vector3 vector) const
  {
    Vector3 result;
    result.x = x + vector.x;
    result.y = y + vector.y;
    result.z = vector.z;

    return vector;
  }

  Vector2 opSub(Vector2 vector) const
  {
    Vector2 result;
    result.x = x - vector.x;
    result.y = y - vector.y;

    return result; 
  }

  Vector3 opSub(Vector3 vector) const
  {
    Vector3 result;
    result.x = x - vector.x;
    result.y = y - vector.y;
    result.z = vector.z;

    return result; 
  }

  Vector2 opUnary(string s)() const if (s == "-")
  {
    Vector2 result;
    result.x = -x;
    result.y = -y;

    return result;
  }

  Vector2 opMul(Vector2 vector) const
  {
    Vector2 result;
    result.x = x * vector.x;
    result.y = y * vector.y;

    return result; 
  }

  Vector2 opMul(float a) const
  {
    Vector2 result;
    result.x = x * a;
    result.y = y * a;

    return result; 
  }

  Vector2 opDiv(float a) const
  {
    Vector2 result;
    result.x = x / a;
    result.y = y / a;

    return result; 
  }
}