import 'dart:ffi';
import 'dart:ui' show Rect;

import 'package:ffi/ffi.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:win32/win32.dart';

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
    SetWindowPos(hWnd, HWND_TOPMOST, rect.left.ceil(), rect.top.ceil(), rect.width.ceil(), rect.height.ceil(), SWP_FRAMECHANGED | SWP_SHOWWINDOW);
    //SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
    //ShowWindow(hWnd, SW_MAXIMIZE);
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

  Future<List<MonitorDevice>> getAllMonitorDevices() async {
    final displays = await screenRetriever.getAllDisplays();
    displays.removeWhere(
        (display) => display.name == null || display.visiblePosition == null);
    final List<MonitorDevice> devices = [];

    for (Display display in displays) {
      final name = display.name!;
      // TEXT(name)은 호출마다 새로 할당되므로 한 번만 만들어 재사용하고 반드시 해제한다.
      final nameNative = TEXT(name);
      final displayDevice = calloc<DISPLAY_DEVICE>();
      displayDevice.ref.cb = sizeOf<DISPLAY_DEVICE>();

      if (EnumDisplayDevices(nameNative, 0, displayDevice, 0) != 0) {
        final hdc = CreateDC(nameNative, nameNative, nullptr, nullptr);
        final dpiX = GetDeviceCaps(hdc, LOGPIXELSX); // X DPI
        final dpiY = GetDeviceCaps(hdc, LOGPIXELSY); // X DPI
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
      calloc.free(displayDevice);
      free(nameNative);
    }

    return devices;
  }

  Future<MonitorDevice> getPrimaryMonitorDevice() async {
    final display = await screenRetriever.getPrimaryDisplay();
    final name = display.name!;
    final nameNative = TEXT(name);
    final displayDevice = calloc<DISPLAY_DEVICE>();
    displayDevice.ref.cb = sizeOf<DISPLAY_DEVICE>();
    EnumDisplayDevices(nameNative, 0, displayDevice, 0);
    final hdc = CreateDC(nameNative, nameNative, nullptr, nullptr);
    final dpiX = GetDeviceCaps(hdc, LOGPIXELSX); // X DPI
    final dpiY = GetDeviceCaps(hdc, LOGPIXELSY); // X DPI
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
    calloc.free(displayDevice);
    free(nameNative);
    return result;
  }
}
