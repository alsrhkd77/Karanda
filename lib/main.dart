import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/firebase_options.dart';
import 'package:karanda/route.dart';
import 'package:karanda/settings/settings_notifier.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/ui/app/karanda_app.dart';
import 'package:karanda/ui/overlay_app/widgets/overlay_app.dart';
import 'package:karanda/ui/settings/controller/settings_controller.dart';
import 'package:karanda/utils/command_line_arguments.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shutdown_scheduler/shutdown_scheduler_notifier.dart';
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
      /*FirebaseMessaging.instance
          .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      )
          .then((settings) async {
        if (settings.authorizationStatus != AuthorizationStatus.denied) {
          final fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey: kIsWeb ? const String.fromEnvironment('VAPID') : null,
          );
        }
      });*/
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

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /* Old */
        ChangeNotifierProvider(
          create: (_) => SettingsNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ShutdownSchedulerNotifier()),
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(rootScaffoldMessengerKey, router),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => TradeMarketNotifier()),
        ChangeNotifierProvider(
          create: (_) => BdoWorldTimeNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => RealTimeNotifier()),
      ],
      child: Consumer(
        builder: (context, SettingsController controller, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router,
            title: 'Karanda - 카란다',
            themeMode: controller.themeMode,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: controller.textTheme(AppTheme.lightTheme.textTheme),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: controller.textTheme(AppTheme.darkTheme.textTheme),
            ),
          );
        },
      ),
    );
  }
}
