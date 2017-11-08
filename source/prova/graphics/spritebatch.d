module prova.graphics.spritebatch;

import prova.graphics,
       prova.math,
       prova.util.linkedlist;

///
class SpriteBatch
{
  private static ShaderProgram defaultShaderProgram;
  /// SpriteShaderProgram by default
  ShaderProgram shaderProgram;
  private bool begun;
  private Mesh mesh;
  private Matrix projection;
  private LinkedList!(Sprite) spritePrimitives;
  private LinkedList!(Vector3) positions;

  ///
  this()
  {
    if(!defaultShaderProgram)
      defaultShaderProgram = new SpriteShaderProgram();

    shaderProgram = defaultShaderProgram;

    spritePrimitives = new LinkedList!(Sprite);
    positions = new LinkedList!(Vector3);

    float[] vertices = [
      0, 0, 0, 1,
      1, 0, 0, 1,
      1, 1, 0, 1,
      0, 1, 0, 1
    ];

    uint[] indexes = [ 0, 1, 2, 3 ];

    mesh = new Mesh();
    mesh.setIBO(indexes);
    mesh.setVBO(vertices, 4);
  }

  ///
  void begin(Matrix transform)
  {
    if(begun)
      throw new Exception("Batch already started");

    projection = transform;
    begun = true;
  }

  ///
  void batchSprite(AnimatedSprite sprite, Vector3 position)
  {
    sprite.update();

    batchSprite(cast(Sprite) sprite, position);
  }

  ///
  void batchSprite(Sprite sprite, Vector3 position)
  {
    if(!begun)
      throw new Exception("Batch not started");
    
    spritePrimitives.insertBack(sprite);
    positions.insertBack(position);
  }

  /// Draws batched sprites
  void end()
  {
    if(!begun)
      throw new Exception("Batch not started");

    Color lastTint;
    uint lastTexture = -1;
    Node!Sprite spriteNode = spritePrimitives.getFirstNode();
    Node!Vector3 positionNode = positions.getFirstNode();

    // set the inital value for the tint
    shaderProgram.setVector4("tint", lastTint);

    foreach(i; 0 .. spritePrimitives.length) {
      Sprite sprite = spriteNode.getValue();
      Vector3 position = positionNode.getValue();

      if(sprite.texture.id != lastTexture) {
        shaderProgram.setTexture(0, sprite.texture);
        lastTexture = sprite.texture.id;
      }

      if(sprite.tint != lastTint) {
        shaderProgram.setVector4("tint", sprite.tint);
        lastTint = sprite.tint;
      }
      
      drawSprite(sprite, position);

      spriteNode = spriteNode.getNext();
      positionNode = positionNode.getNext();
    }

    spritePrimitives.clear();
    positions.clear();
    begun = false;
  }

  ///
  void drawSprite(Sprite sprite, Vector3 position)
  {
    Matrix transform = Matrix.identity();
    transform = transform.scale(sprite.width, sprite.height, 1);
    transform = transform.translate(-sprite.origin);
    transform = transform.scale(sprite.scale);
    transform = transform.rotateZ(sprite.angle);
    transform = transform.translate(position.x, position.y, position.z);

    shaderProgram.setMatrix("transform", projection * transform);
    shaderProgram.setVector4("clip", sprite.clip);
    shaderProgram.drawMesh(DrawMode.TRIANGLE_FAN, mesh);
  }
}