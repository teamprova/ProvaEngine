module prova.graphics.spritebatch;

import prova.assets;
import prova.attachables;
import prova.graphics;
import prova.math;
import prova.util;
import std.typecons;

///
final class SpriteBatch
{
  /// Copy of GraphicsContext.spriteShader
  ShaderProgram shaderProgram;
  private bool begun;
  private Mesh mesh;
  private GraphicsContext context;
  private RenderTarget renderTarget;
  private Matrix projection;
  private LinkedList!(Tuple!(Sprite, Matrix)) sprites;

  ///
  this(GraphicsContext context)
  {
    shaderProgram = context.spriteShader;

    sprites = new LinkedList!(Tuple!(Sprite, Matrix));

    mesh = new SpriteMesh();
  }

  ///
  void begin(RenderTarget renderTarget, Matrix projection)
  {
    assert(!begun, "Batch should not already be started");

    this.renderTarget = renderTarget;
    this.projection = projection;
    begun = true;
  }

  ///
  void batchSprite(AnimatedSprite sprite, Matrix transform)
  {
    sprite.update();

    batchSprite(cast(Sprite) sprite, transform);
  }

  ///
  void batchSprite(Sprite sprite, Matrix transform)
  {
    assert(begun, "Batch should have started with begin(RenderTarget, Matrix projection)");
    
    sprites.insertBack(tuple(sprite, transform));
  }

  /// Draws batched sprites
  void end()
  {
    assert(begun, "Batch should have started with begin(RenderTarget, Matrix projection)");

    Color lastTint;
    uint lastTexture = -1;

    // set the inital value for the tint
    shaderProgram.setVector4("tint", lastTint);

    foreach(Tuple!(Sprite, Matrix) spriteTuple; sprites) {
      Sprite sprite = spriteTuple[0];
      Matrix transform = spriteTuple[1];

      if(sprite.texture.id != lastTexture) {
        shaderProgram.setTexture(0, sprite.texture);
        lastTexture = sprite.texture.id;
      }

      if(sprite.tint != lastTint) {
        shaderProgram.setVector4("tint", sprite.tint);
        lastTint = sprite.tint;
      }
      
      drawSprite(sprite, transform);
    }

    sprites.clear();
    begun = false;
  }

  ///
  void drawSprite(Sprite sprite, Matrix transform)
  {
    Vector2 size = sprite.clip.getSize();
    Vector3 center = size / 2;

    Rect clip;
    clip.left = sprite.clip.left / sprite.texture.width;
    clip.top = 1 - (sprite.clip.top + sprite.clip.height) / sprite.texture.height;
    clip.width = sprite.clip.width / sprite.texture.width;
    clip.height = sprite.clip.height / sprite.texture.height;

    Matrix offset = Matrix.identity;
    offset = offset.scale(size);
    offset = offset.translate(-sprite.origin - center);

    shaderProgram.setMatrix("transform", projection * (transform * offset));
    shaderProgram.setVector4("clip", clip);
    shaderProgram.drawMesh(mesh, renderTarget, DrawMode.TRIANGLE_FAN);
  }
}
