import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/model/initializer_status.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/repository/version_repository.dart';
import 'package:karanda/utils/command_line_arguments.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'dart:developer' as developer;

class InitializerService {
  final AppSettingsRepository _appSettingsRepository;
  final OverlayRepository _overlayRepository;
  final VersionRepository _versionRepository;
  final AuthRepository _authRepository;
  final AudioPlayerRepository _audioPlayerRepository;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final GoRouter _router;
  final _status =
      BehaviorSubject<InitializerStatus>.seeded(InitializerStatus());

  InitializerService({
    required AppSettingsRepository appSettingsRepository,
    required OverlayRepository overlayRepository,
    required VersionRepository versionRepository,
    required AuthRepository authRepository,
    required AudioPlayerRepository audioPlayerRepository,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required GoRouter router,
  })  : _appSettingsRepository = appSettingsRepository,
        _overlayRepository = overlayRepository,
        _versionRepository = versionRepository,
        _authRepository = authRepository,
        _audioPlayerRepository = audioPlayerRepository,
        _scaffoldMessengerKey = scaffoldMessengerKey,
        _router = router {
    if (kIsWeb || !Platform.isWindows) {
      initializeForWeb();
    } else {
      initializeForWindows();
    }
  }

  Stream<InitializerStatus> get initializerStatus => _status.stream;

  Future<void> initializeForWindows() async {
    await Future.delayed(const Duration(seconds: 1));
    int process = 6;
    _status.sink.add(InitializerStatus(
      progress: 0 / process,
      message: "check update",
    ));
    if (CommandLineArguments.forceUpdate) {
      await update();
      return;
    }
    //if (!CommandLineArguments.skipUpdate && !kDebugMode) {
    if (true) {
      try {
        final currentVersion = await _versionRepository.getCurrentVersion();
        final latestVersion = await _versionRepository.getLatestVersion();
        print(latestVersion);
        print(currentVersion.isNewerThan(latestVersion));
        if (!currentVersion.isNewerThan(latestVersion)) {
          await update();
          return;
        }
      } catch (e) {
        developer.log("Failed to check version & update\n$e");
        _status.sink.add(InitializerStatus(
          progress: 0,
          message: "failed to update",
        ));
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    _status.sink.add(InitializerStatus(
      progress: 1 / process,
      message: "get settings",
    ));
    final welcome = await _appSettingsRepository.getAppSettings();
    _status.sink.add(InitializerStatus(
      progress: 2 / process,
      message: "start overlay",
    ));
    await _overlayRepository.startOverlay();
    final overlaySettings = await _overlayRepository.loadSettings();
    await _overlayRepository
        .sendActivationStatus(overlaySettings.activationStatus);
    _status.sink.add(InitializerStatus(
      progress: 3 / process,
      message: "authenticate",
    ));
    await _authRepository.login();
    _status.sink.add(InitializerStatus(
      progress: 4 / process,
      message: "connect websocket",
    ));
    //웹소켓
    _status.sink.add(InitializerStatus(
      progress: 5 / process,
      message: "mount audio",
    ));
    await _audioPlayerRepository.init();

    _status.sink.add(InitializerStatus(
      progress: process / process,
      message: "startup",
    ));
    await Future.delayed(const Duration(milliseconds: 500));
    await setWindows();
    if (welcome) {
      _router.go("/welcome");
    } else {
      _router.go("/");
    }
  }

  Future<void> initializeForWeb() async {
    final welcome = await _appSettingsRepository.getAppSettings();
    if (!welcome) {
      await _authRepository.login();
    }
    //웹소켓
    await _audioPlayerRepository.init();
  }

  Future<void> update() async {
    _status.sink.add(InitializerStatus(
      progress: 0,
      message: "check available downloads",
    ));
    await _status.sink.addStream(_versionRepository.downloadLatest().map(
      (progress) {
        return InitializerStatus(
          progress: progress,
          message: "download latest",
        );
      },
    ));
    _status.sink.add(InitializerStatus(
      progress: 1,
      message: "waiting for update",
    ));
    await Process.start(
      '${Directory.current.path}/SetupKaranda.exe',
      ["-t", "-l", "1000", "/silent"],
    );
    windowManager.destroy();
  }

  Future<void> setWindows() async {
    final pref = SharedPreferencesAsync();
    double width = await pref.getDouble('width') ?? 1280;
    double height = await pref.getDouble('height') ?? 720;
    double? dx = await pref.getDouble('x');
    double? dy = await pref.getDouble('y');
    await windowManager.hide();
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    if (kDebugMode) {
      await windowManager.setSize(const Size(1280, 720));
    } else {
      await windowManager.setSize(Size(width, height));
    }
    await windowManager.setMinimumSize(const Size(600, 550));
    if (dx == null || dy == null || kDebugMode) {
      await windowManager.center();
    } else {
      windowManager.setPosition(Offset(dx, dy));
    }
    await windowManager.show();
  }
}
