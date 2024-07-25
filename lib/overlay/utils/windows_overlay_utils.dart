import 'package:win32/win32.dart';

int getMainWindowHandle() {
  int hWnd = FindWindow(TEXT("FLUTTER_RUNNER_WIN32_WINDOW"), TEXT("Karanda"));
  return hWnd;
}

int getWindowHandle({required String title}) {
  int hWnd = FindWindow(TEXT("FlutterMultiWindow"), TEXT(title));
  return hWnd;
}

void showWindow(int hWnd) {
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOW);
}

void hideWindow(int hWnd) {
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_HIDE);
}

void hideFrame(int hWnd) {
  SetWindowLongPtr(hWnd, WINDOW_LONG_PTR_INDEX.GWL_STYLE, 0);
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOW);
  SetWindowLongPtr(
      hWnd,
      WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
      WINDOW_EX_STYLE.WS_EX_TRANSPARENT |
          WINDOW_EX_STYLE.WS_EX_LAYERED |
          WINDOW_EX_STYLE.WS_EX_TOOLWINDOW);
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOW);
  SetWindowPos(
      hWnd,
      HWND_TOPMOST,
      0,
      0,
      0,
      0,
      SET_WINDOW_POS_FLAGS.SWP_NOMOVE |
          SET_WINDOW_POS_FLAGS.SWP_NOSIZE |
          SET_WINDOW_POS_FLAGS.SWP_FRAMECHANGED);
}

void showFrame(int hWnd) {
  SetWindowLongPtr(
      hWnd,
      WINDOW_LONG_PTR_INDEX.GWL_STYLE,
      WINDOW_STYLE.WS_VISIBLE |
          WINDOW_STYLE.WS_OVERLAPPEDWINDOW & ~WINDOW_STYLE.WS_THICKFRAME);
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOW);
  SetWindowLongPtr(
      hWnd, WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE, ~WINDOW_EX_STYLE.WS_EX_LAYERED);
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOW);
  SetWindowPos(
      hWnd,
      hWnd,
      0,
      0,
      0,
      0,
      SET_WINDOW_POS_FLAGS.SWP_NOZORDER |
          SET_WINDOW_POS_FLAGS.SWP_NOOWNERZORDER |
          SET_WINDOW_POS_FLAGS.SWP_NOMOVE |
          SET_WINDOW_POS_FLAGS.SWP_NOSIZE |
          SET_WINDOW_POS_FLAGS.SWP_FRAMECHANGED);
}
