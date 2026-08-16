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
    // 반환값을 반드시 대입해야 dispose()에서 해제할 수 있다. 대입하지 않으면 late final
    // _bdoTime이 미초기화 상태로 남아 dispose()의 _bdoTime.cancel()이 LateInitializationError로
    // 크래시하고, 그 전까지는 구독이 계속 남아 dispose된 컨트롤러에 notify가 이어진다.
    _bdoTime = _timeRepository.bdoTimeStream.listen(_onBdoTimeUpdate);
    _now = _timeRepository.utcTimeStream.listen(_onTimeUpdate);
  }

  void _onTimeUpdate(DateTime value) {
    remaining = bdoTime.nextTransition.difference(value);
    notifyIfVisible();
  }

  void _onBdoTimeUpdate(BdoTime value){
    bdoTime = value;
    notifyIfVisible();
  }

  @override
  Future<void> dispose() async {
    await _now.cancel();
    await _bdoTime.cancel();
    super.dispose();
  }
}
