module prova.assets.shaders.shaderprogram;

import prova.graphics;
import prova.assets;
import prova.math;
import std.conv;
import std.file;
import std.stdio;
import std.string;

///
enum DrawMode : uint {
  POINTS = 0,
  LINES = 1,
  LINE_LOOP = 2,
  LINE_STRIP = 3,
  TRIANGLES = 4,
  TRIANGLE_STRIP = 5,
  TRIANGLE_FAN = 6
}

///
class ShaderProgram : Asset
{
  private static uint currentId = -1;
  private uint[] shaders;
  private int _id;

  ///
  this()
  {
    _id = glCreateProgram();
  }

  ///
  final @property int id()
  {
    return _id;
  }

  private void useProgram()
  {
    if(currentId == _id)
      return;

    currentId = _id;
    glUseProgram(_id);
  }

  ///
  final uint getAttribute(string name)
  {
    const uint location = glGetAttribLocation(_id, toStringz(name));

    assert(location != -1, "Attribute " ~ name ~ " should have a location in shader");

    return location;
  }

  ///
  final uint getUniform(string name)
  {
    const uint location = glGetUniformLocation(_id, toStringz(name));

    assert(location != -1, "Uniform " ~ name ~ " should have a location in shader");

    return location;
  }

  ///
  final void setVector2(string name, Vector2 vector)
  {
    useProgram();

    const uint location = getUniform(name);
    glUniform2f(location, vector.x, vector.y);
  }

  ///
  final void setVector3(string name, Vector3 vector)
  {
    useProgram();

    const uint location = getUniform(name);
    glUniform3f(location, vector.x, vector.y, vector.z);
  }

  ///
  final void setVector4(string name, Vector4 vector)
  {
    useProgram();

    const uint location = getUniform(name);
    glUniform4f(location, vector.x, vector.y, vector.z, vector.w);
  }

  ///
  final void setVector4(string name, Rect rect)
  {
    useProgram();

    const uint location = getUniform(name);
    glUniform4f(location, rect.left, rect.top, rect.width, rect.height);
  }

  ///
  final void setVector4(string name, Color color)
  {
    useProgram();

    const uint location = getUniform(name);
    glUniform4f(location, color.r, color.g, color.b, color.a);
  }

  ///
  final void setMatrix(string name, Matrix matrix)
  {
    useProgram();

    const uint location = getUniform(name);
    glUniformMatrix4fv(location, 1, true, matrix.array[0].ptr);
  }

  ///
  final void setTexture(int sampler, Texture texture)
  {
    useProgram();

    glActiveTexture(GL_TEXTURE0 + sampler);
    texture.bind();
  }

  ///
  final void setTexture(int sampler, uint texture)
  {
    useProgram();

    glActiveTexture(GL_TEXTURE0 + sampler);
    Texture.bind(texture);
  }

  ///
  final void setTexture(string name, Texture texture)
  {
    setTexture(name, texture.id);
  }

  ///
  final void setTexture(string name, uint texture)
  {
    useProgram();

    const uint location = getUniform(name);
    glActiveTexture(location);
    Texture.bind(texture);
  }

  ///
  final void drawMesh(Mesh mesh, RenderTarget target, DrawMode mode)
  {
    target.bindFrameBuffer();
    useProgram();

    glBindVertexArray(mesh.VAO);
    glDrawElements(mode, mesh.indexCount, GL_UNSIGNED_INT, null);
  }

  ///
  final void drawMesh(Mesh mesh, uint frameBufferId, DrawMode mode)
  {
    RenderTarget.bindFrameBuffer(frameBufferId);
    useProgram();

    glBindVertexArray(mesh.VAO);
    glDrawElements(mode, mesh.indexCount, GL_UNSIGNED_INT, null);
  }

  ///
  final void loadVertexShader(string sourceFile)
  {
    loadShader(GL_VERTEX_SHADER, sourceFile);
  }

  ///
  final void loadFragmentShader(string sourceFile)
  {
    loadShader(GL_FRAGMENT_SHADER, sourceFile);
  }

  ///
  final void attachVertexShader(string source)
  {
    compileShader(GL_VERTEX_SHADER, source);
  }

  ///
  final void attachFragmentShader(string source)
  {
    compileShader(GL_FRAGMENT_SHADER, source);
  }

  ///
  final void link()
  {
    glLinkProgram(_id);

    //Check for errors
    int programSuccess;
    glGetProgramiv(_id, GL_LINK_STATUS, &programSuccess);

    if(programSuccess == true)
      return;

    printProgramLog();
    throw new Exception("Error linking program");
  }

  ///
  final void loadShader(uint shaderType, string sourceFile)
  {
    string contents = readText(sourceFile);

    compileShader(shaderType, contents);
  }

  private void compileShader(uint shaderType, string source)
  {
    uint shader = glCreateShader(shaderType);

    const char*[] shaderSource = [toStringz(source)];

    glShaderSource(shader, 1, shaderSource.ptr, null);
    glCompileShader(shader);

    int successfulCompilation;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &successfulCompilation);

    if(successfulCompilation != true) {
      printShaderLog(shader);
      throw new Exception("Unable to compile shader");
    }

    glAttachShader(_id, shader);

    shaders ~= shader;
  }

  ///
  final void printProgramLog()
  {
    int infoLogLength = 0;
    int maxLength = 0;

    glGetProgramiv(_id, GL_INFO_LOG_LENGTH, &maxLength);

    char[] infoLog;
    infoLog.length = maxLength;

    glGetProgramInfoLog(_id, maxLength, &infoLogLength, infoLog.ptr);

    if(infoLogLength > 0)
      writeln(infoLog);
  }

  ///
  final void printShaderLog(uint shader)
  {
    int infoLogLength = 0;
    int maxLength = 0;
    
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &maxLength);
    
    char[] infoLog;
    infoLog.length = maxLength;

    glGetShaderInfoLog(shader, maxLength, &infoLogLength, infoLog.ptr);

    if(infoLogLength > 0)
      writeln(infoLog);
  }

  ~this()
  {
    foreach(uint shader; shaders) {
      glDetachShader(_id, shader);
      glDeleteShader(shader);
    }

    glDeleteProgram(_id);
  }
}
