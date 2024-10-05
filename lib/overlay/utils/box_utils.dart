import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class BoxUtils {
  static Future<Rect?> loadBoxRect(String key) async {
    final instance = await SharedPreferences.getInstance();
    double? left = instance.getDouble("${key}_rect_left");
    double? top = instance.getDouble("${key}_rect_top");
    double? width = instance.getDouble("${key}_rect_width");
    double? height = instance.getDouble("${key}_rect_height");
    if(left == null || top == null || width == null || height == null ){
      return null;
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  static Future<void> saveRect(String key, Rect rect) async {
    final instance = await SharedPreferences.getInstance();
    instance.setDouble("${key}_rect_left", rect.left);
    instance.setDouble("${key}_rect_top", rect.top);
    instance.setDouble("${key}_rect_width", rect.width);
    instance.setDouble("${key}_rect_height", rect.height);
  }
}