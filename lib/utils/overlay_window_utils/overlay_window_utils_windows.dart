import 'dart:ffi';
import 'dart:ui' show Rect;

import 'package:ffi/ffi.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:logging/logging.dart';
import 'package:win32/win32.dart';

/// 오버레이 창·모니터 제어 운영 로그.
final _log = Logger('overlay');

abstract class OverlayWindowUtilsPlatform {
  int getOverlayWindowHandle() {
    // TEXT()는 호출마다 네이티브 메모리를 새로 할당한다. 지역 변수로 받아 반드시 해제한다.
    final className = TEXT("FlutterMultiWindow");
    final windowName = TEXT("Karanda Overlay");
    final hWnd = FindWindow(className, windowName);
    free(className);
    free(windowName);
    return hWnd;
  }

  void setOverlay(int hWnd, Rect rect) {
    /* Set non-client rendering attributes */
    final Pointer<INT> ncrp = calloc<INT>();
    ncrp.value = 1;
    DwmSetWindowAttribute(hWnd, DWMWINDOWATTRIBUTE.DWMWA_NCRENDERING_POLICY,
        ncrp, sizeOf<INT>());
    calloc.free(ncrp);

    /* Set transparent */
    final Pointer<MARGINS> margin = calloc<MARGINS>();
    margin.ref.cxLeftWidth = -1;
    margin.ref.cxRightWidth = -1;
    margin.ref.cyBottomHeight = -1;
    margin.ref.cyTopHeight = -1;
    DwmExtendFrameIntoClientArea(hWnd, margin);
    calloc.free(margin);

    /* Set window style — 기존 비트를 통짜로 덮어쓰지 않고 필요한 비트만 조작한다.
       Flutter 호스트 창은 뷰용 자식 HWND를 갖고 있어 WS_CLIPCHILDREN이 없으면 부모가
       자식 영역까지 다시 그려 불필요한 재그리기가 생기고, desktop_multi_window가 설정한
       확장 스타일도 통짜 대입으로 함께 날아간다. WS_EX_TOPMOST는 아래 SetWindowPos의
       HWND_TOPMOST가 담당하므로 여기서는 넣지 않는다. */
    final style = GetWindowLongPtr(hWnd, GWL_STYLE);
    SetWindowLongPtr(hWnd, GWL_STYLE, (style & ~WS_OVERLAPPEDWINDOW) | WS_POPUP);
    SetWindowPos(hWnd, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    final exStyle = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
    SetWindowLongPtr(hWnd, GWL_EXSTYLE,
        exStyle | WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOOLWINDOW);

    applyBounds(hWnd, rect);
  }

  /// 창을 지정 영역(**물리 픽셀**, 가상 데스크톱 좌표)에 배치한다.
  ///
  /// 이동과 크기 지정을 **두 단계로 분리**한다. 배율이 다른 모니터로 창이 넘어가는 순간
  /// Windows는 `WM_DPICHANGED`를 보내고, `desktop_multi_window`의 핸들러는 OS가 제안한
  /// rect(이전 크기 × 배율비)를 그대로 적용한다. 이동과 크기를 한 번에 지정하면 우리가 지정한
  /// 크기가 그 재조정에 휩쓸릴 수 있다. 먼저 이동해 DPI 전환을 끝낸 뒤(1단계), 이동이 없는
  /// 상태에서 크기를 확정한다(2단계). 2단계에는 모니터 이동이 없으므로 DPI 전환이 끼어들 수 없다.
  void applyBounds(int hWnd, Rect rect) {
    final left = rect.left.round();
    final top = rect.top.round();
    final width = rect.width.round();
    final height = rect.height.round();

    /* 1단계: 이동만 (z-order·활성화 건드리지 않음) */
    SetWindowPos(hWnd, NULL, left, top, 0, 0,
        SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);

    /* 2단계: 같은 모니터 안에서 크기 확정 + topmost 승격 */
    SetWindowPos(hWnd, HWND_TOPMOST, left, top, width, height,
        SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  /// 창의 현재 영역(물리 픽셀). 조회 실패 시 null.
  Rect? getWindowBounds(int hWnd) {
    final bounds = calloc<RECT>();
    try {
      if (GetWindowRect(hWnd, bounds) == 0) return null;
      return Rect.fromLTRB(
        bounds.ref.left.toDouble(),
        bounds.ref.top.toDouble(),
        bounds.ref.right.toDouble(),
        bounds.ref.bottom.toDouble(),
      );
    } finally {
      calloc.free(bounds);
    }
  }

  void enableClick(int hWnd) {
    int style = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, style & ~WS_EX_LAYERED);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  void disableClick(int hWnd) {
    int style = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, style | WS_EX_LAYERED);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  /// 연결된 모니터 목록. rect는 **물리 픽셀**(가상 데스크톱 좌표)이다.
  ///
  /// 논리 픽셀을 주는 `screen_retriever`를 쓰지 않고 Win32로 직접 조회한다. 논리→물리 복원에
  /// 쓰던 `GetDeviceCaps(LOGPIXELSX)`는 모니터별 DPI를 주지 않고(MSDN: 다중 모니터에서 모든
  /// 모니터가 같은 값) 프로세스 전역 단일 값만 주기 때문에, 배율이 서로 다른 다중 모니터에서
  /// 반드시 어긋난다.
  Future<List<MonitorDevice>> getAllMonitorDevices() async {
    final devices = <MonitorDevice>[];
    final handles = <int>{}; // 복제 모드에서는 여러 어댑터가 같은 HMONITOR를 가리킨다
    final adapter = calloc<DISPLAY_DEVICE>();
    final devMode = calloc<DEVMODE>();
    try {
      for (int index = 0;; index++) {
        adapter.ref.cb = sizeOf<DISPLAY_DEVICE>();
        if (EnumDisplayDevices(nullptr, index, adapter, 0) == 0) break;
        if ((adapter.ref.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) == 0) {
          continue;
        }

        final adapterName = TEXT(adapter.ref.DeviceName);
        try {
          /* 현재 표시 설정에서 가상 데스크톱 위치만 가져온다. dmPelsWidth/Height는 회전 모니터에서
             드라이버별로 뒤바뀌어 보고되므로 크기로는 쓰지 않고, 이 위치를 HMONITOR 탐침점으로만
             사용한다(크기·좌표는 아래 rcMonitor 기준). */
          devMode.ref.dmSize = sizeOf<DEVMODE>();
          final settings = EnumDisplaySettings(adapterName,
              ENUM_DISPLAY_SETTINGS_MODE.ENUM_CURRENT_SETTINGS, devMode);
          if (settings == 0) continue;

          final hMonitor = _monitorFromPoint(
            devMode.ref.dmPosition.x,
            devMode.ref.dmPosition.y,
            MONITOR_FROM_FLAGS.MONITOR_DEFAULTTONULL,
          );
          if (hMonitor == NULL || !handles.add(hMonitor)) continue;

          final device = _fromMonitorHandle(hMonitor);
          if (device != null) devices.add(device);
        } finally {
          free(adapterName);
        }
      }
    } finally {
      calloc.free(adapter);
      calloc.free(devMode);
    }
    return devices;
  }

  /// 주 모니터. 조회 실패 시 예외를 던지지 않고 화면 크기 기반 값으로 폴백한다
  /// (여기서 던지면 오버레이 설정 로드 전체가 실패해 기능이 조용히 비활성화된다).
  Future<MonitorDevice> getPrimaryMonitorDevice() async {
    final hMonitor = _monitorFromPoint(
      0,
      0,
      MONITOR_FROM_FLAGS.MONITOR_DEFAULTTOPRIMARY,
    );
    final device = hMonitor == NULL ? null : _fromMonitorHandle(hMonitor);
    if (device != null) return device;

    final width = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN);
    final height = GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN);
    _log.warning('Failed to query primary monitor; '
        'using screen metrics fallback (${width}x$height)');
    return MonitorDevice(
      name: "",
      deviceID: "",
      rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
  }

  int _monitorFromPoint(int x, int y, int flags) {
    final point = calloc<POINT>();
    try {
      point.ref.x = x;
      point.ref.y = y;
      return MonitorFromPoint(point.ref, flags);
    } finally {
      calloc.free(point);
    }
  }

  /// HMONITOR → MonitorDevice. rcMonitor(물리 픽셀, 작업표시줄 포함 전체 영역)를 그대로 쓴다.
  MonitorDevice? _fromMonitorHandle(int hMonitor) {
    final info = calloc<MONITORINFOEX>();
    final monitor = calloc<DISPLAY_DEVICE>();
    try {
      info.ref.monitorInfo.cbSize = sizeOf<MONITORINFOEX>();
      if (GetMonitorInfo(hMonitor, info.cast<MONITORINFO>()) == 0) return null;

      final name = info.ref.szDevice;
      final rcMonitor = info.ref.monitorInfo.rcMonitor;
      final rect = Rect.fromLTRB(
        rcMonitor.left.toDouble(),
        rcMonitor.top.toDouble(),
        rcMonitor.right.toDouble(),
        rcMonitor.bottom.toDouble(),
      );

      final namePtr = TEXT(name);
      try {
        monitor.ref.cb = sizeOf<DISPLAY_DEVICE>();
        final deviceID = EnumDisplayDevices(namePtr, 0, monitor, 0) != 0
            ? monitor.ref.DeviceID
            : "";
        _log.fine('Display $name: ${rect.width.toInt()}x${rect.height.toInt()} '
            'at ${rect.left.toInt()},${rect.top.toInt()} '
            '(scale ${(_scaleFactor(hMonitor) * 100).round()}%)');
        return MonitorDevice(name: name, deviceID: deviceID, rect: rect);
      } finally {
        free(namePtr);
      }
    } finally {
      calloc.free(info);
      calloc.free(monitor);
    }
  }

  /// 모니터 배율(로그 전용). 조회 실패 시 1.0.
  double _scaleFactor(int hMonitor) {
    final dpiX = calloc<UINT>();
    final dpiY = calloc<UINT>();
    try {
      final result = GetDpiForMonitor(
          hMonitor, MONITOR_DPI_TYPE.MDT_EFFECTIVE_DPI, dpiX, dpiY);
      if (result != S_OK || dpiX.value == 0) return 1.0;
      return dpiX.value / 96.0;
    } finally {
      calloc.free(dpiX);
      calloc.free(dpiY);
    }
  }
}
