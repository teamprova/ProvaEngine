module prova.core.assetmanager;

import prova.interfaces : Asset;

///
class AssetManager {
  private Asset[string] assets;

  ///
  void store(string name, Asset asset) {
    assets[name] = asset;
  }

  ///
  void remove(string name) {
    assets.remove(name);
  }

  ///
  T get(T)(string name) {
    return cast(T) assets[name];
  }

  ///
  void clear() {
    assets.clear();
  }
}
