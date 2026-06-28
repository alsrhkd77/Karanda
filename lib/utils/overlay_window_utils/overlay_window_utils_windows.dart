import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:ui' show Rect;

import 'package:ffi/ffi.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:win32/win32.dart';

abstract class OverlayWindowUtilsPlatform {
  int getOverlayWindowHandle() {
    return using((arena) {
      // desktop_multi_window 0.3 서브윈도우는 이 창 클래스를 사용하고 타이틀을 설정할 수
      // 없으므로, 오버레이 창은 클래스 이름만으로 찾는다.
      final result = FindWindow(
        arena.pcwstr("FLUTTER_MULTI_WINDOW_WIN32_WINDOW"),
        null,
      );
      final handle = result.value.address;
      developer.log('Overlay window handle: $handle', name: 'overlay');
      return handle;
    });
  }

  /// 표시 전 단계: 위치/크기, 팝업 스타일, DWM 글래스(투명)만 적용한다.
  /// WS_EX_LAYERED(레이어드)는 콘텐츠가 렌더링되기 전에 적용하면 창이 보이지
  /// 않게 되므로 여기서는 적용하지 않고, 표시 후 enableClickThrough에서 적용한다.
  /// DWM 글래스만으로도 창은 투명하게 표시되므로 검은 창이 보이지 않는다.
  void prepareOverlay(int hWndAddress, Rect rect) {
    final hWnd = HWND(Pointer.fromAddress(hWndAddress));

    /* 비클라이언트 영역 렌더링 속성 설정 */
    final Pointer<Int32> ncrp = calloc<Int32>();
    ncrp.value = 1;
    DwmSetWindowAttribute(
        hWnd, DWMWA_NCRENDERING_POLICY, ncrp, sizeOf<Int32>());
    calloc.free(ncrp);

    /* 투명 처리(DWM 글래스) */
    final Pointer<MARGINS> margin = calloc<MARGINS>();
    margin.ref.cxLeftWidth = -1;
    margin.ref.cxRightWidth = -1;
    margin.ref.cyBottomHeight = -1;
    margin.ref.cyTopHeight = -1;
    DwmExtendFrameIntoClientArea(hWnd, margin);
    calloc.free(margin);

    /* 창 스타일(팝업) + 위치/크기. 표시는 하지 않는다(SWP_SHOWWINDOW 미사용). */
    SetWindowLongPtr(hWnd, GWL_STYLE, WS_POPUP);
    SetWindowPos(hWnd, null, 0, 0, 0, 0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    SetWindowPos(hWnd, HWND_TOPMOST, rect.left.ceil(), rect.top.ceil(),
        rect.width.ceil(), rect.height.ceil(),
        SWP_FRAMECHANGED | SWP_NOACTIVATE);
  }

  /// 표시 후 단계: 레이어드 + 클릭스루를 적용한다. 창이 표시·렌더링된 뒤에
  /// 호출해야 정상적으로 보인다.
  void enableClickThrough(int hWndAddress) {
    final hWnd = HWND(Pointer.fromAddress(hWndAddress));
    SetWindowLongPtr(hWnd, GWL_EXSTYLE,
        WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOOLWINDOW | WS_EX_TOPMOST);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_NOACTIVATE);
  }

  void enableClick(int hWndAddress) {
    final hWnd = HWND(Pointer.fromAddress(hWndAddress));
    final int style = GetWindowLongPtr(hWnd, GWL_EXSTYLE).value;
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, style & ~WS_EX_LAYERED);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  void disableClick(int hWndAddress) {
    final hWnd = HWND(Pointer.fromAddress(hWndAddress));
    final int style = GetWindowLongPtr(hWnd, GWL_EXSTYLE).value;
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, style | WS_EX_LAYERED);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  Future<List<MonitorDevice>> getAllMonitorDevices() async {
    final displays = await screenRetriever.getAllDisplays();
    displays.removeWhere(
        (display) => display.name == null || display.visiblePosition == null);
    final List<MonitorDevice> devices = [];

    for (Display display in displays) {
      final name = display.name!;
      final displayDevice = calloc<DISPLAY_DEVICE>();
      displayDevice.ref.cb = sizeOf<DISPLAY_DEVICE>();
      final namePtr = name.toPcwstr(allocator: calloc);

      if (EnumDisplayDevices(namePtr, 0, displayDevice, 0)) {
        final hdc = CreateDC(namePtr, namePtr, null, null);
        final dpiX = GetDeviceCaps(hdc, LOGPIXELSX); // X축 DPI
        final dpiY = GetDeviceCaps(hdc, LOGPIXELSY); // Y축 DPI
        DeleteDC(hdc);

        devices.add(
          MonitorDevice(
            name: name,
            deviceID: displayDevice.ref.DeviceID,
            rect: Rect.fromLTWH(
              display.visiblePosition!.dx,
              display.visiblePosition!.dy,
              display.size.width * dpiX / 96,
              display.size.height * dpiY / 96,
            ),
          ),
        );
      }
      calloc.free(namePtr);
      calloc.free(displayDevice);
    }

    return devices;
  }

  Future<MonitorDevice> getPrimaryMonitorDevice() async {
    final display = await screenRetriever.getPrimaryDisplay();
    final name = display.name!;
    final displayDevice = calloc<DISPLAY_DEVICE>();
    displayDevice.ref.cb = sizeOf<DISPLAY_DEVICE>();
    final namePtr = name.toPcwstr(allocator: calloc);
    EnumDisplayDevices(namePtr, 0, displayDevice, 0);
    final hdc = CreateDC(namePtr, namePtr, null, null);
    final dpiX = GetDeviceCaps(hdc, LOGPIXELSX); // X DPI
    final dpiY = GetDeviceCaps(hdc, LOGPIXELSY); // Y DPI
    DeleteDC(hdc);
    final result = MonitorDevice(
      name: name,
      deviceID: displayDevice.ref.DeviceID,
      rect: Rect.fromLTWH(
        display.visiblePosition!.dx,
        display.visiblePosition!.dy,
        display.size.width * dpiX / 96,
        display.size.height * dpiY / 96,
      ),
    );
    calloc.free(namePtr);
    calloc.free(displayDevice);
    return result;
  }
}
