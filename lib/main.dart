import 'package:black_tools/artifact/artifact_page.dart';
import 'package:black_tools/event_calender/event_calender_page.dart';
import 'package:black_tools/home/home_page.dart';
import 'package:black_tools/horse/horse_page.dart';
import 'package:black_tools/settings/settings_notifier.dart';
import 'package:black_tools/settings/settings_page.dart';
import 'package:black_tools/sikarakia/sikarakia_page.dart';
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
            title: 'Black tools Demo',
            theme: _settings.darkMode ? ThemeData.dark() : ThemeData.light(),
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const HomePage()),
              GetPage(name: '/settings', page: () => const SettingsPage()),
              GetPage(name: '/horse', page: () => const HorsePage()),
              GetPage(name: '/event-calender', page: () => const EventCalenderPage()),
              GetPage(name: '/sikarakia', page: () => const SikarakiaPage()),
              GetPage(name: '/artifact', page: () => const ArtifactPage()),
            ],
          );
        },
      ),
    );
  }
}
