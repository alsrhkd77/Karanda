import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/checklist/checklist_notifier.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/command_line_arguments.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/maretta/maretta_notifier.dart';
import 'package:karanda/overlay/overlay_app.dart';
import 'package:karanda/route.dart';
import 'package:karanda/settings/settings_notifier.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shutdown_scheduler/shutdown_scheduler_notifier.dart';
//import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  //usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  Widget app;

  if(args.firstOrNull == 'multi_window'){
    /* Start up overlay */
    await Window.initialize();
    await Window.setEffect(effect: WindowEffect.transparent);
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty ? {} : jsonDecode(args[2]);
    app = OverlayApp(
      windowController: WindowController.fromWindowId(windowId),
      arguments: arguments,
    );
  } else {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        CommandLineArguments.setArguments(args);
        await windowManager.ensureInitialized();
        await windowManager.setPreventClose(true);
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
    MediaKit.ensureInitialized();
    app = MyApp();
  }
  initializeDateFormatting().then((_) => runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko', 'KR'),
      child: app,
    ),
  ));
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

const _floatingActionButtonTheme = FloatingActionButtonThemeData(
  backgroundColor: Colors.blue,
);

InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Colors.blue),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
);

class MyApp extends StatelessWidget {
  MyApp({Key? key, }) : super(key: key);
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
          create: (_) => AuthNotifier(rootScaffoldMessengerKey, router),
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
      ],
      child: Consumer(
        builder: (context, SettingsNotifier settings, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'Karanda - 카란다',
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: toBeginningOfSentenceCase(settings.fontFamily.name),
              colorSchemeSeed: const Color.fromRGBO(87, 132, 193, 1.0),
              dropdownMenuTheme: _dropdownMenuTheme,
              actionIconTheme: _actionIconTheme,
              floatingActionButtonTheme: _floatingActionButtonTheme,
              inputDecorationTheme: _inputDecorationTheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: toBeginningOfSentenceCase(settings.fontFamily.name),
              colorSchemeSeed: Colors.indigoAccent,
              //colorSchemeSeed: Color.fromRGBO(87, 132, 193, 1.0),
              //colorSchemeSeed: Color.fromRGBO(61, 133, 184, 1.0),
              //colorSchemeSeed: Color.fromRGBO(164, 210, 224, 1.0),
              brightness: Brightness.dark,
              dropdownMenuTheme: _dropdownMenuTheme,
              actionIconTheme: _actionIconTheme,
              floatingActionButtonTheme: _floatingActionButtonTheme,
              inputDecorationTheme: _inputDecorationTheme,
              //appBarTheme: AppBarTheme(backgroundColor: Color.fromRGBO(24, 24, 24, 1.0)),
              appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromRGBO(25, 25, 27, 1.0)),
              //scaffoldBackgroundColor: Color.fromRGBO(24, 24, 24, 1.0),
              scaffoldBackgroundColor: const Color.fromRGBO(25, 25, 27, 1.0),
              //scaffoldBackgroundColor: const Color.fromRGBO(20, 20, 24, 1.0),
              //cardTheme: CardTheme(color: Color.fromRGBO(40, 40, 40, 1.0)),
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
