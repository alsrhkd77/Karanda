import 'dart:async';
import 'package:flutter/foundation.dart';
import './visibility_change_listener.dart'
    if (dart.library.js_interop) './visibility_change_listener.dart';

class WebVisibility {
  final StreamController _controller = StreamController<bool>.broadcast();

  bool _visible = true;

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
    _visible = true;
    _controller.sink.add(true);
  }

  void _onHidden() {
    _visible = false;
    _controller.sink.add(false);
  }
}
