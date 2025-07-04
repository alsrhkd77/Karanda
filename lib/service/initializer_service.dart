import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tray_manager/tray_manager.dart';
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
    if (kIsWeb) {
      initializeForWeb();
    } else if(Platform.isWindows) {
      initializeForWindows();
    } else if(Platform.isAndroid){
      initializeForAndroid();
    }
  }

  Stream<InitializerStatus> get initializerStatus => _status.stream;

  Future<void> initializeForWindows() async {
    await Future.delayed(const Duration(seconds: 1));
    int process = 7;
    _status.sink.add(InitializerStatus(
      progress: 0 / process,
      message: "check update",
    ));
    if (CommandLineArguments.forceUpdate) {
      await update();
      return;
    }
    if (!CommandLineArguments.skipUpdate) {
      try {
        final currentVersion = await _versionRepository.getCurrentVersion();
        final latestVersion = await _versionRepository.getLatestVersion();
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
    final overlaySettings = await _overlayRepository.loadSettings();
    await _overlayRepository.startOverlay(overlaySettings.monitorDevice);
    await _overlayRepository.sendOverlaySettings(overlaySettings);
    _status.sink.add(InitializerStatus(
      progress: 3 / process,
      message: "authenticate",
    ));
    await _authRepository.login();
    _status.sink.add(InitializerStatus(
      progress: 4 / process,
      message: "start tray",
    ));
    await startTray();
    _status.sink.add(InitializerStatus(
      progress: 5 / process,
      message: "connect websocket",
    ));
    _status.sink.add(InitializerStatus(
      progress: 6 / process,
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

  Future<void> initializeForAndroid() async {
    final welcome = await _appSettingsRepository.getAppSettings();
    if (!welcome) {
      await _authRepository.login();
    }
    await _audioPlayerRepository.init();
    AppLinks().uriLinkStream.listen((uri) => _router.goWithGa(uri.fragment));
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
    await windowManager.hide();
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    if (kDebugMode) {
      await windowManager.setSize(const Size(1280, 720));
    } else {
      await windowManager.setSize(_appSettingsRepository.settings.windowSize);
    }
    await windowManager.setMinimumSize(const Size(600, 550));
    if (_appSettingsRepository.settings.windowOffset == null || kDebugMode) {
      await windowManager.center();
    } else {
      windowManager.setPosition(_appSettingsRepository.settings.windowOffset!);
    }
    if (!_appSettingsRepository.settings.startMinimized) {
      await windowManager.show();
    } else if (!_appSettingsRepository.settings.useTrayMode) {
      await windowManager.minimize();
    }
  }

  Future<void> startTray() async {
    await trayManager.setIcon("assets/brand/app_icon.ico");
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: "windowsTray.show".tr(),
        ),
        MenuItem(
          key: 'hide',
          label: "windowsTray.hide".tr(),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'cancel',
          label: "windowsTray.cancel".tr(),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'quit',
          label: "windowsTray.quit".tr(),
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
}
