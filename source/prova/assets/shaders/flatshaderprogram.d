module prova.assets.shaders.flatshaderprogram;

import prova.assets;

/**
 * Uniforms:
 * - mat4 transform
 * - vec4 color
 */
class FlatShaderProgram : ShaderProgram
{
  ///
  this()
  {
    super();

    attachVertexShader(
      "#version 130
      uniform mat4 transform;
      in vec3 vertexPosition;

      void main() {
        gl_Position = transform * vec4(vertexPosition, 1);
      }"
    );

    attachFragmentShader(
      "#version 130
      uniform vec4 color;
      out vec4 fragmentColor;

      void main() {
        fragmentColor = color;
      }"
    );

    link();
  }
}
