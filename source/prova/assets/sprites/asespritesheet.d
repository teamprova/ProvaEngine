module prova.assets.sprites.asespritesheet;

import prova.assets;
import std.json;
import std.file;
import std.path;

/// Uses sprite sheets generated from Aseprite
class AseSpriteSheet : SpriteSheet
{
  /**
   * JSON file should have the same name and be in the same folder
   * 
   * Params:
   *   path = Path of the image file
   */
  this(string path)
  {
    string jsonPath = stripExtension(path) ~ ".json";
    string jsonString = readText(jsonPath);
    JSONValue json = parseJSON(jsonString);

    JSONValue framesObject = json["frames"];
    JSONValue metaObject = json["meta"].object;
    JSONValue frameTagsObject = metaObject["frameTags"];

    frames = getFrames(framesObject);
    animations = getAnimations(frameTagsObject, frames);
    texture = new Texture(path);
  }

  private SpriteFrame[] getFrames(JSONValue framesObject)
  {
    SpriteFrame[] frames;

    if(framesObject.type != JSON_TYPE.ARRAY)
      throw new Exception("\"frames\" should be an array");

    foreach(JSONValue frameObject; framesObject.array)
      frames ~= readFrame(frameObject);

    return frames;
  }

  private SpriteFrame readFrame(JSONValue frameObject)
  {
    SpriteFrame frame;

    JSONValue clipObject = frameObject["frame"];

    frame.clip.left = clipObject["x"].integer;
    frame.clip.top = clipObject["y"].integer;
    frame.clip.width = clipObject["w"].integer;
    frame.clip.height = clipObject["h"].integer;

    frame.duration = frameObject["duration"].integer / 1000f;

    return frame;
  }

  private SpriteAnimation[string] getAnimations(JSONValue frameTagsObject, SpriteFrame[] frames)
  {
    SpriteAnimation[string] animations;

    foreach(JSONValue value; frameTagsObject.array)
    {
      string name = value["name"].str;
      long start = value["from"].integer;
      long end = value["to"].integer + 1;

      animations[name] = new SpriteAnimation(name, frames[start .. end]);
    }

    return animations;
  }
}
