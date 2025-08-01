import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/data_source/overlay_app_data_source.dart';
import 'package:karanda/repository/overlay_app_repository.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/service/overlay_app_service.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/ui/overlay_app/controllers/overlay_app_controller.dart';
import 'package:provider/provider.dart';

import 'overlay_app_screen.dart';

class OverlayApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Map arguments;

  const OverlayApp({
    super.key,
    required this.scaffoldMessengerKey,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => OverlayAppDataSource()),
        Provider(
          create: (context) => OverlayAppRepository(
            appDataSource: context.read(),
          ),
          lazy: false,
        ),
        Provider(
          create: (context) => OverlayAppService(
            appRepository: context.read(),
            scaffoldMessengerKey: scaffoldMessengerKey,
          ),
          lazy: false,
        ),
        Provider(create: (context) => TimeRepository()),
        ChangeNotifierProvider(
          create: (context) => OverlayAppController(appService: context.read()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Karanda Overlay",
        scaffoldMessengerKey: scaffoldMessengerKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.overlayAppTheme,
        home: const OverlayAppScreen(),
      ),
    );
  }
}
