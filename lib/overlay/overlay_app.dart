import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/overlay/utils/overlay_utils.dart';
import 'package:karanda/world_boss_timer/boss_timer_overlay.dart';

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

const _floatingActionButtonTheme = FloatingActionButtonThemeData(
  backgroundColor: Colors.blue,
);

class OverlayApp extends StatelessWidget {
  final WindowController windowController;
  final Map? arguments;

  OverlayApp({super.key, required this.windowController, this.arguments}){
    setOverlay(windowTitle: arguments!["title"]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Maplestory",
        colorSchemeSeed: Colors.indigoAccent,
        brightness: Brightness.dark,
        dropdownMenuTheme: _dropdownMenuTheme,
        actionIconTheme: _actionIconTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(25, 25, 27, 1.0)),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: BossTimerOverlay(),
    );
  }
}
