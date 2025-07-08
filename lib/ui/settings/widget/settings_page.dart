import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/ui/auth/widgets/auth_info_page.dart';
import 'package:karanda/ui/auth/widgets/auth_page.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/ui/settings/controller/settings_controller.dart';
import 'package:karanda/ui/settings/widget/notification_settings_page.dart';
import 'package:karanda/ui/settings/widget/push_notification_settings_page.dart';
import 'package:karanda/utils/api_endpoints/karanda_api.dart';
import 'package:karanda/utils/external_links.dart';
import 'package:karanda/utils/launch_url.dart';
import 'package:karanda/widgets/class_symbol_widget.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: FontAwesomeIcons.gear,
        title: context.tr("settings.settings"),
      ),
      body: Consumer(builder: (context, SettingsController controller, child) {
        return PageBase(children: [
          _AccountTile(
            user: controller.user,
          ),
          _NotificationTile(authenticated: controller.authenticated),
          ListTile(
            onTap: () => context.goWithGa("/settings/styles"),
            leading: const Icon(Icons.palette_outlined),
            title: Text(context.tr("settings.style")),
          ),
          _VolumeTile(
            volume: controller.audioPlayerSettings.volume,
            onChanged: controller.setVolume,
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text("Languages"),
            subtitle: const Text("This feature is still in the works."),
            subtitleTextStyle:
                TextTheme.of(context).bodySmall?.copyWith(color: Colors.grey),
            trailing: MenuAnchor(
              builder: (context, controller, child) {
                return TextButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Text(
                    context.locale.toLanguageTag(),
                    style: TextTheme.of(context).bodyLarge,
                  ),
                );
              },
              menuChildren: context.supportedLocales
                  .map((locale) => MenuItemButton(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(locale.toLanguageTag()),
                        ),
                        onPressed: () => context.setLocale(locale),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(context.tr("settings.region")),
            trailing: Text(controller.appSettings.region.name),
          ),
          const _WindowsTile(),
          ListTile(
            onTap: () => launchURL(ExternalLinks.discord),
            leading: const Icon(
              size: 20.0,
              FontAwesomeIcons.discord,
            ),
            title: Text(context.tr("settings.karanda discord")),
            trailing: const Icon(Icons.open_in_new),
          ),
          ListTile(
            onTap: () => context.goWithGa('/settings/support-karanda'),
            leading: const Icon(Icons.loyalty_outlined),
            title: Text(context.tr("settings.support")),
          ),
          ListTile(
            onTap: () => context.goWithGa('/settings/change-log'),
            leading: const Icon(Icons.description_outlined),
            title: Text(context.tr("settings.updateHistory")),
          ),
          ListTile(
            onTap: () => context.goWithGa('/settings/karanda-info'),
            leading: const Icon(Icons.info_outline),
            title: Text(context.tr("settings.info")),
          ),
        ]);
      }),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final User? user;

  const _AccountTile({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AuthInfoPage(),
          ));
        },
        leading: user?.family == null ? CircleAvatar(
          foregroundImage: Image.network(user!.avatar).image,
          backgroundColor: Colors.transparent,
          radius: 12,
        ) : ClassSymbolWidget(className: user!.family!.mainClass.name),
        title: Text(user!.family?.familyName ?? user!.username),
        trailing: user?.family == null
            ? null
            : Icon(
                Icons.verified,
                color: user!.family!.verified ? Colors.blue : Colors.grey,
              ),
      );
    }
    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ));
      },
      leading: const Icon(Icons.login),
      title: Text(context.tr("auth.social login")),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final bool authenticated;

  const _NotificationTile({
    super.key,
    required this.authenticated,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return ListTile(
        leading: const Icon(Icons.notifications),
        title: Text(context.tr("settings.push notifications")),
        onTap: () {
          if (authenticated) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PushNotificationSettingsPage(),
            ));
          } else {
            SnackBarKit.of(context).needLogin();
          }
        },
      );
    }
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: Text(context.tr("settings.notifications")),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const NotificationSettingsPage(),
        ));
      },
    );
  }
}

class _VolumeTile extends StatelessWidget {
  final double volume;
  final void Function(double value) onChanged;

  const _VolumeTile({super.key, required this.volume, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.volume_up),
      title: Text(context.tr("settings.volume")),
      //expandedAlignment: Alignment.centerLeft,
      /*childrenPadding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),*/
      children: [
        Slider(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          value: volume,
          onChanged: onChanged,
          min: 0.0,
          max: 100.0,
          divisions: 100,
          label: volume.round().toString(),
        ),
      ],
    );
  }
}

class _WindowsTile extends StatelessWidget {
  const _WindowsTile({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isWindows) {
      return ListTile(
        onTap: () => launchURL(KarandaApi.latestVersionMirrors.first),
        leading: const Icon(Icons.install_desktop),
        title: Text(context.tr("settings.download windows installer")),
        trailing: const Icon(Icons.open_in_new),
      );
    }
    return ListTile(
      onTap: () => context.goWithGa('/settings/windows-settings'),
      leading: const Icon(Icons.desktop_windows_outlined),
      title: Text(context.tr("settings.windows settings")),
    );
  }
}
