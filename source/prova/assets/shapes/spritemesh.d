module prova.assets.shapes.spritemesh;

import prova.assets;

/// Similar to QuadMesh, but not centered
class SpriteMesh : Mesh
{
  ///
  this()
  {
    float[] vertices = [
      0, 0, 
      1, 0,
      1, 1,
      0, 1
    ];

    uint[] indexes = [0, 1, 2, 3];

    setVBO(vertices, 2);
    setIBO(indexes);
  }
}
