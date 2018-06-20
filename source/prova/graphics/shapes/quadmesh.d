module prova.graphics.shapes.quadmesh;

import prova.graphics,
       prova.math;

///
class QuadMesh : Mesh
{
  ///
  this(float width, float height)
  {
    float halfWidth = width / 2;
    float halfHeight = height / 2;
    float[] vertices = [
      -halfWidth, -halfHeight, 
      halfWidth, -halfHeight,
      halfWidth, halfHeight,
      -halfWidth, halfHeight
    ];

    uint[] indexes = [0, 1, 2, 0, 2, 3];

    setVBO(vertices, 2);
    setIBO(indexes);
  }
}
