import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:karanda/model/monitor_device.dart';

class OverlayApi {
  /// 오버레이 창 생성. 실제 배치(모니터 전체 덮기)는 이후 `set window` 메시지가 담당하고,
  /// 여기서는 0 크기로 대상 모니터 구석에 띄우기만 한다.
  ///
  /// `desktop_multi_window`는 창을 항상 주 모니터에 만든다. 배율이 다른 모니터로 창이 넘어가면
  /// Windows가 `WM_DPICHANGED`를 보내고 플러그인이 OS 제안 크기를 그대로 적용하므로, **크기를
  /// 확정하기 전에** 여기서 미리 대상 모니터로 옮겨 모니터 간 이동을 끝내둔다.
  Future<WindowController> startOverlay(MonitorDevice target) async {
    Map<String, dynamic> arguments = {
      'width': target.rect.width,
      'height': target.rect.height,
    };
    final windowController =
        await DesktopMultiWindow.createWindow(jsonEncode(arguments));
    await windowController.setFrame(
      Offset(target.rect.right - 60, target.rect.bottom - 20) &
          const Size(0, 0),
    );
    await windowController.setTitle("Karanda Overlay");
    await windowController.show();
    return windowController;
  }

  Future<void> sendToOverlay({
    required WindowController windowController,
    required String method,
    required String data,
  }) async {
    await DesktopMultiWindow.invokeMethod(windowController.windowId, method, data);
  }
}
