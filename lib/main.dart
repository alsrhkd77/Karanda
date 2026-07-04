import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:karanda/firebase_options.dart';
import 'package:karanda/ui/app/karanda_app.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_app.dart';
import 'package:karanda/utils/command_line_arguments.dart';
import 'package:logging/logging.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;

/// 앱 전역 오류 로그. 미처리 예외를 운영 로그(`OperationLogService`가 `Logger.root` 구독)로
/// 남겨, 초기화 단계 등에서 조용히 죽는 문제를 진단할 수 있게 한다.
final _log = Logger('app');

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 전역 오류 핸들러 (메인·오버레이 두 진입 모두 적용).
  // runZonedGuarded 대신 프레임워크 권장 방식을 써서 바인딩 zone 불일치 문제를 피한다.
  FlutterError.onError = (details) {
    // 빌드/레이아웃 등 프레임워크 오류: 디버그 표시는 유지하고 로그로도 남긴다.
    _log.severe('Flutter framework error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // 그 외 async/zone에서 잡히지 않은 오류: 로그만 남기고 앱은 유지한다.
    _log.severe('Uncaught error', error, stack);
    return true;
  };

  usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  Widget app;

  if (args.firstOrNull == 'multi_window') {
    /* Start up overlay */
    final windowId = int.parse(args[1]);
    WindowController.fromWindowId(windowId);
    final Map arguments = args[2].isEmpty ? {} : jsonDecode(args[2]);
    app = OverlayApp(
      arguments: arguments,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    );
  } else {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        CommandLineArguments.setArguments(args);
        await windowManager.ensureInitialized();
        await windowManager.setPreventClose(true);
        WindowOptions windowOptions = const WindowOptions(
          size: Size(360, 380),
          center: true,
          title: "Karanda",
          titleBarStyle: TitleBarStyle.hidden,
        );
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }
    }
    if (kIsWeb || Platform.isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    //WebSocketManager();
    MediaKit.ensureInitialized();
    //app = MyApp();
    app = KarandaApp(scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>());
  }
  initializeDateFormatting().then((_) => runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ko', 'KR'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('en', 'US'),
          child: app,
        ),
      ));
}
