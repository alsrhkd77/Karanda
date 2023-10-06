import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:karanda/atoraxxion/yolunakea_moon_page.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/auth/auth_page.dart';
import 'package:karanda/checklist/checklist_notifier.dart';
import 'package:karanda/checklist/checklist_page.dart';
import 'package:karanda/color_counter/color_counter_page.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/settings/version_notifier.dart';
import 'package:karanda/trade/trade_calculator_page.dart';
import 'settings/app_update_page.dart';
import 'settings/experimental_function_page.dart';

import 'package:window_size/window_size.dart';

import '../artifact/artifact_page.dart';
import '../event_calender/event_calender_page.dart';
import '../home/home_page.dart';
import '../horse/horse_page.dart';
import '../settings/settings_notifier.dart';
import '../settings/settings_page.dart';
import 'atoraxxion/sycrakea_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'ship_extension/ship_extension_page.dart';
import 'shutdown_scheduler/shutdown_scheduler_notifier.dart';
import 'shutdown_scheduler/shutdown_scheduler_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      setWindowMinSize(const Size(600, 550));
    }
  }
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

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
        ChangeNotifierProvider(create: (_) => AuthNotifier(rootScaffoldMessengerKey)),
        ChangeNotifierProvider(create: (_) => ChecklistNotifier(rootScaffoldMessengerKey)),
        ChangeNotifierProvider(create: (_) => BdoWorldTimeNotifier()),
      ],
      child: Consumer(
        builder: (context, SettingsNotifier settings, _) {
          return GetMaterialApp(
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
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const HomePage()),
              GetPage(name: '/settings', page: () => const SettingsPage()),
              GetPage(name: '/desktop-app', page: () => const AppUpdatePage()),
              GetPage(
                  name: '/experimental-function',
                  page: () => const ExperimentalFunctionPage()),
              GetPage(name: '/horse', page: () => const HorsePage()),
              GetPage(
                  name: '/event-calender',
                  page: () => const EventCalenderPage()),
              GetPage(name: '/sycrakea', page: () => const SycrakeaPage()),
              GetPage(
                  name: '/yolunakea-moon',
                  page: () => const YolunakeaMoonPage()),
              GetPage(name: '/artifact', page: () => const ArtifactPage()),
              GetPage(
                  name: '/shutdown-scheduler',
                  page: () => const ShutdownSchedulerPage()),
              GetPage(
                  name: '/ship-extension',
                  page: () => const ShipExtensionPage()),
              GetPage(name: '/trade-calculator', page: () => const TradeCalculatorPage()),
              GetPage(name: '/auth/:auth', page: () => const AuthPage()),
              GetPage(name: '/checklist', page: () => const ChecklistPage()),
              GetPage(name: '/color-counter', page: () => const ColorCounterPage()),
            ],
          );
        },
      ),
    );
  }
}
