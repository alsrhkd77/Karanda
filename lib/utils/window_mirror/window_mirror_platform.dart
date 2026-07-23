import 'dart:ui';

import 'package:karanda/model/window_info.dart';

abstract class WindowMirrorUtilsPlatform {
  /// 미러링 가능한 창 목록 (보이는 창 + 제목 있음 + 타 프로세스)
  List<WindowInfo> getMirrorableWindows() =>
      throw UnsupportedError('Platform unsupported.');

  /// DWM 썸네일 등록. 성공 시 썸네일 핸들, 실패 시 0 반환.
  int registerThumbnail({required int destination, required int source}) =>
      throw UnsupportedError('Platform unsupported.');

  /// DWM 썸네일 속성 갱신.
  /// [destination]은 오버레이 창 기준 물리 픽셀, [source]는 소스 창 클라이언트 기준 물리 픽셀.
  void updateThumbnail(
    int thumbnail, {
    required Rect destination,
    required Rect? source,
    required int opacity,
    required bool visible,
  }) =>
      throw UnsupportedError('Platform unsupported.');

  /// DWM 썸네일 해제.
  void unregisterThumbnail(int thumbnail) =>
      throw UnsupportedError('Platform unsupported.');

  /// 창 클라이언트 영역 크기 (물리 픽셀). 실패 시 null.
  Size? getClientSize(int hWnd) =>
      throw UnsupportedError('Platform unsupported.');

  /// 창 핸들 유효성 검사.
  bool isWindowValid(int hWnd) =>
      throw UnsupportedError('Platform unsupported.');
}
