import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_retriever/screen_retriever.dart';

class OverlayApi {
  Future<WindowController> startOverlay() async {
    Display primary = await screenRetriever.getPrimaryDisplay();
    Map<String, dynamic> arguments = {
      'width': primary.size.width,
      'height': primary.size.height,
    };
    final windowController =
        await DesktopMultiWindow.createWindow(jsonEncode(arguments));
    await windowController.setFrame(
      Offset(primary.size.width, primary.size.height) & const Size(0, 0),
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
    DesktopMultiWindow.invokeMethod(windowController.windowId, method, data);
  }
}
