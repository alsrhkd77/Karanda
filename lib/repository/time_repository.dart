import 'dart:async';

import 'package:rxdart/rxdart.dart';

class TimeRepository {
  final _realTime = BehaviorSubject<DateTime>.seeded(DateTime.now());

  DateTime get realTime => _realTime.value;
  DateTime get utcTime => realTime.toUtc();

  Stream<DateTime> get realTimeStream => _realTime.stream;

  Stream<DateTime> get utcTimeStream =>
      realTimeStream.map((time) => time.toUtc());

  TimeRepository() {
    Timer.periodic(const Duration(milliseconds: 500), _update);
  }

  void _update(Timer tick) {
    _realTime.sink.add(DateTime.now());
  }
}
