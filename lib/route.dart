import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/adventurer_hub/adventurer_hub_page.dart';
import 'package:karanda/adventurer_hub/recruitment_detail_page.dart';
import 'package:karanda/artifact/artifact_page.dart';
import 'package:karanda/bdo_news/event_calendar/event_calendar_page.dart';
import 'package:karanda/color_counter/color_counter_page.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/obs_widgets/obs_bdo_timer/obs_bdo_timer_page.dart';
import 'package:karanda/obs_widgets/partrigio_page.dart';
import 'package:karanda/service/auth_service.dart';
import 'package:karanda/settings/change_log_page.dart';
import 'package:karanda/settings/karanda_info_page.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_page.dart';
import 'package:karanda/shutdown_scheduler/shutdown_scheduler_page.dart';
import 'package:karanda/trade/trade_calculator_page.dart';
import 'package:karanda/ui/auth/widgets/auth_error_page.dart';
import 'package:karanda/ui/auth/widgets/auth_info_page.dart';
import 'package:karanda/ui/auth/widgets/auth_page.dart';
import 'package:karanda/ui/auth/widgets/authenticate_page.dart';
import 'package:karanda/ui/core/ui/loading_indicator_page.dart';
import 'package:karanda/ui/core/ui/not_found_page.dart';
import 'package:karanda/ui/home/widget/home_page.dart';
import 'package:karanda/ui/overlay/widgets/overlay_page.dart';
import 'package:karanda/ui/settings/widget/settings_page.dart';
import 'package:karanda/ui/settings/widget/style_settings_page.dart';
import 'package:karanda/ui/settings/widget/support_karanda_page.dart';
import 'package:karanda/ui/trade_market/presets/widgets/trade_market_cooking_box_preset_page.dart';
import 'package:karanda/ui/trade_market/presets/widgets/trade_market_preset_page.dart';
import 'package:karanda/ui/trade_market/widgets/trade_market_detail_page.dart';
import 'package:karanda/ui/trade_market/widgets/trade_market_page.dart';
import 'package:karanda/ui/welcome/widgets/welcome_page.dart';
import 'package:karanda/ui/windows_initializer/widgets/windows_initializer_page.dart';
import 'package:karanda/ui/world_boss/widgets/world_boss_page.dart'
    show WorldBossPage;
import 'package:karanda/widgets/invalid_access_page.dart';
import 'package:karanda/widgets/loading_page.dart';
import 'package:provider/provider.dart';

