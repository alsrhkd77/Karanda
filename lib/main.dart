import 'package:black_tools/home/home_page.dart';
import 'package:black_tools/settings/settings_notifier.dart';
import 'package:flutter/material.dart';
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
        builder: (context,SettingsNotifier _settings, _){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Black tools Demo',
            theme: _settings.darkMode ? ThemeData.dark() : ThemeData.light(),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}