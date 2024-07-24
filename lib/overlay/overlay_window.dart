import 'dart:convert';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';

class OverlayWindow {
  int? windowId;
  WindowController? _controller;
  late String title;
  late Offset offset;
  late Size size;
  late bool show;
  bool adjusting = false;

  OverlayWindow.fromJson(Map data){
    title = data["title"];
    offset = Offset(data["x"], data["y"]);
    size = Size(data["width"], data["height"]);
    show = data["show"];
  }

  Map toJson(){
    Map data = {
      "title": title,
      "x": offset.dx,
      "y": offset.dy,
      "width": size.width,
      "height": size.height,
      "show": show
    };
    return data;
  }

  Future<void> create() async {
    _controller = await DesktopMultiWindow.createWindow(jsonEncode({
      'title': title,
      'show': show,
    }));
    windowId = _controller?.windowId;
    await _controller?.setFrame(offset & size);
    await _controller?.setTitle(title);
    await _controller?.hide();
  }

  void showOverlay() {
    show = true;
    _controller?.show();
  }

  void hideOverlay() {
    show = false;
    _controller?.hide();
  }

  void invokeMethod({required String method, dynamic arguments}){
    print("send");
    if(windowId != null){
      DesktopMultiWindow.invokeMethod(windowId!, method, arguments);
    }
  }
}
