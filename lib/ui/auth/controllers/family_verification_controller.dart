import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/repository/time_repository.dart';

class FamilyVerificationController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TimeRepository _timeRepository;
  late final StreamSubscription _now;
  bool lifeSkillIsLocked = false;
  bool contributionPointIsLocked = false;
  DateTime? startedAt;
  DateTime now = DateTime.now();

  FamilyVerificationController({
    required AuthRepository authRepository,
    required TimeRepository timeRepository,
  })  : _authRepository = authRepository,
        _timeRepository = timeRepository {
    _now = _timeRepository.realTimeStream.listen(_onTimeUpdate);
  }

  bool get locked => lifeSkillIsLocked;

  Duration? get timeLimit => startedAt?.add(const Duration(minutes: 10)).difference(now);

  Future<bool> startVerification() async {
    final result = await _authRepository.startFamilyVerification();
    if (result.containsKey("lifeSkillIsLocked") &&
        result.containsKey("contributionPointIsLocked") &&
        result.containsKey("createdAt")) {
      lifeSkillIsLocked = result["lifeSkillIsLocked"];
      contributionPointIsLocked = result["contributionPointIsLocked"];
      startedAt = DateTime.tryParse(result["createdAt"])?.toLocal();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> verify() async {
    return await _authRepository.verifyFamily();
  }

  void _onTimeUpdate(DateTime value) {
    now = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _now.cancel();
    super.dispose();
  }
}
