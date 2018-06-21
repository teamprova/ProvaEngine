module prova.graphics.shapes.circlemesh;

import prova.graphics;
import prova.math;

///
class CircleMesh : Mesh
{
  ///
  this(float radius, int segments)
  {
    float[] vertices;
    uint[] indexes;

    indexes.length = segments + 1;
    vertices.length = indexes.length * 2;

    foreach(i; 0 .. indexes.length)
    {
      Vector2 point;
      point.setMagnitude(radius);
      point.setDirection(i * 360 / segments);

      vertices[i * 2] = point.x;
      vertices[i * 2 + 1] = point.y;
      indexes[i] = cast(uint) i;
    }

    setVBO(vertices, 2);
    setIBO(indexes);
  }
}
