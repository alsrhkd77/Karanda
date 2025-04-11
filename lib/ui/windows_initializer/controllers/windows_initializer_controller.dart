import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/initializer_status.dart';
import 'package:karanda/repository/version_repository.dart';
import 'package:karanda/service/initializer_service.dart';

class WindowsInitializerController extends ChangeNotifier {
  final InitializerService _initializerService;
  final VersionRepository _versionRepository;
  late final StreamSubscription _status;

  String version = "";
  InitializerStatus status = InitializerStatus();

  WindowsInitializerController({
    required InitializerService initializerService,
    required VersionRepository versionRepository,
  })  : _initializerService = initializerService,
        _versionRepository = versionRepository{
    getVersion();
    _status = _initializerService.initializerStatus.listen(_onUpdateStatus);
  }

  Future<void> getVersion() async {
    final currentVersion = await _versionRepository.getCurrentVersion();
    version = currentVersion.text;
    notifyListeners();
  }

  void _onUpdateStatus(InitializerStatus value){
    status = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _status.cancel();
    super.dispose();
  }
}
