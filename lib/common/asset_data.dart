import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class AssetData {
  static Future<ByteData> load(String path) async {
    path = _fixPath(path);
    return await rootBundle.load(path);
  }

  static Future<String> loadString(String path) async {
    path = _fixPath(path);
    return await rootBundle.loadString(path);
  }

  static _fixPath(String path){
    if(!kIsWeb){
      path = path.replaceAll('\\\\', '/').replaceAll('\\', '/');
    }
    return path;
  }
}
