import 'dart:ffi';
import 'dart:ui' show Rect;

import 'package:ffi/ffi.dart';
import 'package:karanda/model/monitor_device.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:win32/win32.dart';

abstract class OverlayWindowUtilsPlatform {
  int getOverlayWindowHandle() {
    int hWnd = FindWindow(TEXT("FlutterMultiWindow"), TEXT("Karanda Overlay"));
    return hWnd;
  }

  void setOverlay(int hWnd, Rect rect) {
    /* Set non-client rendering attributes */
    final Pointer<INT> ncrp = calloc<INT>();
    ncrp.value = 1;
    DwmSetWindowAttribute(hWnd, DWMWA_NCRENDERING_POLICY, ncrp, sizeOf<INT>());
    calloc.free(ncrp);

    /* Set transparent */
    final Pointer<MARGINS> margin = calloc<MARGINS>();
    margin.ref.cxLeftWidth = -1;
    margin.ref.cxRightWidth = -1;
    margin.ref.cyBottomHeight = -1;
    margin.ref.cyTopHeight = -1;
    DwmExtendFrameIntoClientArea(hWnd, margin);
    calloc.free(margin);

    /* Set window style */
    SetWindowLongPtr(hWnd, GWL_STYLE, WS_POPUP);
    SetWindowPos(hWnd, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOOLWINDOW | WS_EX_TOPMOST);
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
      final displayDevice = calloc<DISPLAY_DEVICE>();
      displayDevice.ref.cb = sizeOf<DISPLAY_DEVICE>();

      if (EnumDisplayDevices(TEXT(name), 0, displayDevice, 0) != 0) {
        final hdc = CreateDC(TEXT(name), TEXT(name), nullptr, nullptr);
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
    }

    return devices;
  }

  Future<MonitorDevice> getPrimaryMonitorDevice() async {
    final display = await screenRetriever.getPrimaryDisplay();
    final name = display.name!;
    final displayDevice = calloc<DISPLAY_DEVICE>();
    displayDevice.ref.cb = sizeOf<DISPLAY_DEVICE>();
    EnumDisplayDevices(TEXT(name), 0, displayDevice, 0);
    final hdc = CreateDC(TEXT(name), TEXT(name), nullptr, nullptr);
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
    return result;
  }
}
