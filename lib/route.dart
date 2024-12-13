import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/adventurer_hub/adventurer_hub_page.dart';
import 'package:karanda/adventurer_hub/recruitment_detail_page.dart';
import 'package:karanda/artifact/artifact_page.dart';
import 'package:karanda/atoraxxion/sycrakea_page.dart';
import 'package:karanda/atoraxxion/yolunakea_moon_page.dart';
import 'package:karanda/auth/auth_error_page.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/auth/auth_page.dart';
import 'package:karanda/bdo_news/event_calendar/event_calendar_page.dart';
import 'package:karanda/color_counter/color_counter_page.dart';
import 'package:karanda/home/home_page.dart';
import 'package:karanda/horse_status/horse_status_page.dart';
import 'package:karanda/initializer/initializer_page.dart';
import 'package:karanda/obs_widgets/obs_bdo_timer/obs_bdo_timer_page.dart';
import 'package:karanda/obs_widgets/partrigio_page.dart';
import 'package:karanda/overlay/pages/overlay_page.dart';
import 'package:karanda/settings/change_log_page.dart';
import 'package:karanda/settings/karanda_info_page.dart';
import 'package:karanda/settings/settings_page.dart';
import 'package:karanda/settings/support_karanda_page.dart';
import 'package:karanda/settings/theme_setting_page.dart';
import 'package:karanda/ship_upgrading/ship_upgrading_page.dart';
import 'package:karanda/shutdown_scheduler/shutdown_scheduler_page.dart';
import 'package:karanda/trade/trade_calculator_page.dart';
import 'package:karanda/trade_market/presets/cooking_box_page.dart';
import 'package:karanda/trade_market/presets/dehkias_light_page.dart';
import 'package:karanda/trade_market/presets/magical_lightstone_crystal_page.dart';
import 'package:karanda/trade_market/presets/melody_of_stars_page.dart';
import 'package:karanda/trade_market/trade_market_detail_page.dart';
import 'package:karanda/trade_market/trade_market_page.dart';
import 'package:karanda/verification_center/verification_center_page.dart';
import 'package:karanda/widgets/invalid_access_page.dart';
import 'package:karanda/widgets/loading_page.dart';
import 'package:karanda/world_boss/world_boss_page.dart';
import 'package:provider/provider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/window-init',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
            path: 'window-init',
            builder: (context, state) => const InitializerPage(),
            redirect: (BuildContext context, GoRouterState state) {
              if (kIsWeb) {
                return '/';
              }
              return null;
            }),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
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
              path: 'theme',
              builder: (context, state) => const ThemeSettingPage(),
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
        ),
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
          path: 'auth',
          builder: (context, state) => const AuthPage(
            token: null,
            refreshToken: null,
          ),
        ),
        GoRoute(
          path: 'color-counter',
          builder: (context, state) => const ColorCounterPage(),
        ),
        GoRoute(
          path: 'trade-market',
          builder: (context, state) => const TradeMarketPage(),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => TradeMarketDetailPage(
                code: state.extra as String?,
                name: state.uri.queryParameters['name'],
              ),
            ),
            GoRoute(
              path: 'cooking-box',
              builder: (context, state) => const CookingBoxPage(),
            ),
            GoRoute(
              path: 'melody-of-stars',
              builder: (context, state) => const MelodyOfStarsPage(),
            ),
            GoRoute(
              path: 'magical-lightstone-crystal',
              builder: (context, state) => const MagicalLightstoneCrystalPage(),
            ),
            GoRoute(
              path: 'dehkias-light',
              builder: (context, state) => const DehkiasLightPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'world-boss',
          builder: (context, state) => const WorldBossPage(),
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
          path: 'overlay',
          builder: (context, state) => const OverlayPage(),
          redirect: (BuildContext context, GoRouterState state) {
            if (kIsWeb) {
              return '/';
            }
            return null;
          },
        ),
        GoRoute(
          path: 'verification-center',
          builder: (context, state) {
            if (context.watch<AuthNotifier>().waitResponse) {
              return const LoadingPage();
            }
            return VerificationCenterPage();
          },
        ),
        GoRoute(
            path: 'adventurer-hub',
            builder: (context, state) {
              if (context.watch<AuthNotifier>().waitResponse) {
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
                      authenticated: context.read<AuthNotifier>().authenticated,
                    );
                  }
                },
              )
            ]),
      ],
    ),
  ],
);
