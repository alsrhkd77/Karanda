import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/overlay/overlay_window.dart';

class OverlayApp extends StatelessWidget {
  final WindowController windowController;
  final Map? arguments;

  OverlayApp({super.key, required this.windowController, this.arguments}){
    //setOverlay(windowTitle: arguments!["title"]);
    //arguments?["show"] ? showOverlay(windowTitle: arguments!["title"]) : hideOverlay(windowTitle: arguments!["title"]);
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
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const OverlayWindow(),
    );
  }
}
