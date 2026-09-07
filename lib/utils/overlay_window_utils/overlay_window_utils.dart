import 'dart:ui';

import 'package:karanda/utils/overlay_window_utils/overlay_window_utils_platform.dart'
    if (dart.library.io) 'package:karanda/utils/overlay_window_utils/overlay_window_utils_windows.dart';
import 'package:logging/logging.dart';

/// 오버레이 창 제어 운영 로그.
final _log = Logger('overlay');

/// 오버레이 창 배치 결과.
///
/// [actual]은 실제로 적용된 창 영역(조회 실패 시 null), [corrected]는 요청과 어긋난 창을
/// 다시 배치했는지 여부다. 호출측이 운영 로그로 남겨 배치 실패를 사후 진단할 수 있게 한다.
class OverlayBoundsResult {
  final Rect? actual;
  final bool corrected;

  const OverlayBoundsResult({this.actual, this.corrected = false});
}

class OverlayWindowUtils extends OverlayWindowUtilsPlatform {
  /// 오버레이 창을 [rect](물리 픽셀)에 배치하고 투명·클릭 통과 모드를 적용한다.
  OverlayBoundsResult setOverlayMode({required Rect rect}) {
    try {
      final handle = getOverlayWindowHandle();
      if (handle == 0) return const OverlayBoundsResult();
      setOverlay(handle, rect);
      return _ensureBounds(handle, rect);
    } on UnsupportedError catch (e) {
      _log.fine('Unsupported: ${e.message}');
      return const OverlayBoundsResult();
    }
  }

  /// 배치 후 뒤늦게 도착한 DPI 변경까지 흡수하기 위한 재검증.
  ///
  /// 창 이동 직후가 아니라 잠시 뒤 `WM_DPICHANGED`가 처리되면 창 크기가 다시 조정될 수 있다.
  /// 어긋나 있으면 한 번 더 배치한다.
  OverlayBoundsResult ensureOverlayBounds(Rect rect) {
    try {
      final handle = getOverlayWindowHandle();
      if (handle == 0) return const OverlayBoundsResult();
      return _ensureBounds(handle, rect);
    } on UnsupportedError catch (e) {
      _log.fine('Unsupported: ${e.message}');
      return const OverlayBoundsResult();
    }
  }

  /// 실제 창 영역을 되읽어 요청과 다르면 한 번 더 배치한다. 맞으면 아무것도 하지 않는다.
  OverlayBoundsResult _ensureBounds(int handle, Rect rect) {
    final bounds = getWindowBounds(handle);
    if (bounds == null || _matches(bounds, rect)) {
      return OverlayBoundsResult(actual: bounds);
    }
    applyBounds(handle, rect);
    return OverlayBoundsResult(actual: getWindowBounds(handle), corrected: true);
  }

  /// 창 영역 비교. 두 값 모두 정수 물리 픽셀이므로 허용 오차를 두지 않는다.
  bool _matches(Rect a, Rect b) {
    return a.left.round() == b.left.round() &&
        a.top.round() == b.top.round() &&
        a.width.round() == b.width.round() &&
        a.height.round() == b.height.round();
  }

  void enableEditMode() {
    try {
      final handle = getOverlayWindowHandle();
      enableClick(handle);
    } on UnsupportedError catch (e) {
      _log.fine('Unsupported: ${e.message}');
    }
  }

  void disableEditMode() {
    try {
      final handle = getOverlayWindowHandle();
      disableClick(handle);
    } on UnsupportedError catch (e) {
      _log.fine('Unsupported: ${e.message}');
    }
  }
}
