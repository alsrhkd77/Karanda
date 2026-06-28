import 'dart:developer' as developer;
import 'dart:ui';
import 'package:karanda/utils/overlay_window_utils/overlay_window_utils_platform.dart'
    if (dart.library.io) 'package:karanda/utils/overlay_window_utils/overlay_window_utils_windows.dart';

class OverlayWindowUtils extends OverlayWindowUtilsPlatform {
  /// 표시 전: 위치/크기/팝업/투명(DWM 글래스)만 적용한다. 레이어드(클릭스루)는
  /// 표시 후 [enableClickThroughMode]에서 적용한다.
  void prepareOverlayMode({required Rect rect}) {
    try {
      final handle = getOverlayWindowHandle();
      prepareOverlay(handle, rect);
    } on UnsupportedError catch (e) {
      developer.log('Unsupported ${e.message}', name: 'overlay utils');
    }
  }

  /// 표시 후: 레이어드 + 클릭스루를 적용한다.
  void enableClickThroughMode() {
    try {
      final handle = getOverlayWindowHandle();
      enableClickThrough(handle);
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
