module prova.graphics.shapes.linemesh;

import prova.graphics;
import prova.math;

///
class LineMesh : Mesh
{
  private Vector3 _start;
  private Vector3 _end;

  ///
  this()
  {
    this(Vector3(), Vector3());
  }

  ///
  this(Vector3 start, Vector3 end)
  {
    uint[] indexes = [0, 1];

    setIBO(indexes);
    set(start, end);
  }

  ///
  @property Vector3 start()
  {
    return _start;
  }

  ///
  @property Vector3 end()
  {
    return _end;
  }

  ///
  void set(Vector3 start, Vector3 end)
  {
    float[] vertices = [
      start.x, start.y, start.z,
      end.x, end.y, end.z
    ];

    setVBO(vertices, 3);

    _start = start;
    _end = end;
  }

  ///
  void setStart(float x, float y, float z)
  {
    Vector3 start = Vector3(x, y, z);
    set(start, _end);
  }

  ///
  void setStart(Vector3 start)
  {
    set(start, _end);
  }

  ///
  void setEnd(float x, float y, float z)
  {
    Vector3 end = Vector3(x, y, z);
    set(_start, end);
  }

  ///
  void setEnd(Vector3 end)
  {
    set(_start, end);
  }
}
