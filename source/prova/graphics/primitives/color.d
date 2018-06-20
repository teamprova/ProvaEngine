module prova.graphics.primitives.color;

///
struct Color
{
  ///
  float r = 1;
  ///
  float g = 1;
  ///
  float b = 1;
  ///
  float a = 1;

  ///
  this(float r, float g, float b)
  {
    set(r, g, b, 1);
  }

  ///
  this(float r, float g, float b, float a)
  {
    set(r, g, b, a);
  }

  /// Sets the values of r, g, and b in a single statement
  void set(float r, float g, float b)
  {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = 1;
  }

  /// Sets the values of r, g, b, and a in a single statement
  void set(float r, float g, float b, float a)
  {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  Color lerp(Color color, float a) const
  {
    color.r = (color.r + r) * a;
    color.g = (color.g + g) * a;
    color.b = (color.b + b) * a;
    color.a = (color.a + a) * a;

    return color;
  }

  invariant
  {
    // limit components to be [0-1]
    assert(r <= 1 && r >= 0);
    assert(g <= 1 && g >= 0);
    assert(b <= 1 && b >= 0);
    assert(a <= 1 && a >= 0);
  }
}
