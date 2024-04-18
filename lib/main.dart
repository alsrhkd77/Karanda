import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:karanda/artifact/artifact_page.dart';
import 'package:karanda/atoraxxion/yolunakea_moon_page.dart';
import 'package:karanda/auth/auth_error_page.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/auth/auth_page.dart';
import 'package:karanda/checklist/checklist_notifier.dart';
import 'package:karanda/checklist/checklist_page.dart';
import 'package:karanda/color_counter/color_counter_page.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/event_calender/event_calendar_page.dart';
import 'package:karanda/event_calender/event_calender_notifier.dart';
import 'package:karanda/home/home_page.dart';
import 'package:karanda/horse/horse_page.dart';
import 'package:karanda/initializer/initializer_page.dart';
import 'package:karanda/maretta/maretta_notifier.dart';
import 'package:karanda/maretta/maretta_page.dart';
import 'package:karanda/settings/karanda_info_page.dart';
import 'package:karanda/settings/settings_notifier.dart';
import 'package:karanda/settings/settings_page.dart';
import 'package:karanda/settings/support_karanda_page.dart';
import 'package:karanda/settings/theme_setting_page.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_page.dart';
import 'package:karanda/trade/trade_calculator_page.dart';
import 'package:karanda/trade_market/presets/cooking_box_page.dart';
import 'package:karanda/trade_market/presets/dehkias_light_page.dart';
import 'package:karanda/trade_market/presets/magical_lightstone_crystal_page.dart';
import 'package:karanda/trade_market/presets/melody_of_stars_page.dart';
import 'package:karanda/trade_market/trade_market_detail_page.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_page.dart';
import 'package:window_manager/window_manager.dart';
import 'atoraxxion/sycrakea_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ship_extension/ship_extension_page.dart';
import 'shutdown_scheduler/shutdown_scheduler_notifier.dart';
import 'shutdown_scheduler/shutdown_scheduler_page.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //usePathUrlStrategy();
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(350, 360),
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
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

final _dropdownMenuTheme = DropdownMenuThemeData(
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
);

final _actionIconTheme = ActionIconThemeData(
  backButtonIconBuilder: (BuildContext context) =>
      const Icon(Icons.arrow_back_ios_new),
);

final GoRouter _router = GoRouter(
  initialLocation: '/window-init',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
            path: 'window-init',
            builder: (context, state) => const InitializerPage(),
            redirect: (BuildContext context, GoRouterState state) {
              if (kIsWeb) {
                return '/';
              }
              return null;
            }),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'auth/info',
              builder: (context, state) => const AuthPage(
                token: null,
                refreshToken: null,
              ),
            ),
            GoRoute(
              path: 'auth/authenticate',
              builder: (context, state) => AuthPage(
                token: state.uri.queryParameters['token'],
                refreshToken: state.uri.queryParameters['refresh-token'],
              ),
            ),
            GoRoute(
              path: 'theme',
              builder: (context, state) => const ThemeSettingPage(),
            ),
            GoRoute(
              path: 'support-karanda',
              builder: (context, state) => const SupportKarandaPage(),
            ),
            GoRoute(
              path: 'karanda-info',
              builder: (context, state) => const KarandaInfoPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'auth/info',
          builder: (context, state) => const AuthPage(
            token: null,
            refreshToken: null,
          ),
        ),
        GoRoute(
          path: 'auth/authenticate',
          builder: (context, state) => AuthPage(
            token: state.uri.queryParameters['token'],
            refreshToken: state.uri.queryParameters['refresh-token'],
          ),
        ),
        GoRoute(
          path: 'auth/error',
          builder: (context, state) => const AuthErrorPage(),
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
          redirect: (context, state) => '/ship-upgrading',
        ),
        GoRoute(
          path: 'ship-upgrading',
          builder: (context, state) => const ShipUpgradingPage(),
        ),
        GoRoute(
          path: 'trade-calculator',
          builder: (context, state) => const TradeCalculatorPage(),
        ),
        GoRoute(
          path: 'auth',
          builder: (context, state) => const AuthPage(
            token: null,
            refreshToken: null,
          ),
        ),
        GoRoute(
          path: 'checklist',
          builder: (context, state) => const ChecklistPage(),
        ),
        GoRoute(
          path: 'color-counter',
          builder: (context, state) => const ColorCounterPage(),
        ),
        GoRoute(
          path: 'maretta',
          builder: (context, state) => const MarettaPage(),
        ),
        GoRoute(
          path: 'trade-market',
          builder: (context, state) => const TradeMarketPage(),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => TradeMarketDetailPage(
                code: state.extra as String?,
                name: state.uri.queryParameters['name'],
              ),
            ),
            GoRoute(
              path: 'cooking-box',
              builder: (context, state) => const CookingBoxPage(),
            ),
            GoRoute(
              path: 'melody-of-stars',
              builder: (context, state) => const MelodyOfStarsPage(),
            ),
            GoRoute(
              path: 'magical-lightstone-crystal',
              builder: (context, state) => const MagicalLightstoneCrystalPage(),
            ),
            GoRoute(
              path: 'dehkias-light',
              builder: (context, state) => const DehkiasLightPage(),
            ),
          ],
        ),
      ],
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
        ChangeNotifierProvider(
          create: (_) => SettingsNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ShutdownSchedulerNotifier()),
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(rootScaffoldMessengerKey, _router),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<AuthNotifier, ChecklistNotifier>(
          create: (_) => ChecklistNotifier(rootScaffoldMessengerKey),
          update: (_, authNotifier, checklistNotifier) {
            if (authNotifier.authenticated) {
              checklistNotifier!.getAllChecklistItems();
            }
            return checklistNotifier!;
          },
        ),
        ChangeNotifierProvider(create: (_) => TradeMarketNotifier()),
        ChangeNotifierProvider(
          create: (_) => BdoWorldTimeNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => MarettaNotifier()),
        ChangeNotifierProvider(create: (_) => RealTimeNotifier()),
        ChangeNotifierProvider(create: (_) => EventCalenderNotifier()),
      ],
      child: Consumer(
        builder: (context, SettingsNotifier settings, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            title: 'Karanda - 카란다',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: toBeginningOfSentenceCase(settings.fontFamily.name),
              colorSchemeSeed: Colors.blue,
              dropdownMenuTheme: _dropdownMenuTheme,
              actionIconTheme: _actionIconTheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: toBeginningOfSentenceCase(settings.fontFamily.name),
              colorSchemeSeed: Colors.blueAccent,
              brightness: Brightness.dark,
              dropdownMenuTheme: _dropdownMenuTheme,
              actionIconTheme: _actionIconTheme,
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
