import 'package:karanda/settings/app_update_page.dart';

import '../artifact/artifact_page.dart';
import '../event_calender/event_calender_page.dart';
import '../home/home_page.dart';
import '../horse/horse_page.dart';
import '../settings/settings_notifier.dart';
import '../settings/settings_page.dart';
import '../sikarakia/sikarakia_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsNotifier(),
      child: Consumer(
        builder: (context, SettingsNotifier _settings, _) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Karanda',
            theme: _settings.darkMode ? ThemeData.dark() : ThemeData.light(),
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const HomePage()),
              GetPage(name: '/settings', page: () => const SettingsPage()),
              GetPage(name: '/horse', page: () => const HorsePage()),
              GetPage(name: '/event-calender', page: () => const EventCalenderPage()),
              GetPage(name: '/sikarakia', page: () => const SikarakiaPage()),
              GetPage(name: '/artifact', page: () => const ArtifactPage()),
              GetPage(name: '/desktop-app', page: () => const AppUpdatePage()),
            ],
          );
        },
      ),
    );
  }
}
