import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:developer' as developer;

class DesktopService {
  final AppSettingsRepository _appSettingsRepository;

  DesktopService({required AppSettingsRepository appSettingsRepository})
      : _appSettingsRepository = appSettingsRepository;

  Future<void> _exitApp() async {
    try {
      // desktop_multi_window 0.3에는 WindowController.close()가 없으므로 서브윈도우는
      // 여기서 숨기고, 아래에서 프로세스가 종료될 때 함께 정리된다.
      final subWindows = await WindowController.getAll();
      for (final controller in subWindows) {
        await controller.hide();
      }
    } catch (e) {
      developer.log('Failed to close sub windows\n$e', name: 'overlay');
    }
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
