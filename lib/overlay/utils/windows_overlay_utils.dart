import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

int getOverlayWindowHandle() {
  int hWnd = FindWindow(TEXT("FlutterMultiWindow"), TEXT("Karanda Overlay"));
  return hWnd;
}

void setOverlay(int hWnd, double width, double height){
  /* Set non-client rendering attributes */
  final Pointer<INT> ncrp = calloc<INT>();
  ncrp.value = 1;
  DwmSetWindowAttribute(hWnd, DWMWINDOWATTRIBUTE.DWMWA_NCRENDERING_POLICY, ncrp, sizeOf<INT>());
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
  SetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_STYLE, WINDOW_STYLE.WS_POPUP);
  SetWindowPos(hWnd, NULL, 0, 0, 0, 0, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE | SET_WINDOW_POS_FLAGS.SWP_NOZORDER | SET_WINDOW_POS_FLAGS.SWP_FRAMECHANGED);
  SetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE, WINDOW_EX_STYLE.WS_EX_LAYERED | WINDOW_EX_STYLE.WS_EX_TRANSPARENT | WINDOW_EX_STYLE.WS_EX_TOOLWINDOW | WINDOW_EX_STYLE.WS_EX_TOPMOST);
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, width.ceil(), height.ceil(), SET_WINDOW_POS_FLAGS.SWP_FRAMECHANGED | SET_WINDOW_POS_FLAGS.SWP_SHOWWINDOW);
}

void enableClick(int hWnd){
  int style = GetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE);
  SetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE, style & ~WINDOW_EX_STYLE.WS_EX_LAYERED);
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE | SET_WINDOW_POS_FLAGS.SWP_FRAMECHANGED | SET_WINDOW_POS_FLAGS.SWP_SHOWWINDOW);
}

void disableClick(int hWnd){
  int style = GetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE);
  SetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE, style | WINDOW_EX_STYLE.WS_EX_LAYERED);
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE | SET_WINDOW_POS_FLAGS.SWP_FRAMECHANGED | SET_WINDOW_POS_FLAGS.SWP_SHOWWINDOW);
}