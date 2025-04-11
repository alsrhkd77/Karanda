import 'dart:async';

import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_widget_controller.dart';

class ClockOverlayController extends OverlayWidgetController {
  final TimeRepository _timeRepository;
  late final StreamSubscription _now;

  DateTime now = DateTime.now();

  ClockOverlayController({
    required super.service,
    required super.key,
    required super.defaultRect,
    required super.constraints,
    required TimeRepository timeRepository,
  }) : _timeRepository = timeRepository {
    _now = _timeRepository.realTimeStream.listen(_onTimeUpdate);
  }

  void _onTimeUpdate(DateTime value) {
    now = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _now.cancel();
    super.dispose();
  }
}
