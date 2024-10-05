import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:karanda/common/web_visibility/visibility_change_listener.dart'
    if (dart.library.js_interop) 'package:karanda/common/web_visibility/web_visibility_change_listener.dart';

class WebVisibility {
  final StreamController _controller = StreamController<bool>.broadcast();

  bool _visible = true;

  Timer? _timer;

  Stream get stream => _controller.stream;

  bool get isVisible => _visible;

  static final WebVisibility _instance = WebVisibility._internal();

  factory WebVisibility() {
    return _instance;
  }

  WebVisibility._internal() {
    if (kIsWeb) {
      _visible = currentVisible() ?? _visible;
      addListener(onVisible: _onVisible, onHidden: _onHidden);
    }
  }

  void _onVisible() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), (){
      if(!_visible){
        _visible = true;
        _controller.sink.add(true);
      }
    });
  }

  void _onHidden() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), (){
      if(_visible){
        _visible = false;
        _controller.sink.add(false);
      }
    });
  }
}
