import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

int getMainWindowHandle() {
  int hWnd = FindWindow(TEXT("FLUTTER_RUNNER_WIN32_WINDOW"), TEXT("Karanda"));
  return hWnd;
}

int getOverlayWindowHandle({required String title}) {
  int hWnd = FindWindow(TEXT("FlutterMultiWindow"), TEXT(title));
  return hWnd;
}

void setParent({required int child, required int parent}) {
  SetParent(child, parent);
}

void setOpacity(int hWnd) {
  double alpha = 0.85;
  int gwlExStyle = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
  SetWindowLongPtr(hWnd, GWL_EXSTYLE, gwlExStyle | WS_EX_LAYERED);
  SetLayeredWindowAttributes(hWnd, 0, (255 * alpha).round(), LWA_ALPHA);
}

void setIgnoreMouseEvents(int hWnd) {
  int gwlExStyle = GetWindowLongPtr(hWnd, GWL_EXSTYLE);
  SetWindowLongPtr(
      hWnd, GWL_EXSTYLE, gwlExStyle | WS_EX_TRANSPARENT | WS_EX_LAYERED);
  SetWindowPos(hWnd, hWnd, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

void setAsFrameless(int hWnd) {
  Pointer<RECT> rect = calloc<RECT>();
  SetWindowLongPtr(hWnd, GWL_STYLE, WS_THICKFRAME);
  SetWindowPos(
      hWnd,
      hWnd,
      rect.ref.left,
      rect.ref.top,
      rect.ref.right - rect.ref.left,
      rect.ref.bottom - rect.ref.top,
      SWP_NOZORDER |
          SWP_NOOWNERZORDER |
          SWP_NOMOVE |
          SWP_NOSIZE |
          SWP_FRAMECHANGED);
  free(rect);
}

void setAlwaysOnTop(int hWnd) {
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}
