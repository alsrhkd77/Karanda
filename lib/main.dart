import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:karanda/atoraxxion/yolunakea_moon_page.dart';
import 'package:karanda/auth/auth_error_page.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/auth/auth_page.dart';
import 'package:karanda/checklist/checklist_notifier.dart';
import 'package:karanda/checklist/checklist_page.dart';
import 'package:karanda/color_counter/color_counter_page.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/settings/version_notifier.dart';
import 'package:karanda/trade/trade_calculator_page.dart';
import 'settings/app_update_page.dart';

import 'package:window_size/window_size.dart';

import '../artifact/artifact_page.dart';
import '../event_calender/event_calendar_page.dart';
import '../home/home_page.dart';
import '../horse/horse_page.dart';
import '../settings/settings_notifier.dart';
import '../settings/settings_page.dart';
import 'atoraxxion/sycrakea_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ship_extension/ship_extension_page.dart';
import 'shutdown_scheduler/shutdown_scheduler_notifier.dart';
import 'shutdown_scheduler/shutdown_scheduler_page.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      setWindowMinSize(const Size(600, 550));
    }
  }
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
            path: 'auth/info',
            builder: (context, state) => const AuthPage(token: null, refreshToken: null,),
          ),
            GoRoute(
              path: 'auth/authenticate',
              builder: (context, state) => AuthPage(token: state.uri.queryParameters['token'], refreshToken: state.uri.queryParameters['refresh-token'],),
            ),
            GoRoute(
              path: 'desktop-app',
              builder: (context, state) => const AppUpdatePage(),
            ),
          ]
        ),
        GoRoute(
          path: 'auth/info',
          builder: (context, state) => const AuthPage(token: null, refreshToken: null,),
        ),
        GoRoute(
          path: 'auth/authenticate',
          builder: (context, state) => AuthPage(token: state.uri.queryParameters['token'], refreshToken: state.uri.queryParameters['refresh-token'],),
        ),
        GoRoute(
          path: 'auth/error',
          builder: (context, state) => const AuthErrorPage(),
        ),
        GoRoute(
          path: 'desktop-app',
          builder: (context, state) => const AppUpdatePage(),
        ),
        GoRoute(
          path: 'horse',
          builder: (context, state) => const HorsePage(),
        ),
        GoRoute(
          path: 'event-calendar',
          builder: (context, state) => const EventCalendarPage(),
        ),
        GoRoute(
          path: 'sycrakea',
          builder: (context, state) => const SycrakeaPage(),
        ),
        GoRoute(
          path: 'yolunakea-moon',
          builder: (context, state) => const YolunakeaMoonPage(),
        ),
        GoRoute(
          path: 'shutdown-scheduler',
          builder: (context, state) => const ShutdownSchedulerPage(),
        ),
        GoRoute(
          path: 'artifact',
          builder: (context, state) => const ArtifactPage(),
        ),
        GoRoute(
          path: 'ship-extension',
          builder: (context, state) => const ShipExtensionPage(),
        ),
        GoRoute(
          path: 'trade-calculator',
          builder: (context, state) => const TradeCalculatorPage(),
        ),
        GoRoute(
          path: 'auth',
          builder: (context, state) => const AuthPage(token: null, refreshToken: null,),
        ),
        GoRoute(
          path: 'checklist',
          builder: (context, state) => const ChecklistPage(),
        ),
        GoRoute(
          path: 'color-counter',
          builder: (context, state) => const ColorCounterPage(),
        ),
      ]
    ),
  ],
);

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
        ChangeNotifierProvider(
            create: (_) => VersionNotifier(rootScaffoldMessengerKey)),
        ChangeNotifierProvider(create: (_) => ShutdownSchedulerNotifier()),
        ChangeNotifierProvider(
            create: (_) => AuthNotifier(rootScaffoldMessengerKey)),
        ChangeNotifierProvider(
            create: (_) => ChecklistNotifier(rootScaffoldMessengerKey)),
        ChangeNotifierProvider(create: (_) => BdoWorldTimeNotifier()),
      ],
      child: Consumer(
        builder: (context, SettingsNotifier settings, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            title: 'Karanda',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Maplestory',
              colorSchemeSeed: Colors.blue,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Maplestory',
              colorSchemeSeed: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
