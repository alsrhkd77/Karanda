import 'dart:ui';

import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopService {
  final AppSettingsRepository _appSettingsRepository;
  final OverlayRepository _overlayRepository;

  DesktopService({
    required AppSettingsRepository appSettingsRepository,
    required OverlayRepository overlayRepository,
  })  : _appSettingsRepository = appSettingsRepository,
        _overlayRepository = overlayRepository;

  Future<void> _exitApp() async {
    // 오버레이 자식 창 정리는 단일 소유자(OverlayRepository.teardown)에 위임한다.
    await _overlayRepository.teardown();
    await windowManager.hide();
    await trayManager.destroy();
    await windowManager.destroy();
  }

  Future<void> onTrayIconMouseUp() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> onTrayIconRightMouseUp() async {
    await trayManager.popUpContextMenu();
  }

  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case "show":
        await windowManager.show();
        await windowManager.focus();
        break;
      case "hide":
        await windowManager.hide();
        break;
      case "quit":
        _exitApp();
        break;
      default:
        break;
    }
  }

  Future<void> onWindowClose() async {
    if (_appSettingsRepository.settings.useTrayMode) {
      await windowManager.hide();
    } else {
      await _exitApp();
    }
  }

  Future<void> onWindowResized() async {
    Size size = await windowManager.getSize();
    _appSettingsRepository.setWindowSize(size);
  }

  Future<void> onWindowMoved() async {
    Offset position = await windowManager.getPosition();
    _appSettingsRepository.setWindowOffset(position);
  }
}
