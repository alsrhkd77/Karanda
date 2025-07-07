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
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
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
