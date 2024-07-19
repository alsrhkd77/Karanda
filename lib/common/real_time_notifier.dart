import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:karanda/common/real_time.dart';

class RealTimeNotifier with ChangeNotifier {
  DateTime now = DateTime.now();
  final RealTime _realtime = RealTime();
  late StreamSubscription _subscription;

  //late Timer _timer;

  RealTimeNotifier() {
    _subscription = _realtime.stream.listen(_update);
    //_timer = Timer.periodic(const Duration(seconds: 1), (timer) => _update());
  }

  void _update(snapshot) {
    now = snapshot;
    notifyListeners();
  }

  @override
  void dispose() {
    //_timer.cancel();
    _subscription.cancel();
    super.dispose();
  }
}
