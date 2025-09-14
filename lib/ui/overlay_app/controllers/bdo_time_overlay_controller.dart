import 'dart:async';

import 'package:karanda/ui/overlay_app/controllers/overlay_widget_controller.dart';
import 'package:karanda/utils/bdo_time.dart';

import '../../../repository/time_repository.dart';

class BdoTimeOverlayController extends OverlayWidgetController {
  final TimeRepository _timeRepository;
  late final StreamSubscription _now;
  late final StreamSubscription _bdoTime;

  BdoTime bdoTime = BdoTime(DateTime.now().toUtc());
  Duration remaining = Duration.zero;

  BdoTimeOverlayController({
    required super.service,
    required super.key,
    required super.defaultRect,
    required super.constraints,
    required TimeRepository timeRepository,
  }) : _timeRepository = timeRepository {
    _timeRepository.bdoTimeStream.listen(_onBdoTimeUpdate);
    _now = _timeRepository.utcTimeStream.listen(_onTimeUpdate);
  }

  void _onTimeUpdate(DateTime value) {
    remaining = bdoTime.nextTransition.difference(value);
    notifyListeners();
  }

  void _onBdoTimeUpdate(BdoTime value){
    bdoTime = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _now.cancel();
    await _bdoTime.cancel();
    super.dispose();
  }
}
