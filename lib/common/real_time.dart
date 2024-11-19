import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

class RealTime {
  final StreamController<DateTime> _controller = StreamController<DateTime>.broadcast();
  late Timer _timer;
  Duration offset = Duration.zero;  //장치 utc시간이 서버 utc시간과 얼마나 차이나는지
  DateTime now = DateTime.now();

  Stream<DateTime> get stream => _controller.stream;

  static final RealTime _instance = RealTime._internal();

  factory RealTime() {
    return _instance;
  }

  RealTime._internal() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) => _update());
  }

  void _synchronize(){
    final formatter = DateFormat('EEE, d MMM yyyy HH:mm:ss'); // For GMT
    final dateTime = formatter.parse("");
  }

  void _update() {
    now = DateTime.now().add(offset);
    _controller.sink.add(now);
  }

  void dispose() {
    _timer.cancel();
    _controller.sink.close();
  }
}
