import 'package:karanda/utils/window_mirror/window_mirror_platform.dart'
    if (dart.library.io) 'package:karanda/utils/window_mirror/window_mirror_windows.dart';

/// DWM Thumbnail 기반 창 미러링 유틸리티 (Windows 전용).
/// 다른 프로그램 창의 실시간 화면을 오버레이 창 영역에 GPU 합성으로 표시한다.
/// 호출측에서 플랫폼 가드(`Platform.isWindows`)를 확인한 뒤 사용한다.
class WindowMirrorUtils extends WindowMirrorUtilsPlatform {}
