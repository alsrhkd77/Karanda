import 'dart:async';

class RealTime {
  final StreamController _controller = StreamController<DateTime>.broadcast();
  late Timer _timer;
  Duration offset = Duration.zero;
  DateTime now = DateTime.now();

  Stream get stream => _controller.stream;

  static final RealTime _instance = RealTime._internal();

  factory RealTime() {
    return _instance;
  }

  RealTime._internal() {
    _timer = Timer(const Duration(milliseconds: 100), _update);
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
