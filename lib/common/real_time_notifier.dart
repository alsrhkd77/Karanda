import 'dart:async';

import 'package:flutter/widgets.dart';

class RealTimeNotifier with ChangeNotifier {
  DateTime now = DateTime.now();

  late Timer _timer;

  RealTimeNotifier() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _update());
  }

  void _update() {
    now = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
