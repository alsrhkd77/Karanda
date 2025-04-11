import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/ui/auth/widgets/auth_info_page.dart';
import 'package:karanda/ui/auth/widgets/auth_page.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/settings/controller/settings_controller.dart';
import 'package:karanda/utils/external_links.dart';
import 'package:karanda/utils/launch_url.dart';
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
            title: Text(context.tr("settings.update history")),
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
        leading: CircleAvatar(
          foregroundImage: Image.network(user!.avatar).image,
          radius: 12,
        ),
        title: Text(user!.username),
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
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
