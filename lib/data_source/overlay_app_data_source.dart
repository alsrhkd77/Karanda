import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class OverlayAppDataSource {
  Future<void> saveRect(String key, Rect rect) async {
    final pref = SharedPreferencesAsync();
    await pref.setString("$key-overlay-rect", jsonEncode(rect.toJson()));
  }

  Future<Rect?> loadRect(String key) async {
    final pref = SharedPreferencesAsync();
    final json = await pref.getString("$key-overlay-rect");
    if (json != null) {
      final data = jsonDecode(json);
      return Rect.fromLTWH(
        data["left"],
        data["top"],
        data["width"],
        data["height"],
      );
    }
    return null;
  }
}

extension RectExtension on Rect {
  Map toJson() {
    return {
      "left": left,
      "top": top,
      "width": width,
      "height": height,
    };
  }
}
