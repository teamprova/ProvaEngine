// todo: cleanup this

module prova.graphics.bdffont;

import prova.graphics,
       prova.math,
       std.array,
       std.conv,
       std.math,
       std.stdio;

///
class BDFFont : Font
{
  alias Bitmap = ubyte[][];

  ///
  this(string path)
  {
    load(path);
  }

  private void load(string path)
  {
    File file = File(path, "r");

    Bitmap[int] bitmaps;
    int defaultWidth, defaultHeight, glyphCount;
    int glyphsAdded = 0, totalHeight = 0;
    Vector2 defaultOffset;
    Glyph glyph;
    Bitmap bitmap;

    while(!file.eof)
    {
      string line = file.readln();

      if(line.length == 0)
        continue;

      string[] words = to!string(line).split;

      const string keyword = words[0];

      if(keyword == "STARTCHAR")
      {
        // reset glyph to default
        glyph.offset = defaultOffset;
        glyph.width = defaultWidth;
        glyph.height = defaultHeight;
      }
      else if(keyword == "ENCODING")
      {
        glyph.encoding = to!int(words[1]);
      }
      else if(keyword == "DWIDTH" || keyword == "DWIDTH1")
      {
        glyph.shift.x = to!float(words[1]);
        glyph.shift.y = to!float(words[2]);
      }
      else if(keyword == "BBX")
      {
        glyph.width = to!int(words[1]);
        glyph.height = to!int(words[2]);
        glyph.offset.x = to!float(words[3]);
        glyph.offset.y = to!float(words[4]);
      }
      else if(keyword == "BITMAP")
      {
        bitmap = getBitmap(file, glyph.height);
      }
      else if(keyword == "ENDCHAR")
      {
        // copy this glyph to the glyph map
        glyphs[glyph.encoding] = glyph;
        
        // copy its bitmap
        bitmaps[glyph.encoding] = bitmap;

        // finding the tallest glyph
        if(glyph.height > _maxHeight)
          _maxHeight = glyph.height;

        // add height to the total for later stitching/compression
        totalHeight += glyph.height;

        ++glyphsAdded;
      }
      // defaults
      else if(keyword == "FONTBOUNDINGBOX") {
        defaultWidth = to!int(words[1]);
        defaultHeight = to!int(words[2]);
        defaultOffset.x = to!float(words[3]);
        defaultOffset.y = to!float(words[4]);
      }
      else if(keyword == "CHARS") {
        glyphCount = to!int(words[1]);
      }
    }

    file.close();
    
    totalHeight = cast(int)(totalHeight / sqrt(cast(float) glyphCount) + 1);
    stitchTexture(bitmaps, totalHeight);
  }

  private Bitmap getBitmap(File file, int height)
  {
    Bitmap bitmap;
    bitmap.length = height;

    foreach(i; 0 .. height)
    {
      if(file.eof)
        throw new Exception("Unexpected end of file while reading bitmap");

      string line = file.readln();

      int byteCount = cast(int) line.length / 2;
      ubyte[] row;
      row.length = byteCount;

      // convert hex to byte and emplace
      foreach(j; 0 .. byteCount)
      {
        ubyte Byte = 0;

        foreach(k; 0 .. 2)
        {
          Byte <<= 4;

          const ubyte hex = line[j * 2 + k];

          if(hex >= 'A' && hex <= 'F')
            Byte += hex - 'A' + 10;
          else
            Byte += hex - '0';
        }

        row[j] = Byte;
      }

      bitmap[i] = row;
    }

    return bitmap;
  }

  private void stitchTexture(Bitmap[int] glyphBitmaps, int textureHeight)
  {
    int top = 0, left = 0, textureWidth = 0;
    Bitmap textureBitmap;
    textureBitmap.length = textureHeight;

    foreach(charCode; glyphBitmaps.byKey())
    {
      Bitmap glyphBitmap = glyphBitmaps[charCode];
      Glyph glyph = glyphs[charCode];

      int glyphHeight = cast(int) glyphBitmap.length;
      int glyphWidth = cast(int) glyphBitmap[0].length * 8;

      if(textureHeight < top + glyphHeight) {
        // move the placement position to prevent overflow
        left = textureWidth;
        top = 0;
      }

      // resize the texture if the bitmap is overflowing
      if(textureWidth < left + glyphWidth)
        textureWidth = left + glyphWidth;

      stampGlyph(
        glyphBitmap, glyphWidth, glyphHeight,
        textureBitmap, textureHeight,
        left, top
      );

      // update position
      top += glyphHeight;

      // update glyph's clipping
      glyph.clip.left = left;
      glyph.clip.top = top;
      glyphs[charCode] = glyph;
    }

    // adjust glyph clipping to be percentage based
    // rather than pixel based
    foreach(ref glyph; glyphs)
    {
      glyph.clip.left /= textureWidth;
      glyph.clip.top /= textureHeight;
      glyph.clip.width = glyph.width / cast(float) textureWidth;
      glyph.clip.height = glyph.height / cast(float) textureHeight;
      glyph.clip.top = 1 - glyph.clip.top;
    }

    createTexture(textureBitmap, textureWidth, textureHeight);
  }

  private void stampGlyph(
    ref Bitmap glyphBitmap, int glyphWidth, int glyphHeight,
    ref Bitmap textureBitmap, int textureHeight,
    int left, int top
  ) {
    // set texture data
    foreach(i; 0 .. glyphHeight)
    {
      ubyte[] glyphRow = glyphBitmap[i];
      ubyte[] cellRow;
      int bitmapIndex = textureHeight - (top + i) - 1;

      // pad left to align
      cellRow.length = left * 4 - textureBitmap[bitmapIndex].length;

      // loop through bytes
      foreach(j; 0 .. glyphWidth / 8)
      {
        const ubyte Byte = glyphRow[j];
        
        // loop through bits
        foreach_reverse(k; 0 .. 8)
        {
          const bool bit = (Byte >> k) & 1;

          // Fill the 4 RGBA channels
          foreach(l; 0 .. 4)
            cellRow ~= bit ? 255 : 0;
        }
      }

      textureBitmap[bitmapIndex] ~= cellRow;
    }
  }

  private void createTexture(Bitmap bitmap, int width, int height)
  {
    ubyte[] textureData;
    ubyte[] padding;

    textureData.reserve(width * height * 4);

    foreach(ubyte[] row; bitmap) {
      textureData ~= row;

      padding.length = width * 4 - row.length;
      textureData ~= padding;
    }

    texture = new Texture(textureData, width, height);
  }
}