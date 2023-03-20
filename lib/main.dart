import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/atoraxxion/yolunakea_moon_page.dart';
import 'package:karanda/settings/version_notifier.dart';
import 'package:karanda/trade/parley_calculator_page.dart';
import 'package:karanda/trade/trade_calculator_page.dart';
import 'settings/app_update_page.dart';
import 'settings/experimental_function_page.dart';
import 'trade/crow_coin_exchange_page.dart';
import 'trade/material_cost_calculator_page.dart';
import 'trade/overloaded_ship_page.dart';
import 'trade/trade_home_page.dart';
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
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
      ],
      child: Consumer2(
        builder: (context, SettingsNotifier _settings,
            VersionNotifier _versionNotifier, _) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            title: 'Karanda',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: GoogleFonts.gothicA1().fontFamily,
              colorSchemeSeed: Colors.blue,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: GoogleFonts.gothicA1().fontFamily,
              colorSchemeSeed: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            themeMode: _settings.darkMode ? ThemeMode.dark : ThemeMode.light,
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
              /* unused */
              GetPage(
                  name: '/overloaded-ship',
                  page: () => const OverloadedShipPage()),
              GetPage(
                  name: '/crow-coin', page: () => const CrowCoinExchangePage()),
              GetPage(
                  name: '/material-cost-calculator',
                  page: () => const MaterialCostCalculatorPage()),
              GetPage(name: '/trade-home', page: () => const TradeHomePage()),
              GetPage(name: '/parley-calculator', page: () => const ParleyCalculatorPage()),
            ],
          );
        },
      ),
    );
  }
}
