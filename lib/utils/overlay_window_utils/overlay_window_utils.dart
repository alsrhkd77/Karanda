import 'dart:developer' as developer;
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils_platform.dart'
    if (dart.library.io) 'package:karanda/utils/overlay_window_utils/overlay_window_utils_windows.dart';

class OverlayWindowUtils extends OverlayWindowUtilsPlatform {
  void setOverlayMode({required double width, required double height}) {
    try {
      final handle = getOverlayWindowHandle();
      setOverlay(handle, width, height);
    } on UnsupportedError catch (e) {
      developer.log('Unsupported ${e.message}', name: 'overlay utils');
    }
  }

  void enableEditMode() {
    try {
      final handle = getOverlayWindowHandle();
      enableClick(handle);
    } on UnsupportedError catch (e) {
      developer.log('Unsupported ${e.message}', name: 'overlay utils');
    }
  }

  void disableEditMode() {
    try {
      final handle = getOverlayWindowHandle();
      disableClick(handle);
    } on UnsupportedError catch (e) {
      developer.log('Unsupported ${e.message}', name: 'overlay utils');
    }
  }
}
