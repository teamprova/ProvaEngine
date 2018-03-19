module prova.graphics.primitives.mesh;

import prova.graphics,
       prova.math;

///
class Mesh
{
  ///
  uint VAO;
  private uint VBO = -1;
  private uint IBO = -1;
  package(prova) int indexCount;

  ///
  this()
  {
    glGenVertexArrays(1, &VAO);
  }

  ///
  final void setVBO(float[] vertices, int dimensions)
  {
    glBindVertexArray(VAO);
    createBuffer(VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);
    glVertexAttribPointer(0, dimensions, GL_FLOAT, GL_FALSE, 0, null);
    glEnableVertexAttribArray(0);
  }

  ///
  final void setIBO(uint[] indexes)
  {
    indexCount = cast(int) indexes.length;

    glBindVertexArray(VAO);
    createBuffer(IBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexes.length * uint.sizeof, indexes.ptr, GL_STATIC_DRAW);
  }

  private void createBuffer(ref uint buffer)
  {
    // delete old buffers
    if(buffer != -1)
      glDeleteBuffers(1, &buffer);

    // create a new buffer
    glGenBuffers(1, &buffer);
  }

  ~this()
  {
    glDeleteVertexArrays(1, &VAO);

    if(VBO != -1)
      glDeleteBuffers(1, &VBO);
    if(IBO != -1)
      glDeleteBuffers(1, &IBO);
  }
}