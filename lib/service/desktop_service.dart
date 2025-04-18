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
      final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();
      for (final windowId in subWindowIds) {
        WindowController controller = WindowController.fromWindowId(windowId);
        await controller.close();
      }
    } catch (e) {
      developer.log('Failed to get SubWindowIds\n$e', name: 'overlay');
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
