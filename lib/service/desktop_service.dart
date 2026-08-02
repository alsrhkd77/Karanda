import 'dart:ui';

import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/service/operation_log_service.dart';
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

  /// 프로세스가 사라지기 전에 반드시 끝내야 할 일.
  ///
  /// 종료 경로가 여럿(트레이 종료·창 닫기·업데이트 설치)이라 한 곳에 모은다.
  /// 두 flush는 디바운스·fire-and-forget 저장이 완료되기 전에 프로세스가 죽는 것을 막는다.
  Future<void> prepareShutdown() async {
    await OperationLogService.instance.flush();
    await _appSettingsRepository.flush();
    // 오버레이 자식 창 정리는 단일 소유자(OverlayRepository.teardown)에 위임한다.
    await _overlayRepository.teardown();
  }

  Future<void> _exitApp() async {
    await prepareShutdown();
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