import 'deprecated/atoraxxion/sycrakea_page.dart';
import 'deprecated/atoraxxion/yolunakea_moon_page.dart';
import 'deprecated/horse_status/horse_status_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/window-init',
  //debugLogDiagnostics: kDebugMode,
  onException: (_, GoRouterState state, GoRouter router) {
    router.go("/not-found");
  },
  routes: [
    GoRoute(
      path: '/not-found',
      builder: (context, state) => const NotFoundPage(),
    ),
    GoRoute(
      path: '/window-init',
      builder: (context, state) => const WindowsInitializerPage(),
      redirect: (BuildContext context, GoRouterState state) {
        if (kIsWeb || !Platform.isWindows) {
          return '/';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'auth',
          builder: (context, state) {
            if (context.watch<AuthService>().waitResponse) {
              return const LoadingIndicatorPage();
            }
            return context.watch<AuthService>().authenticated
                ? const AuthInfoPage()
                : const AuthPage();
          },
          routes: [
            GoRoute(
              path: 'authenticate',
              builder: (context, state) => AuthenticatePage(
                token: state.uri.queryParameters['token']!,
                refreshToken: state.uri.queryParameters['refresh-token']!,
              ),
              redirect: (BuildContext context, GoRouterState state) {
                if (!state.uri.queryParameters.containsKey('token') ||
                    !state.uri.queryParameters.containsKey('refresh-token')) {
                  return '/not-found';
                }
                return null;
              },
            ),
            GoRoute(
              path: 'error',
              builder: (context, state) => const AuthErrorPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'styles',
              builder: (context, state) => const StyleSettingsPage(),
            ),
            GoRoute(
              path: 'support-karanda',
              builder: (context, state) => const SupportKarandaPage(),
            ),
            GoRoute(
              path: 'change-log',
              builder: (context, state) => const ChangeLogPage(),
            ),
            GoRoute(
              path: 'karanda-info',
              builder: (context, state) => const KarandaInfoPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'trade-market',
          builder: (context, state) => const TradeMarketPage(),
          routes: [
            GoRoute(
              path: ':region/detail/:code',
              builder: (context, state) {
                final region =
                    BDORegion.values.byName(state.pathParameters["region"]!);
                return TradeMarketDetailPage(
                  code: state.pathParameters['code']!,
                  region: region,
                );
              },
              redirect: (BuildContext context, GoRouterState state) {
                if (!state.pathParameters.containsKey("region") ||
                    !BDORegion.values
                        .map((value) => value.name)
                        .contains(state.pathParameters["region"]) ||
                    !state.pathParameters.containsKey("code")) {
                  return 'not-found';
                }
                return null;
              },
            ),
            GoRoute(
              path: ':region/cooking-box',
              builder: (context, state) {
                final region =
                    BDORegion.values.byName(state.pathParameters["region"]!);
                return TradeMarketCookingBoxPresetPage(region: region);
              },
              redirect: (BuildContext context, GoRouterState state) {
                if (!state.pathParameters.containsKey("region") ||
                    !BDORegion.values
                        .map((value) => value.name)
                        .contains(state.pathParameters["region"])) {
                  return 'not-found';
                }
                return null;
              },
            ),
            GoRoute(
              path: ':region/melody-of-stars',
              builder: (context, state) {
                final region =
                    BDORegion.values.byName(state.pathParameters["region"]!);
                return TradeMarketPresetPage(
                  presetKey: "melody_of_stars",
                  region: region,
                );
              },
              redirect: (BuildContext context, GoRouterState state) {
                if (!state.pathParameters.containsKey("region") ||
                    !BDORegion.values
                        .map((value) => value.name)
                        .contains(state.pathParameters["region"])) {
                  return 'not-found';
                }
                return null;
              },
            ),
            GoRoute(
              path: ':region/magical-lightstone-crystal',
              builder: (context, state) {
                final region =
                    BDORegion.values.byName(state.pathParameters["region"]!);
                return TradeMarketPresetPage(
                  presetKey: "magical_lightstone_crystal",
                  region: region,
                );
              },
              redirect: (BuildContext context, GoRouterState state) {
                if (!state.pathParameters.containsKey("region") ||
                    !BDORegion.values
                        .map((value) => value.name)
                        .contains(state.pathParameters["region"])) {
                  return 'not-found';
                }
                return null;
              },
            ),
            GoRoute(
              path: ':region/dehkias-light',
              builder: (context, state) {
                final region =
                    BDORegion.values.byName(state.pathParameters["region"]!);
                return TradeMarketPresetPage(
                  presetKey: "dehkias_light",
                  region: region,
                );
              },
              redirect: (BuildContext context, GoRouterState state) {
                if (!state.pathParameters.containsKey("region") ||
                    !BDORegion.values
                        .map((value) => value.name)
                        .contains(state.pathParameters["region"])) {
                  return 'not-found';
                }
                return null;
              },
            ),
          ],
        ),
        GoRoute(
          path: 'world-boss',
          builder: (context, state) => const WorldBossPage(),
        ),
        GoRoute(
          path: 'overlay',
          builder: (context, state) => const OverlayPage(),
          redirect: (BuildContext context, GoRouterState state) {
            if (kIsWeb || !Platform.isWindows) {
              return '/';
            }
            return null;
          },
        ),
        /*GoRoute(
          path: 'auth',
          builder: (context, state) => const AuthPage(
            token: null,
            refreshToken: null,
          ),
        ),
        GoRoute(
          path: 'auth/info',
          builder: (context, state) => const AuthPage(
            token: null,
            refreshToken: null,
          ),
        ),
        GoRoute(
          path: 'auth/authenticate',
          builder: (context, state) => AuthPage(
            token: state.uri.queryParameters['token'],
            refreshToken: state.uri.queryParameters['refresh-token'],
          ),
        ),
        GoRoute(
          path: 'auth/error',
          builder: (context, state) => const AuthErrorPage(),
        ),*/
        GoRoute(
          path: 'horse',
          builder: (context, state) => const HorseStatusPage(),
        ),
        GoRoute(
          path: 'event-calendar',
          builder: (context, state) => const EventCalendarPage(),
        ),
        GoRoute(
          path: 'sycrakea',
          builder: (context, state) => const SycrakeaPage(),
        ),
        GoRoute(
          path: 'yolunakea-moon',
          builder: (context, state) => const YolunakeaMoonPage(),
        ),
        GoRoute(
          path: 'shutdown-scheduler',
          builder: (context, state) => const ShutdownSchedulerPage(),
        ),
        GoRoute(
          path: 'artifact',
          builder: (context, state) => const ArtifactPage(),
        ),
        GoRoute(
          path: 'ship-extension',
          builder: (context, state) => const ShipUpgradingPage(),
          redirect: (context, state) => '/ship-upgrading',
        ),
        GoRoute(
          path: 'ship-upgrading',
          builder: (context, state) => const ShipUpgradingPage(),
        ),
        GoRoute(
          path: 'trade-calculator',
          builder: (context, state) => const TradeCalculatorPage(),
        ),
        GoRoute(
          path: 'color-counter',
          builder: (context, state) => const ColorCounterPage(),
        ),
        GoRoute(
          path: 'broadcast-widget/bdo-timer',
          builder: (context, state) => const ObsBdoTimerPage(),
        ),
        GoRoute(
          path: 'broadcast-widget/partrigio',
          builder: (context, state) => PartrigioPage(),
        ),
        GoRoute(
          path: 'adventurer-hub',
          builder: (context, state) {
            if (context.watch<AuthService>().waitResponse) {
              return const LoadingPage();
            }
            return AdventurerHubPage();
          },
          routes: [
            GoRoute(
              path: 'posts/:postId',
              builder: (context, state) {
                int? postId =
                    int.tryParse(state.pathParameters['postId'] ?? 'failed');
                if (postId == null) {
                  return const InvalidAccessPage();
                } else {
                  return RecruitmentDetailPage(
                    postId: postId,
                    authenticated: context.read<AuthService>().authenticated,
                  );
                }
              },
            )
          ],
        ),
      ],
    ),
  ],
);
