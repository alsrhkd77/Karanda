abstract class OverlayWindowUtilsPlatform {
  int getOverlayWindowHandle() => throw UnsupportedError('Platform unsupported.');

  void setOverlay(int hWnd, double width, double height) => throw UnsupportedError('Platform unsupported.');

  void enableClick(int hWnd) => throw UnsupportedError('Platform unsupported.');

  void disableClick(int hWnd) => throw UnsupportedError('Platform unsupported.');
}
