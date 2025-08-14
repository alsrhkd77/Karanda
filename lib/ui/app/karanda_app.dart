import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/data_source/party_finder_api.dart';
import 'package:karanda/data_source/app_settings_data_source.dart';
import 'package:karanda/data_source/audio_player_data_source.dart';
import 'package:karanda/data_source/auth_api.dart';
import 'package:karanda/data_source/bdo_family_api.dart';
import 'package:karanda/data_source/overlay_api.dart';
import 'package:karanda/data_source/overlay_settings_data_source.dart';
import 'package:karanda/data_source/trade_market_api.dart';
import 'package:karanda/data_source/trade_market_data_source.dart';
import 'package:karanda/data_source/user_fcm_settings_api.dart';
import 'package:karanda/data_source/version_data_source.dart';
import 'package:karanda/data_source/web_socket_manager.dart';
import 'package:karanda/data_source/world_boss_data_source.dart';
import 'package:karanda/repository/party_finder_repository.dart';
import 'package:karanda/repository/app_notification_repository.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/repository/bdo_item_info_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/repository/user_fc_settings_repository.dart';
import 'package:karanda/repository/time_repository.dart';
import 'package:karanda/repository/trade_market_repository.dart';
import 'package:karanda/repository/version_repository.dart';
import 'package:karanda/repository/world_boss_repository.dart';
import 'package:karanda/route.dart';
import 'package:karanda/service/party_finder_service.dart';
import 'package:karanda/service/app_notification_service.dart';
import 'package:karanda/service/app_settings_service.dart';
import 'package:karanda/service/auth_service.dart';
import 'package:karanda/service/bdo_item_info_service.dart';
import 'package:karanda/service/desktop_service.dart';
import 'package:karanda/service/initializer_service.dart';
import 'package:karanda/service/trade_market_service.dart';
import 'package:karanda/service/world_boss_service.dart';
import 'package:karanda/ui/core/controller/time_controller.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/ui/settings/controller/settings_controller.dart';
import 'package:provider/provider.dart';

class KarandaApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const KarandaApp({super.key, required this.scaffoldMessengerKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => AppSettingsDataSource()),
        Provider(
          create: (context) => AppSettingsRepository(
            settingsDataSource: context.read(),
          ),
        ),
        Provider(create: (context) => VersionDataSource()),
        Provider(
            create: (context) => VersionRepository(dataSource: context.read())),
        Provider(create: (context) => AudioPlayerDataSource()),
        Provider(
          create: (context) => AudioPlayerRepository(
            dataSource: context.read(),
          ),
          lazy: false,
        ),
        Provider(create: (context) => OverlaySettingsDataSource()),
        Provider(create: (context) => OverlayApi()),
        Provider(
          create: (context) => OverlayRepository(
            overlaySettingsDataSource: context.read(),
            overlayApi: context.read(),
          ),
        ),
        Provider(create: (context) => AuthApi()),
        Provider(create: (context) => BDOFamilyApi()),
        Provider(
          create: (context) => AuthRepository(
            authApi: context.read(),
            familyApi: context.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthService(
            authRepository: context.read(),
            router: router,
          ),
        ),
        Provider(create: (context) => UserFcmSettingsApi()),
        Provider(
          create: (context) => UserFcmSettingsRepository(
            userFcmSettingsApi: context.read(),
          ),
        ),
        Provider(
          create: (context) => AppSettingsService(
            authRepository: context.read(),
            audioPlayerRepository: context.read(),
            settingsRepository: context.read(),
            userFcmSettingsRepository: context.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsController(
            settingsService: context.read(),
          ),
        ),
        Provider(
          create: (context) => InitializerService(
            appSettingsRepository: context.read(),
            overlayRepository: context.read(),
            versionRepository: context.read(),
            authRepository: context.read(),
            audioPlayerRepository: context.read(),
            scaffoldMessengerKey: scaffoldMessengerKey,
            router: router,
          ),
          lazy: false,
        ),
        Provider(create: (context) => BDOItemInfoRepository()),
        ChangeNotifierProvider(
          create: (context) => BDOItemInfoService(
            itemInfoRepository: context.read(),
          ),
          lazy: false,
        ),
        /* 후행 */
        Provider(create: (context) => TimeRepository()),
        Provider(create: (context) => WebSocketManager()),
        Provider(
          create: (context) => AppNotificationRepository(
            webSocketManager: context.read(),
          ),
        ),
        Provider(create: (context) => PartyFinderApi()),
        Provider(
          create: (context) => PartyFinderRepository(
            webSocketManager: context.read(),
            partyFinderApi: context.read(),
          ),
        ),
        Provider(
          create: (context) => AppNotificationService(
            appNotificationRepository: context.read(),
            audioPlayerRepository: context.read(),
            overlayRepository: context.read(),
            appSettingsRepository: context.read(),
            authRepository: context.read(),
            partyFinderRepository: context.read(),
            scaffoldMessengerKey: scaffoldMessengerKey,
          ),
          lazy: false,
        ),
        Provider(create: (context) => WorldBossDataSource()),
        Provider(
          create: (context) => WorldBossRepository(
            worldBossDataSource: context.read(),
          ),
        ),
        Provider(
          create: (context) => WorldBossService(
            settingsRepository: context.read(),
            worldBossRepository: context.read(),
            timeRepository: context.read(),
            notificationRepository: context.read(),
            overlayRepository: context.read(),
          ),
          lazy: false,
        ),
        Provider(create: (context) => TradeMarketApi()),
        Provider(create: (context) => TradeMarketDataSource()),
        Provider(
          create: (context) => TradeMarketRepository(
            tradeMarketApi: context.read(),
            tradeMarketDataSource: context.read(),
            webSocketManager: context.read(),
          ),
        ),
        Provider(
          create: (context) => TradeMarketService(
              tradeMarketRepository: context.read(),
              settingsRepository: context.read(),
              itemInfoRepository: context.read()),
          lazy: !kIsWeb && Platform.isWindows,
        ),
        Provider(
          create: (context) => PartyFinderService(
            authRepository: context.read(),
            appSettingsRepository: context.read(),
            partyFinderRepository: context.read(),
            overlayRepository: context.read(),
          ),
          lazy: kIsWeb || !Platform.isWindows,
        ),
        Provider(
          create: (context) => DesktopService(
            appSettingsRepository: context.read(),
          ),
          lazy: kIsWeb || !Platform.isWindows,
        ),
        ChangeNotifierProvider(
          create: (context) => TimeController(timeRepository: context.read()),
        ),
      ],
      child: Consumer(
        builder: (context, SettingsController controller, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: scaffoldMessengerKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router,
            title: 'Karanda - 카란다',
            themeMode: controller.themeMode,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: controller.textTheme(AppTheme.lightTheme.textTheme),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: controller.textTheme(AppTheme.darkTheme.textTheme),
            ),
          );
        },
      ),
    );
  }
}
