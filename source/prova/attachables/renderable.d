module prova.attachables.renderable;

import prova.graphics;
import prova.math;

interface Renderable
{
  void draw(RenderTarget renderTarget, Matrix transform);
}
