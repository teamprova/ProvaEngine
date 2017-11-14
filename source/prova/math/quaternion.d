module prova.math.quaternion;

import prova.math,
       std.math;

///
struct Quaternion
{
  float x;
  float y;
  float z;
  float w;

  ///
  this(float x, float y, float z, float w)
  {
    set(x, y, z, w);
  }

  ///
  this(Vector3 axis, float w)
  {
    set(axis, w);
  }

  /// Sets the values of x, y, z, and w in a single statement
  void set(float x, float y, float z, float w)
  {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }

  ///
  void set(Vector3 axis, float w)
  {
    x = axis.x;
    y = axis.y;
    z = axis.z;
    this.w = w;
  }

  /// 
  void setAxis(float x, float y, float z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  /// 
  void setAxis(Vector3 axis)
  {
    x = axis.x;
    y = axis.y;
    z = axis.z;
  }

  /// Create a quaternion from euler angles in degrees
  static Quaternion fromEuler(Vector3 euler)
  {
    return fromEuler(euler.x, euler.y, euler.z);
  }

  /// Create a quaternion from euler angles in degrees
  static Quaternion fromEuler(float x, float y, float z)
  {
    x *= PI / 180;
    y *= PI / 180;
    z *= PI / 180;

    float cosX = cos(x);
    float sinX = sin(x);
    float cosY = cos(y);
    float sinY = sin(y);
    float cosZ = cos(z);
    float sinZ = sin(z);

    Quaternion result;
    result.w = cosZ * cosX * cosY + sinZ * sinX * sinY;
    result.x = cosZ * sinX * cosY - sinZ * cosX * sinY;
    result.y = cosZ * cosX * sinY + sinZ * sinX * cosY;
    result.z = sinZ * cosX * cosY - cosZ * sinX * sinY;
    return result;
  }

  /// Creates a normalized quaternion with a random rotation and axis
  static Quaternion random()
  {
    Quaternion result = Quaternion(
      randomF(1),
      randomF(1),
      randomF(1),
      randomF(1)
    );

    result.normalize();

    return result;
  }

  ///
  @property Vector3 xyz() const
  {
    return Vector3(x, y, z);
  }

  /// Returns a normalized copy of this quaternion
  Quaternion getNormalized() const
  {
    const float magnitude = getMagnitude();

    Quaternion result;

    if(magnitude != 0) {
      result.x = x / magnitude;
      result.y = y / magnitude;
      result.z = z / magnitude;
      result.w = w / magnitude;
    }

    return result;
  }

  /// Normalizes the quaternion
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

  /// Returns the magnitude of the quaternion
  float getMagnitude() const
  {
    return sqrt(x * x + y * y + z * z + w * w);
  }

  /**
   * Sets the magnitude of this quaternion
   *
   * If the previous magnitude is zero, the x value
   * of the quaternion will be set to the magnitude
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


  // assignment overloading
  Quaternion opAddAssign(Quaternion quaternion)
  {
    x += quaternion.x;
    y += quaternion.y;
    z += quaternion.z;
    w += quaternion.w;

    return this;
  }

  Quaternion opSubAssign(Quaternion quaternion)
  {
    x -= quaternion.x;
    y -= quaternion.y;
    z -= quaternion.z;
    w -= quaternion.w;

    return this;
  }

  Quaternion opMulAssign(float a)
  {
    x *= a;
    y *= a;
    z *= a;
    w *= a;

    return this;
  }

  Quaternion opDivAssign(float a)
  {
    x /= a;
    y /= a;
    z /= a;
    w /= a;

    return this;
  }


  // arithmetic overloading
  Quaternion opAdd(Quaternion quaternion) const
  {
    Quaternion result;
    result.x = x + quaternion.x;
    result.y = y + quaternion.y;
    result.z = z + quaternion.z;
    result.w = w + quaternion.w;

    return result;
  }

  Quaternion opSub(Quaternion quaternion) const
  {
    Quaternion result;
    result.x = x - quaternion.x;
    result.y = y - quaternion.y;
    result.z = z - quaternion.z;
    result.w = w - quaternion.w;

    return result; 
  }

  Quaternion opUnary(string s)() const if (s == "-")
  {
    Quaternion result;
    result.x = -x;
    result.y = -y;
    result.z = -z;
    result.w = -w;

    return result;
  }

  Quaternion opMul(float a) const
  {
    Quaternion result;
    result.x = x * a;
    result.y = y * a;
    result.z = z * a;
    result.w = w * a;

    return result; 
  }

  Vector3 opMul(Vector3 vector) const
  {
    // taken from:
    // https://blog.molecular-matters.com/2013/05/24/a-faster-quaternion-vector-multiplication/
    Vector3 t = 2 * xyz.cross(vector);
    return vector + w * t + xyz.cross(t);
  }

  Quaternion opMul(Quaternion quaternion) const
  {
    Vector3 crossProduct = xyz.cross(quaternion.xyz);
    float dotProduct = xyz.dot(quaternion.xyz);

    Vector3 axis = xyz * quaternion.w + quaternion.xyz * w + crossProduct;

    Quaternion result;
    result.setAxis(axis);
    result.w = (w * quaternion.w) - dotProduct;
    return result;
  }

  Quaternion opDiv(float a) const
  {
    Quaternion result;
    result.x = x / a;
    result.y = y / a;
    result.z = z / a;
    result.w = w / a;

    return result; 
  }
}