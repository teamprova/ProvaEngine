module prova.graphics.color;

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

  /// Hex string starting with a #
  this(string hex)
  {
    import std.conv : to;

    r = to!int(hex[1..3], 16) / 255f;
    g = to!int(hex[3..5], 16) / 255f;
    b = to!int(hex[5..7], 16) / 255f;

    if(hex.length == 9) {
      a = to!int(hex[7..9], 16) / 255f;
    }
  }

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

  invariant
  {
    // limit components to be [0-1]
    assert(r <= 1 && r >= 0);
    assert(g <= 1 && g >= 0);
    assert(b <= 1 && b >= 0);
    assert(a <= 1 && a >= 0);
  }
}

///
Color lerp(Color from, Color to, float a)
{
  return Color(
    from.r * (1 - a) + to.r * a,
    from.g * (1 - a) + to.g * a,
    from.b * (1 - a) + to.b * a,
    from.a * (1 - a) + to.a * a,
  );
}

unittest {
  auto red = Color(1, 0, 0);
  auto blue = Color(0, 0, 1);

  assert(lerp(red, blue, .5) == Color(.5, 0, .5));
  assert(lerp(red, blue, .75) == Color(.25, 0, .75));
}
