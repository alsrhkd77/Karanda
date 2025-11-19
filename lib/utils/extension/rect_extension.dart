import 'dart:ui';

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