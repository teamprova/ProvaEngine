module prova.math.random;

import std.random;

/// Returns a random float within [min, max$(RPAREN)
float randomF(float min, float max)
{
  return uniform(min, max);
}

/// Returns a random float within [0, max$(RPAREN)
float randomF(float max)
{
  return uniform(0, max);
}

/// Returns a random int within [min, max$(RPAREN)
int randomI(int min, int max)
{
  return uniform(min, max);
}

/// Returns a random int within [0, max$(RPAREN)
int randomI(int max)
{
  return uniform(0, max);
}