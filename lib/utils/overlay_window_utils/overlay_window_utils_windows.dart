import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

abstract class OverlayWindowUtilsPlatform {
  int getOverlayWindowHandle() {
    int hWnd = FindWindow(TEXT("FlutterMultiWindow"), TEXT("Karanda Overlay"));
    return hWnd;
  }

  void setOverlay(int hWnd, double width, double height) {
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
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, width.ceil(), height.ceil(), SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  void enableClick(int hWnd) {
    int style = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, style & ~WS_EX_LAYERED);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }

  void disableClick(int hWnd) {
    int style = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, style | WS_EX_LAYERED);
    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);
  }
}