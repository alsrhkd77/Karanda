import 'dart:async';

import 'package:karanda/common/real_time.dart';

class ServerTime {
  final StreamController _controller = StreamController<DateTime>.broadcast();
  Duration offset = const Duration(hours: 9);  //서버시각 - UTC 시각
  final RealTime _realtime = RealTime();
  late StreamSubscription _subscription;

  DateTime now = DateTime.now().toUtc();

  Stream get stream => _controller.stream;

  static final ServerTime _instance = ServerTime._internal();

  factory ServerTime(){
    return _instance;
  }

  ServerTime._internal(){
    now = now.add(offset);
    _subscription = _realtime.stream.listen(_update);
  }

  void _update(snapshot){
    now = snapshot.toUtc().add(offset);
    _controller.sink.add(now);
  }

  void dispose(){
    _subscription.cancel();
    _controller.sink.close();
  }
}