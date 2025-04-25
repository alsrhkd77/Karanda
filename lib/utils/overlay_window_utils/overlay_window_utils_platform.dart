import 'dart:ui';
import 'package:karanda/model/monitor_device.dart';

abstract class OverlayWindowUtilsPlatform {
  int getOverlayWindowHandle() => throw UnsupportedError('Platform unsupported.');

  void setOverlay(int hWnd, Rect rect) => throw UnsupportedError('Platform unsupported.');

  void enableClick(int hWnd) => throw UnsupportedError('Platform unsupported.');

  void disableClick(int hWnd) => throw UnsupportedError('Platform unsupported.');

  Future<List<MonitorDevice>> getAllMonitorDevices() => throw UnsupportedError('Platform unsupported.');

  Future<MonitorDevice> getPrimaryMonitorDevice() => throw UnsupportedError('Platform unsupported.');
}
